import * as admin from 'firebase-admin';

// Initialize Firebase Admin only once
if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Lazy initialization functions to avoid deployment timeout
let firestoreDb: admin.firestore.Firestore | null = null;
let authInstance: admin.auth.Auth | null = null;
let storageInstance: admin.storage.Storage | null = null;

/**
 * Get Firestore instance with pixcraft database
 * Uses lazy initialization to avoid timeout during deployment
 */
export function getDb(): admin.firestore.Firestore {
  if (!firestoreDb) {
    firestoreDb = admin.firestore();
    firestoreDb.settings({ databaseId: 'pixcraft' });
    console.log('✅ Firestore initialized with database: pixcraft');
  }
  return firestoreDb;
}

/**
 * Get Auth instance
 * Uses lazy initialization to avoid timeout during deployment
 */
export function getAuth(): admin.auth.Auth {
  if (!authInstance) {
    authInstance = admin.auth();
    console.log('✅ Auth initialized');
  }
  return authInstance;
}

/**
 * Get Storage instance
 * Uses lazy initialization to avoid timeout during deployment
 */
export function getStorage(): admin.storage.Storage {
  if (!storageInstance) {
    storageInstance = admin.storage();
    console.log('✅ Storage initialized');
  }
  return storageInstance;
}

// Keep admin export for direct access if needed
export { admin };

// Legacy exports for backward compatibility (if needed)
// Comment these out if you want to force using getDb(), getAuth(), getStorage()
// export const db = getDb();
// export const auth = getAuth();
// export const storage = getStorage();