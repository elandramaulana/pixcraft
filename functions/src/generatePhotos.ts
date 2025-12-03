// FILE: functions/src/generatePhotoVariations.ts

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import { getStorage } from 'firebase-admin/storage';
import * as admin from 'firebase-admin';
import { GoogleAuth } from 'google-auth-library';
import axios from 'axios';
import { GeneratePhotoRequest, GeneratePhotoResponse, GeneratedVariation } from './types';
import { CONFIG, VARIATION_PROMPTS } from './config';

// Initialize Firebase Admin ONCE
if (admin.apps.length === 0) {
  admin.initializeApp();
}

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
      console.log('Project ID:', process.env.GCP_PROJECT || process.env.GCLOUD_PROJECT);
      
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

      // Initialize Firestore
      const db = admin.firestore();
      db.settings({ databaseId: 'pixcraft' });
      
      console.log('🔧 Using Firestore database: pixcraft');

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

      // Download original image for reference image editing
      console.log('📥 Downloading original image...');
      const imageResponse = await axios.get(imageUrl, { 
        responseType: 'arraybuffer',
        timeout: 30000,
      });
      const imageBase64 = Buffer.from(imageResponse.data).toString('base64');
      console.log('✅ Original image downloaded');

      // Determine which variations to generate
      const variationTypes = variations && variations.length > 0
        ? variations.slice(0, CONFIG.MAX_VARIATIONS)
        : Object.keys(VARIATION_PROMPTS).slice(0, CONFIG.MAX_VARIATIONS);

      console.log('🎨 Generating variations:', variationTypes);

      // Find or create generation document
      console.log('💾 Finding generation document...');
      
      let generationRef;
      let generationId;
      
      try {
        // Search for existing generation document with this imageUrl
        const querySnapshot = await db
          .collection(CONFIG.COLLECTIONS.USER_GENERATIONS)
          .where('userId', '==', userId)
          .where('originalImage.url', '==', imageUrl)
          .limit(1)
          .get();

        if (!querySnapshot.empty) {
          // Use existing document
          generationRef = querySnapshot.docs[0].ref;
          generationId = generationRef.id;
          console.log('✅ Found existing generation document:', generationId);
          
          // Update status to processing
          await generationRef.update({
            status: 'processing',
            variationTypes,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          // Create new document (fallback)
          const generationData = {
            userId,
            originalImage: {
              url: imageUrl,
              storagePath: '',
              fileName: 'uploaded_image.jpg',
            },
            generatedImages: [],
            status: 'processing',
            variationTypes,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          
          generationRef = await db.collection(CONFIG.COLLECTIONS.USER_GENERATIONS).add(generationData);
          generationId = generationRef.id;
          console.log('✅ Created new generation document:', generationId);
        }
        
      } catch (firestoreError: any) {
        console.error('⚠️ Firestore operation failed:', firestoreError);
        generationId = `gen_${Date.now()}`;
        console.log('⚠️ Continuing with temporary ID:', generationId);
      }

      // Generate images for each variation using EDIT mode
      const projectId = serviceAccount.project_id;
      const endpoint = `https://${CONFIG.REGION}-aiplatform.googleapis.com/v1/projects/${projectId}/locations/${CONFIG.REGION}/publishers/google/models/${CONFIG.IMAGEN_MODEL}:predict`;

      const generatedVariations: GeneratedVariation[] = [];

      for (const variationType of variationTypes) {
        try {
          console.log(`🎨 Generating ${variationType} variation...`);

          const prompt = VARIATION_PROMPTS[variationType as keyof typeof VARIATION_PROMPTS] || 
                        `Replace background with ${variationType} scene. Keep the person unchanged.`;

          // Call Imagen API with EDIT mode - include reference image
          const requestBody = {
            instances: [
              { 
                prompt,
                image: {
                  bytesBase64Encoded: imageBase64,
                },
              }
            ],
            parameters: {
              sampleCount: 1,
              aspectRatio: CONFIG.IMAGE_ASPECT_RATIO,
              safetyFilterLevel: CONFIG.SAFETY_FILTER,
              personGeneration: CONFIG.PERSON_GENERATION,
              // IMPORTANT: Edit mode parameters
              editMode: 'inpainting-insert', // or 'outpainting' based on your needs
              mode: 'edit',
            },
          };

          console.log(`📡 Calling Imagen API for ${variationType} (EDIT MODE)...`);
          const response = await axios.post(endpoint, requestBody, {
            headers: {
              'Authorization': `Bearer ${accessToken.token}`,
              'Content-Type': 'application/json',
            },
            timeout: 90000, // Increased timeout for editing
          });

          const predictions = response.data.predictions;
          
          if (predictions && predictions.length > 0) {
            const generatedImageBase64 = predictions[0].bytesBase64Encoded;
            console.log(`✅ Image generated for ${variationType}`);

            // Upload generated image to Storage
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

            console.log(`✅ ${variationType} generated successfully`);
          } else {
            console.warn(`⚠️ No predictions returned for ${variationType}`);
          }

        } catch (error: any) {
          console.error(`❌ Failed to generate ${variationType}:`, error.message);
          if (error.response?.data) {
            console.error('API Error details:', JSON.stringify(error.response.data, null, 2));
          }
          // Continue with other variations
        }
      }

      // Update generation document with results
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