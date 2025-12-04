import * as admin from 'firebase-admin';

if (admin.apps.length === 0) {
  admin.initializeApp();
  const db = admin.firestore();
  db.settings({ databaseId: 'pixcraft' });
}

// Export pre-configured instances
export const db = admin.firestore();
export const auth = admin.auth();
export const storage = admin.storage();