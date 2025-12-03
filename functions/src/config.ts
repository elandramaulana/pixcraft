export const CONFIG = {
  IMAGEN_MODEL: 'imagen-4.0-fast-generate-001',
  REGION: 'us-central1',
  MAX_VARIATIONS: 4,
  IMAGE_ASPECT_RATIO: '1:1',
  SAFETY_FILTER: 'block_some',
  PERSON_GENERATION: 'allow_adult',
  
  // Firestore collections
  COLLECTIONS: {
    USERS: 'users',
    GENERATIONS: 'generations',
    IMAGES: 'images',
  },
  
  // Storage paths
  STORAGE_PATHS: {
    ORIGINALS: 'originals',
    GENERATED: 'generated',
  },
};

export const VARIATION_PROMPTS = {
  beach: 'A person enjoying a beautiful tropical beach with turquoise water, golden sand, and palm trees, perfect Instagram travel photo',
  city: 'A person exploring vibrant city streets with modern architecture, urban lifestyle, stylish travel photography',
  mountain: 'A person on a scenic mountain summit with breathtaking views, adventure travel photography',
  cafe: 'A person at a cozy aesthetic cafe with beautiful interior design, lifestyle photography',
  desert: 'A person in a stunning desert landscape with sand dunes at golden hour, travel photography',
  forest: 'A person in a lush green forest with sunlight filtering through trees, nature photography',
};