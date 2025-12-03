// FILE: functions/src/initFirestore.ts
// One-time script untuk initialize Firestore collections

import { onRequest } from 'firebase-functions/v2/https';
import { getFirestore } from 'firebase-admin/firestore';
import * as admin from 'firebase-admin';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const initFirestore = onRequest(async (req, res) => {
  try {
    const db = getFirestore();
    
    console.log('🔧 Initializing Firestore collections...');
    
    // Create dummy documents to initialize collections
    const collections = ['images', 'generations', 'users'];
    
    for (const collectionName of collections) {
      const docRef = await db.collection(collectionName).add({
        _initialized: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`✅ Collection '${collectionName}' initialized with doc ID: ${docRef.id}`);
      
      // Delete dummy document
      await docRef.delete();
      console.log(`🗑️  Dummy document deleted from '${collectionName}'`);
    }
    
    res.json({
      success: true,
      message: 'Firestore collections initialized successfully',
      collections,
    });
    
  } catch (error: any) {
    console.error('❌ Initialization error:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// Setelah deploy, call function ini sekali:
// https://us-central1-pixcraft-4841b.cloudfunctions.net/initFirestore