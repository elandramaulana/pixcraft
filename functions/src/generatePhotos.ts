import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { getStorage } from 'firebase-admin/storage';
import * as admin from 'firebase-admin';
import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';
import { db } from './firebase';
import { GeneratePhotoRequest, GeneratePhotoResponse, GeneratedVariation } from './types';
import { CONFIG, VARIATION_PROMPTS } from './config';
import sharp from 'sharp';

const serviceAccountSecret = defineSecret('GOOGLE_SERVICE_ACCOUNT');

// STRATEGY 1: Aggressive mask - only protect person silhouette
async function generateAggressiveMask(imageBase64: string): Promise<string> {
  console.log('🎭 Generating AGGRESSIVE mask (minimal person protection)...');
  
  const imageBuffer = Buffer.from(imageBase64, 'base64');
  const metadata = await sharp(imageBuffer).metadata();
  const width = metadata.width!;
  const height = metadata.height!;

  console.log(`📐 Image size: ${width}x${height}`);

  // VERY SMALL person area: only 30% width x 40% height (face + upper body only)
  const personWidth = Math.floor(width * 0.3);
  const personHeight = Math.floor(height * 0.4);
  const left = Math.floor((width - personWidth) / 2);
  const top = Math.floor((height - personHeight) / 3); // Upper third

  // Create WHITE background (90%+ will be edited)
  const maskBuffer = await sharp({
    create: {
      width,
      height,
      channels: 3,
      background: { r: 255, g: 255, b: 255 } // WHITE = edit ALL of this
    }
  })
  .composite([
    {
      // Small BLACK oval/rectangle for person
      input: await sharp({
        create: {
          width: personWidth,
          height: personHeight,
          channels: 3,
          background: { r: 0, g: 0, b: 0 } // BLACK = keep only this tiny area
        }
      })
      .png()
      .toBuffer(),
      top,
      left,
    }
  ])
  .png()
  .toBuffer();

  const maskBase64 = maskBuffer.toString('base64');
  console.log('✅ Aggressive mask generated - 70%+ area will be edited');
  
  return maskBase64;
}

// STRATEGY 2: Full background replacement - detect person with edge blur
async function generateFullBackgroundMask(imageBase64: string): Promise<string> {
  console.log('🎭 Generating FULL BACKGROUND replacement mask...');
  
  const imageBuffer = Buffer.from(imageBase64, 'base64');
  const metadata = await sharp(imageBuffer).metadata();
  const width = metadata.width!;
  const height = metadata.height!;

  console.log(`📐 Image size: ${width}x${height}`);

  // Even smaller: 25% width x 35% height
  const personWidth = Math.floor(width * 0.25);
  const personHeight = Math.floor(height * 0.35);
  const left = Math.floor((width - personWidth) / 2);
  const top = Math.floor((height - personHeight) / 3.5);

  // Create person silhouette with soft edges
  const personMask = await sharp({
    create: {
      width: personWidth,
      height: personHeight,
      channels: 3,
      background: { r: 0, g: 0, b: 0 }
    }
  })
  .blur(5) // Soft edge untuk blending lebih natural
  .png()
  .toBuffer();

  const maskBuffer = await sharp({
    create: {
      width,
      height,
      channels: 3,
      background: { r: 255, g: 255, b: 255 }
    }
  })
  .composite([
    {
      input: personMask,
      top,
      left,
    }
  ])
  .png()
  .toBuffer();

  const maskBase64 = maskBuffer.toString('base64');
  console.log('✅ Full background mask generated - 80%+ area will be replaced');
  
  return maskBase64;
}

// Main function - choose strategy
async function generateMask(imageBase64: string, strategy: 'aggressive' | 'full' = 'full'): Promise<string> {
  if (strategy === 'aggressive') {
    return generateAggressiveMask(imageBase64);
  }
  return generateFullBackgroundMask(imageBase64);
}

export const generatePhotoVariations = onCall<GeneratePhotoRequest, Promise<GeneratePhotoResponse>>(
  {
    secrets: [serviceAccountSecret],
    timeoutSeconds: 300,
    memory: '2GiB',
    region: CONFIG.REGION,
    enforceAppCheck: false,
    cors: true,
  },
  async (request) => {
    try {
      console.log('🚀 Starting generation request');
      
      // Validation
      if (!request.auth) {
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const { imageUrl, userId, variations } = request.data;

      if (!imageUrl || !userId) {
        throw new HttpsError('invalid-argument', 'Missing required fields');
      }

      if (request.auth.uid !== userId) {
        throw new HttpsError('permission-denied', 'User ID mismatch');
      }

      console.log('✅ Validation passed');

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

      // Download image
      console.log('📥 Downloading image...');
      const imageResponse = await axios.get(imageUrl, { 
        responseType: 'arraybuffer',
        timeout: 30000,
      });
      const imageBase64 = Buffer.from(imageResponse.data).toString('base64');
      console.log('✅ Image downloaded');

      // Generate mask
      const maskBase64 = await generateMask(imageBase64);

      // Setup variations
      const variationTypes = variations && variations.length > 0
        ? variations.slice(0, CONFIG.MAX_VARIATIONS)
        : Object.keys(VARIATION_PROMPTS).slice(0, CONFIG.MAX_VARIATIONS);

      console.log('🎨 Generating variations:', variationTypes);

      // Setup Firestore
      let generationRef;
      let generationId;
      
      try {
        const querySnapshot = await db
          .collection(CONFIG.COLLECTIONS.USER_GENERATIONS)
          .where('userId', '==', userId)
          .where('originalImage.url', '==', imageUrl)
          .limit(1)
          .get();

        if (!querySnapshot.empty) {
          generationRef = querySnapshot.docs[0].ref;
          generationId = generationRef.id;
          await generationRef.update({
            status: 'processing',
            variationTypes,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          const generationData = {
            userId,
            originalImage: { url: imageUrl, storagePath: '', fileName: 'uploaded_image.jpg' },
            generatedImages: [],
            status: 'processing',
            variationTypes,
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

      // CORRECT API ENDPOINT - Use imagen-3.0-capability-001
      const endpoint = `https://${CONFIG.REGION}-aiplatform.googleapis.com/v1/projects/${projectId}/locations/${CONFIG.REGION}/publishers/google/models/imagen-3.0-capability-001:predict`;
      
      const generatedVariations: GeneratedVariation[] = [];

      // Generate each variation
      for (const variationType of variationTypes) {
        try {
          console.log(`🎨 Generating ${variationType} variation...`);

          const prompt = VARIATION_PROMPTS[variationType as keyof typeof VARIATION_PROMPTS] || 
                        `${variationType} background scene`;

          // CORRECT REQUEST BODY (sesuai dokumentasi Imagen 3.0)
          const requestBody = {
            instances: [
              {
                prompt: prompt,
                referenceImages: [
                  {
                    referenceType: "REFERENCE_TYPE_RAW",
                    referenceId: 1,
                    referenceImage: {
                      bytesBase64Encoded: imageBase64
                    }
                  },
                  {
                    referenceType: "REFERENCE_TYPE_MASK",
                    referenceId: 2,
                    referenceImage: {
                      bytesBase64Encoded: maskBase64
                    },
                    maskImageConfig: {
                      maskMode: "MASK_MODE_USER_PROVIDED",
                      dilation: 0.03 // Optional: slight dilation for smoother edges
                    }
                  }
                ]
              }
            ],
            parameters: {
              sampleCount: 1,
              editMode: "EDIT_MODE_INPAINT_INSERTION", // ✅ CORRECT: Insert new content
              editConfig: {
                baseSteps: 60, // Increase for stronger edits (35-75 range)
              },
              // Optional safety settings
              safetyFilterLevel: "block_some",
              personGeneration: "allow_adult",
            }
          };

          console.log(`📡 Calling Imagen 3.0 API for ${variationType}...`);
          console.log(`🎯 Prompt: ${prompt}`);
          
          const response = await axios.post(endpoint, requestBody, {
            headers: {
              'Authorization': `Bearer ${accessToken.token}`,
              'Content-Type': 'application/json',
            },
            timeout: 90000,
          });

          const predictions = response.data.predictions;

          if (predictions && predictions.length > 0) {
            const generatedImageBase64 = predictions[0].bytesBase64Encoded;
            console.log(`✅ ${variationType} generated successfully`);

            // Upload to Storage
            const timestamp = Date.now();
            const storagePath = `${CONFIG.STORAGE_PATHS.GENERATED}/${userId}/${generationId}/${variationType}_${timestamp}.jpg`;

            console.log(`⬆️ Uploading to Storage: ${storagePath}`);
            const bucket = getStorage().bucket();
            const file = bucket.file(storagePath);

            await file.save(Buffer.from(generatedImageBase64, 'base64'), {
              metadata: {
                contentType: 'image/jpeg',
                metadata: {
                  userId,
                  generationId,
                  variationType,
                  prompt,
                  generatedAt: new Date().toISOString(),
                },
              },
            });

            await file.makePublic();
            const generatedImageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
            console.log(`✅ File uploaded: ${generatedImageUrl}`);

            generatedVariations.push({
              type: variationType,
              imageUrl: generatedImageUrl,
              storagePath, 
              prompt,
            });

            console.log(`✅ ${variationType} completed`);
          } else {
            console.warn(`⚠️ No predictions returned for ${variationType}`);
          }

        } catch (error: any) {
          console.error(`❌ Failed to generate ${variationType}:`, error.message);
          if (error.response?.data) {
            console.error('API Error details:', JSON.stringify(error.response.data, null, 2));
          }
        }
      }

      // Update Firestore
      if (generationRef) {
        try {
          const updateData = {
            generatedImages: generatedVariations,
            status: generatedVariations.length > 0 ? 'completed' : 'failed',
            completedAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          
          console.log('📝 Updating generation document...');
          await generationRef.update(updateData);
          console.log('✅ Generation document updated');
          
        } catch (firestoreError: any) {
          console.error('⚠️ Failed to update generation:', firestoreError);
        }
      }

      console.log('🎉 Generation completed:', generationId);
      console.log(`📊 Successfully generated ${generatedVariations.length}/${variationTypes.length} variations`);

      return {
        success: true,
        generationId,
        message: `Successfully generated ${generatedVariations.length} variations`,
        variations: generatedVariations,
      };

    } catch (error: any) {
      console.error('❌ Generation error:', error);
      console.error('Error stack:', error.stack);

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