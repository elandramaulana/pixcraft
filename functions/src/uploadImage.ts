// FILE: functions/src/uploadImage.ts

import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getStorage } from 'firebase-admin/storage';
import { getFirestore } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';
import { UploadImageRequest, UploadImageResponse } from './types';
import { CONFIG } from './config';

// Initialize Firebase Admin ONCE
if (admin.apps.length === 0) {
  admin.initializeApp();
}

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
      // Log untuk debugging
      console.log('📥 Upload request received');
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
      console.log('📦 Converting base64 to buffer...');
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
      console.log(`📂 Storage path: ${storagePath}`);

      // Upload to Firebase Storage
      console.log('⬆️  Uploading to Firebase Storage...');
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
      console.log('🔓 Making file public...');
      await file.makePublic();
      const imageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
      console.log(`✅ Public URL: ${imageUrl}`);

      // Save metadata to Firestore
      console.log('💾 Saving metadata to Firestore...');
      try {
        const db = getFirestore();
        
        // Langsung simpan tanpa test connection
        const docRef = await db.collection(CONFIG.COLLECTIONS.IMAGES).add({
          userId,
          imageUrl,
          storagePath,
          fileName,
          uploadedAt: admin.firestore.FieldValue.serverTimestamp(),
          type: 'original',
          createdAt: new Date().toISOString(),
        });

        console.log('✅ Metadata saved with ID:', docRef.id);
        
      } catch (firestoreError: any) {
        console.error('⚠️ Firestore save failed:', firestoreError.message);
        
        // Tetap return success karena file sudah ter-upload
        console.log('⚠️ Image uploaded successfully, but metadata save failed');
      }

      console.log('🎉 Upload completed successfully');

      return {
        success: true,
        imageUrl,
        storagePath,
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