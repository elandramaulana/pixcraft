import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getStorage } from 'firebase-admin/storage';
import * as admin from 'firebase-admin';
import { getDb } from './firebase';
import { UploadImageRequest, UploadImageResponse } from './types';
import { CONFIG } from './config';

export const uploadImage = onCall<UploadImageRequest, Promise<UploadImageResponse>>(
  {
    timeoutSeconds: 60,
    memory: '512MiB',
    region: CONFIG.REGION,
    enforceAppCheck: false,
    cors: true,
  },
  async (request) => {
    try {
      console.log('Upload request received');
      console.log('User ID:', request.auth?.uid);
      
      // Validate authentication
      if (!request.auth) {
        console.error('❌ Unauthenticated request');
        throw new HttpsError('unauthenticated', 'User must be authenticated');
      }

      const { imageBase64, userId, fileName } = request.data;

      // Validate input
      if (!imageBase64 || !userId || !fileName) {
        console.error('❌ Missing required fields');
        throw new HttpsError(
          'invalid-argument',
          'Missing required fields: imageBase64, userId, or fileName'
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

      // Convert base64 to buffer
      const imageBuffer = Buffer.from(imageBase64, 'base64');
      console.log(`✅ Buffer size: ${imageBuffer.length} bytes`);

      // Validate file size (max 10MB)
      const maxSize = 10 * 1024 * 1024;
      if (imageBuffer.length > maxSize) {
        console.error('❌ Image too large');
        throw new HttpsError(
          'invalid-argument',
          `Image size exceeds 10MB limit (${imageBuffer.length} bytes)`
        );
      }

      // Generate storage path
      const timestamp = Date.now();
      const storagePath = `${CONFIG.STORAGE_PATHS.ORIGINALS}/${userId}/${timestamp}_${fileName}`;

      // Upload to Firebase Storage
      const bucket = getStorage().bucket();
      const file = bucket.file(storagePath);

      await file.save(imageBuffer, {
        metadata: {
          contentType: 'image/jpeg',
          metadata: {
            userId,
            uploadedAt: new Date().toISOString(),
          },
        },
      });

      console.log('✅ File saved to storage');

      // Make file publicly accessible
      await file.makePublic();
      const imageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
      console.log(`✅ Public URL: ${imageUrl}`);

      // Create NEW generation document with original image only
      console.log('💾 Creating generation document in Firestore...');
      
      let generationId = '';
      
      try {
        // Get Firestore instance using lazy initialization
        const db = getDb();
        
        const generationData = {
          userId,
          originalImage: {
            url: imageUrl,
            storagePath,
            fileName,
          },
          generatedImages: [], // Empty array, will be filled during generation
          status: 'uploaded', // Initial status
          variationTypes: [],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };
        
        console.log('📝 Generation document data:', JSON.stringify(generationData, null, 2));
        
        const docRef = await db.collection(CONFIG.COLLECTIONS.USER_GENERATIONS).add(generationData);
        generationId = docRef.id;
        
        console.log('✅ Generation document created with ID:', generationId);
        
      } catch (firestoreError: any) {
        console.error('⚠️ Firestore save failed:', firestoreError);
        console.error('Error code:', firestoreError.code);
        console.error('Error message:', firestoreError.message);
        
        throw new HttpsError(
          'internal',
          'Failed to create generation document',
          firestoreError.message
        );
      }

      console.log('🎉 Upload completed successfully');

      return {
        success: true,
        imageUrl,
        storagePath,
        documentId: generationId,
      };

    } catch (error: any) {
      console.error('❌ Upload error:', error);
      console.error('Error code:', error.code);
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);
      
      if (error instanceof HttpsError) {
        throw error;
      }

      throw new HttpsError(
        'internal',
        'Failed to upload image',
        error.message || String(error)
      );
    }
  }
);