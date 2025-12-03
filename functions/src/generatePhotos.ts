import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { getStorage } from 'firebase-admin/storage';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';
import { GeneratePhotoRequest, GeneratePhotoResponse, GeneratedVariation } from './types';
import { CONFIG, VARIATION_PROMPTS } from './config';

const serviceAccountSecret = defineSecret('GOOGLE_SERVICE_ACCOUNT');

export const generatePhotoVariations = onCall<GeneratePhotoRequest, Promise<GeneratePhotoResponse>>(
  {
    secrets: [serviceAccountSecret],
    timeoutSeconds: 300,
    memory: '1GiB',
    region: CONFIG.REGION,
    enforceAppCheck: false,
    cors: true,
  },
  async (request) => {
    try {
      console.log('🚀 Starting generation request');
      
      // Validate authentication
      if (!request.auth) {
        console.error('❌ Unauthenticated request');
        throw new HttpsError(
          'unauthenticated',
          'User must be authenticated'
        );
      }

      const { imageUrl, userId, variations } = request.data;

      // Validate input
      if (!imageUrl || !userId) {
        console.error('❌ Missing required fields');
        throw new HttpsError(
          'invalid-argument',
          'Missing required fields: imageUrl or userId'
        );
      }

      // Verify userId matches authenticated user
      if (request.auth.uid !== userId) {
        console.error('❌ User ID mismatch');
        throw new HttpsError(
          'permission-denied',
          'User ID does not match authenticated user'
        );
      }

      console.log('✅ Validation passed');
      console.log('🚀 Starting generation for user:', userId);

      // Get service account credentials
      const serviceAccountJson = serviceAccountSecret.value();
      const serviceAccount = JSON.parse(serviceAccountJson);

      // Create auth client
      console.log('🔑 Creating auth client...');
      const auth = new GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      });

      const client = await auth.getClient();
      const accessToken = await client.getAccessToken();

      if (!accessToken.token) {
        throw new Error('Failed to obtain access token');
      }

      console.log('✅ Access token obtained');

      // Determine which variations to generate
      const variationTypes = variations && variations.length > 0
        ? variations.slice(0, CONFIG.MAX_VARIATIONS)
        : Object.keys(VARIATION_PROMPTS).slice(0, CONFIG.MAX_VARIATIONS);

      console.log('🎨 Generating variations:', variationTypes);

      // Create generation document in Firestore
      console.log('💾 Creating generation record in Firestore...');
      const db = getFirestore();
      
      let generationRef;
      let generationId;
      
      try {
        generationRef = await db.collection(CONFIG.COLLECTIONS.GENERATIONS).add({
          userId,
          originalImageUrl: imageUrl,
          status: 'processing',
          variationTypes,
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });
        
        generationId = generationRef.id;
        console.log('✅ Generation record created:', generationId);
        
      } catch (firestoreError: any) {
        console.error('⚠️ Firestore generation record failed:', firestoreError.message);
        // Continue without Firestore tracking
        generationId = `gen_${Date.now()}`;
        console.log('⚠️ Continuing with temporary ID:', generationId);
      }

      // Generate images for each variation
      const projectId = serviceAccount.project_id;
      const endpoint = `https://${CONFIG.REGION}-aiplatform.googleapis.com/v1/projects/${projectId}/locations/${CONFIG.REGION}/publishers/google/models/${CONFIG.IMAGEN_MODEL}:predict`;

      const generatedVariations: GeneratedVariation[] = [];

      for (const variationType of variationTypes) {
        try {
          console.log(`🎨 Generating ${variationType} variation...`);

          const prompt = VARIATION_PROMPTS[variationType as keyof typeof VARIATION_PROMPTS] || 
                        `A person in a beautiful ${variationType} scene, Instagram-worthy photo`;

          // Call Imagen API
          const requestBody = {
            instances: [{ prompt }],
            parameters: {
              sampleCount: 1,
              aspectRatio: CONFIG.IMAGE_ASPECT_RATIO,
              safetyFilterLevel: CONFIG.SAFETY_FILTER,
              personGeneration: CONFIG.PERSON_GENERATION,
            },
          };

          console.log(`📡 Calling Imagen API for ${variationType}...`);
          const response = await axios.post(endpoint, requestBody, {
            headers: {
              'Authorization': `Bearer ${accessToken.token}`,
              'Content-Type': 'application/json',
            },
            timeout: 60000,
          });

          const predictions = response.data.predictions;
          
          if (predictions && predictions.length > 0) {
            const imageBase64 = predictions[0].bytesBase64Encoded;
            console.log(`✅ Image generated for ${variationType}`);

            // Upload generated image to Storage
            const timestamp = Date.now();
            const storagePath = `${CONFIG.STORAGE_PATHS.GENERATED}/${userId}/${generationId}/${variationType}_${timestamp}.jpg`;

            console.log(`⬆️ Uploading to Storage: ${storagePath}`);
            const bucket = getStorage().bucket();
            const file = bucket.file(storagePath);

            await file.save(Buffer.from(imageBase64, 'base64'), {
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
            console.log(`✅ File uploaded and made public: ${generatedImageUrl}`);

            // Save to Firestore (with error handling)
            try {
              await db.collection(CONFIG.COLLECTIONS.IMAGES).add({
                userId,
                generationId,
                imageUrl: generatedImageUrl,
                storagePath,
                type: 'generated',
                variationType,
                prompt,
                generatedAt: FieldValue.serverTimestamp(),
              });
              console.log(`✅ Metadata saved to Firestore for ${variationType}`);
            } catch (firestoreError: any) {
              console.error(`⚠️ Firestore metadata save failed for ${variationType}:`, firestoreError.message);
              // Continue - image is already uploaded
            }

            generatedVariations.push({
              type: variationType,
              imageUrl: generatedImageUrl,
              storageRef: storagePath,
              prompt,
            });

            console.log(`✅ ${variationType} generated successfully`);
          } else {
            console.warn(`⚠️ No predictions returned for ${variationType}`);
          }

        } catch (error: any) {
          console.error(`❌ Failed to generate ${variationType}:`, error.message);
          // Continue with other variations even if one fails
        }
      }

      // Update generation status (with error handling)
      if (generationRef) {
        try {
          await generationRef.update({
            status: generatedVariations.length > 0 ? 'completed' : 'failed',
            variations: generatedVariations,
            completedAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
          console.log('✅ Generation status updated in Firestore');
        } catch (firestoreError: any) {
          console.error('⚠️ Failed to update generation status:', firestoreError.message);
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