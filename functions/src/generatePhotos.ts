import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { getStorage } from 'firebase-admin/storage';
import * as admin from 'firebase-admin';
import { GoogleAuth } from 'google-auth-library';
import { GeneratePhotoRequest, GeneratePhotoResponse, GeneratedVariation } from './types';
import { CONFIG, VARIATION_PROMPTS, NEGATIVE_PROMPTS, SCENE_CONTEXTS } from './config';
import { getDb } from './firebase';

const serviceAccountSecret = defineSecret('GOOGLE_SERVICE_ACCOUNT');

// Lazy imports to avoid initialization timeout
let axios: any = null;
let sharpModule: any = null;

async function getAxios() {
  if (!axios) {
    axios = (await import('axios')).default;
  }
  return axios;
}

async function getSharp() {
  if (!sharpModule) {
    sharpModule = (await import('sharp')).default;
  }
  return sharpModule;
}

async function analyzeImageContext(imageBase64: string): Promise<{
  aspectRatio: string;
  orientation: 'portrait' | 'landscape' | 'square';
  suggestedFraming: string;
  dimensions: { width: number; height: number };
}> {
  const sharp = await getSharp();
  const imageBuffer = Buffer.from(imageBase64, 'base64');
  const metadata = await sharp(imageBuffer).metadata();
  
  const width = metadata.width!;
  const height = metadata.height!;
  const ratio = width / height;
  
  let orientation: 'portrait' | 'landscape' | 'square';
  let suggestedFraming: string;
  let aspectRatio: string;
  
  if (ratio < 0.95) {
    orientation = 'portrait';
    suggestedFraming = 'vertical portrait composition';
    if (ratio < 0.65) {
      aspectRatio = '9:16';
    } else {
      aspectRatio = '3:4';
    }
  } else if (ratio > 1.05) {
    orientation = 'landscape';
    suggestedFraming = 'horizontal landscape composition';
    if (ratio > 1.6) {
      aspectRatio = '16:9';
    } else {
      aspectRatio = '4:3';
    }
  } else {
    orientation = 'square';
    suggestedFraming = 'square composition';
    aspectRatio = '1:1';
  }
  
  console.log(`📊 Mapped ${width}x${height} (${ratio.toFixed(2)}) → ${aspectRatio}`);
  
  return { aspectRatio, orientation, suggestedFraming, dimensions: { width, height } };
}

// FIXED: Ultra-focused prompts for maximum face preservation
function buildEnhancedPrompt(
  basePrompt: string,
  sceneContext: any,
  variationIndex: number
): string {
  // Format: Keep subject [1] prominent with scene context
  const variations = [
    'professional photography, sharp focus on face',
    'high quality portrait, natural expression', 
    'lifestyle photography, authentic moment',
    'editorial style photo, engaging pose'
  ];
  
  const style = variations[variationIndex % variations.length];
  
  return `${basePrompt}, the person is [1], ${style}, photorealistic, 8k quality`;
}
// Di generatePhotoVariations.ts - GANTI buildNegativePrompt:
function buildNegativePrompt(selectedScene: string): string {
  // KUNCI: Fokus ke "jangan ubah identitas" bukan "jangan blur/distort"
  const identityLock = `different person, wrong identity, face replacement, face swap, substituted face, another person's face, someone else, different individual, changed identity, swapped identity, face morph between people, merged faces, blended faces`;
  
  const featureChange = `altered facial features, modified face structure, different nose, different eyes, different eyebrows, different mouth shape, different chin, different cheekbones, different face shape, different skin tone, different complexion, different ethnicity, different gender presentation`;
  
  const ageChange = `different age, aged up, aged down, younger appearance, older appearance, baby face, elderly face, age progression, age regression`;
  
  const quality = `no face, faceless, missing face, obscured face, hidden face, covered face, blurred face, distorted face, deformed, mutation, disfigured, multiple faces, extra limbs, bad anatomy, low quality, blurry image, pixelated, watermark, text, logo`;
  
  const sceneNegative = NEGATIVE_PROMPTS[selectedScene as keyof typeof NEGATIVE_PROMPTS] || '';
  
  return `${identityLock}, ${featureChange}, ${ageChange}, ${quality}, ${sceneNegative}`;
}


export const generatePhotoVariations = onCall<GeneratePhotoRequest, Promise<GeneratePhotoResponse>>(
  {
    secrets: [serviceAccountSecret],
    timeoutSeconds: 540,
    memory: '4GiB',
    region: CONFIG.REGION,
    enforceAppCheck: false,
    cors: true,
    minInstances: 0,
    maxInstances: 10,
    concurrency: 1,
  },
  async (request) => {
    const startTime = Date.now();
    
    try {
      console.log('🚀 Starting photo generation with enhanced face preservation');
      
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const { imageUrl, userId, selectedScene } = request.data;

      if (!imageUrl || !userId || !selectedScene) {
        throw new HttpsError('invalid-argument', 'Missing required fields');
      }

      if (request.auth.uid !== userId) {
        throw new HttpsError('permission-denied', 'User ID mismatch');
      }

      console.log(`✅ Scene: ${selectedScene} | User: ${userId.substring(0, 8)}...`);

      // Get credentials
      const serviceAccountJson = serviceAccountSecret.value();
      const serviceAccount = JSON.parse(serviceAccountJson);
      const projectId = serviceAccount.project_id;

      const auth = new GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      });

      const client = await auth.getClient();
      const accessToken = await client.getAccessToken();

      if (!accessToken.token) {
        throw new Error('Failed to obtain access token');
      }

      console.log(`🔑 Authentication completed (${Date.now() - startTime}ms)`);

      // Lazy load axios
      const axiosInstance = await getAxios();

      // Download and analyze image
      console.log('📥 Downloading and analyzing image...');
      const imageResponse = await axiosInstance.get(imageUrl, { 
        responseType: 'arraybuffer',
        timeout: 30000,
        maxContentLength: 10 * 1024 * 1024,
      });
      const imageBase64 = Buffer.from(imageResponse.data).toString('base64');
      
      const imageContext = await analyzeImageContext(imageBase64);
      console.log(`📊 Analysis: ${imageContext.orientation} ${imageContext.aspectRatio}`);

      // Get scene configuration
      const basePrompt = VARIATION_PROMPTS[selectedScene as keyof typeof VARIATION_PROMPTS];
      const sceneContext = SCENE_CONTEXTS[selectedScene as keyof typeof SCENE_CONTEXTS];
      
      if (!basePrompt || !sceneContext) {
        throw new HttpsError('invalid-argument', `Invalid scene: ${selectedScene}`);
      }

      const negativePrompt = buildNegativePrompt(selectedScene);

      console.log(`🎨 Generating 4 variations with STRICT face preservation for: ${selectedScene}`);

      // Setup Firestore with lazy initialization
      let generationRef;
      let generationId;
      
      try {
        const db = getDb();
        const querySnapshot = await db
          .collection(CONFIG.COLLECTIONS.USER_GENERATIONS)
          .where('userId', '==', userId)
          .where('originalImage.url', '==', imageUrl)
          .where('selectedScene', '==', selectedScene)
          .limit(1)
          .get();

        if (!querySnapshot.empty) {
          generationRef = querySnapshot.docs[0].ref;
          generationId = generationRef.id;
          await generationRef.update({
            status: 'processing',
            selectedScene,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          const generationData = {
            userId,
            originalImage: { url: imageUrl, storagePath: '', fileName: 'uploaded_image.jpg' },
            generatedImages: [],
            status: 'processing',
            selectedScene,
            imageContext,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          generationRef = await db.collection(CONFIG.COLLECTIONS.USER_GENERATIONS).add(generationData);
          generationId = generationRef.id;
        }
      } catch (firestoreError: any) {
        generationId = `gen_${Date.now()}`;
        console.log('⚠️ Using temporary ID:', generationId);
      }

      const endpoint = `https://${CONFIG.REGION}-aiplatform.googleapis.com/v1/projects/${projectId}/locations/${CONFIG.REGION}/publishers/google/models/${CONFIG.IMAGEN_MODEL}:predict`;
      
      const generatedVariations: GeneratedVariation[] = [];
      const failedAttempts: number[] = [];

      // Generate 4 variations
      for (let i = 0; i < CONFIG.MAX_VARIATIONS; i++) {
        try {
          console.log(`🎨 Generating variation ${i + 1}/${CONFIG.MAX_VARIATIONS}...`);

          const enhancedPrompt = buildEnhancedPrompt(basePrompt, sceneContext, i);

          // ULTRA-AGGRESSIVE FACE PRESERVATION CONFIGURATION
      const requestBody = {
        instances: [
          {
            prompt: enhancedPrompt,
            negativePrompt: negativePrompt,
            referenceImages: [
              {
                referenceType: "REFERENCE_TYPE_SUBJECT",
                referenceId: 1,
                referenceImage: {
                  bytesBase64Encoded: imageBase64
                },
                subjectImageConfig: {
                  subjectType: "SUBJECT_TYPE_PERSON",
                  subjectDescription: "exact same person with identical face"
                }
              }
            ]
          }
        ],
        parameters: {
          sampleCount: 1,
          aspectRatio: imageContext.aspectRatio,
          safetyFilterLevel: "block_only_high",
          personGeneration: "allow_adult",
          addWatermark: false,
          outputOptions: {
            mimeType: "image/jpeg",
            compressionQuality: 95
          },
          // KUNCI: Gunakan seed yang sama untuk konsistensi wajah
          seed: 12345  // Seed tetap untuk semua variasi
        }
      };

          console.log(`📝 Config: ${imageContext.aspectRatio} | ULTRA face preservation | seed: ${42 + i}`);

          const response = await axiosInstance.post(endpoint, requestBody, {
            headers: {
              'Authorization': `Bearer ${accessToken.token}`,
              'Content-Type': 'application/json',
            },
            timeout: 120000,
          });

          const predictions = response.data.predictions;

          if (predictions && predictions.length > 0) {
            const generatedImageBase64 = predictions[0].bytesBase64Encoded;
            console.log(`✅ Variation ${i + 1} generated with face preservation`);

            // Upload to Storage
            const timestamp = Date.now();
            const storagePath = `${CONFIG.STORAGE_PATHS.GENERATED}/${userId}/${generationId}/${selectedScene}_v${i + 1}_${timestamp}.jpg`;

            const bucket = getStorage().bucket();
            const file = bucket.file(storagePath);

            await file.save(Buffer.from(generatedImageBase64, 'base64'), {
              metadata: {
                contentType: 'image/jpeg',
                metadata: {
                  userId,
                  generationId,
                  scene: selectedScene,
                  variationNumber: (i + 1).toString(),
                  aspectRatio: imageContext.aspectRatio,
                  generatedAt: new Date().toISOString(),
                },
              },
            });

            await file.makePublic();
            const generatedImageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;

            generatedVariations.push({
              type: `${selectedScene}_v${i + 1}`,
              imageUrl: generatedImageUrl,
              storagePath, 
              prompt: enhancedPrompt,
              scene: selectedScene,
              variationNumber: i + 1,
            });

            console.log(`✅ Variation ${i + 1} uploaded (${Date.now() - startTime}ms total)`);
          } else {
            console.warn(`⚠️ No predictions returned for variation ${i + 1}`);
            failedAttempts.push(i + 1);
          }

          // Delay between generations
          if (i < CONFIG.MAX_VARIATIONS - 1) {
            const delay = 3000 + Math.random() * 2000;
            await new Promise(resolve => setTimeout(resolve, delay));
          }

        } catch (error: any) {
          console.error(`❌ Failed variation ${i + 1}:`, error.message);
          failedAttempts.push(i + 1);
          
          if (error.response?.data) {
            console.error('API Error Details:', JSON.stringify(error.response.data, null, 2));
          }
          
          if (error.response?.status === 429) {
            console.log('⏳ Rate limited, waiting 8 seconds...');
            await new Promise(resolve => setTimeout(resolve, 8000));
          }
        }
      }

      // Update Firestore
      if (generationRef) {
        try {
          const updateData = {
            generatedImages: generatedVariations,
            selectedScene,
            imageContext,
            status: generatedVariations.length > 0 ? 'completed' : 'failed',
            successCount: generatedVariations.length,
            failedAttempts: failedAttempts,
            processingTimeMs: Date.now() - startTime,
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          
          await generationRef.update(updateData);
          console.log('✅ Firestore updated successfully');
          
        } catch (firestoreError: any) {
          console.error('⚠️ Firestore update failed:', firestoreError.message);
        }
      }

      const successRate = ((generatedVariations.length / CONFIG.MAX_VARIATIONS) * 100).toFixed(0);
      console.log(`🎉 Generation completed with face preservation!`);
      console.log(`📊 Success: ${generatedVariations.length}/${CONFIG.MAX_VARIATIONS} (${successRate}%)`);
      console.log(`⏱️  Total time: ${Date.now() - startTime}ms`);

      return {
        success: generatedVariations.length > 0,
        generationId,
        message: `Successfully generated ${generatedVariations.length} out of ${CONFIG.MAX_VARIATIONS} variations for ${selectedScene} with face preservation`,
        variations: generatedVariations,
        selectedScene,
        imageContext,
        failedCount: failedAttempts.length,
        processingTimeMs: Date.now() - startTime,
      };

    } catch (error: any) {
      console.error('❌ Critical error:', error);
      console.error('Stack trace:', error.stack);

      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        'internal',
        'Failed to generate photo variations',
        error instanceof Error ? error.message : String(error)
      );
    }
  }
);