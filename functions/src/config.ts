export const CONFIG = {
  IMAGEN_MODEL: "imagen-4.0-fast-generate-001",
  REGION: "us-central1",
  MAX_VARIATIONS: 4,
  IMAGE_ASPECT_RATIO: "1:1",
  SAFETY_FILTER: "block_some",
  PERSON_GENERATION: "allow_adult",
  
  // Firestore collections - UPDATED STRUCTURE
  COLLECTIONS: {
    USERS: "users",
    USER_GENERATIONS: "user_generations",
  },
  
  // Storage paths
  STORAGE_PATHS: {
    ORIGINALS: "originals",
    GENERATED: "generated",
  },
};

export const VARIATION_PROMPTS = {
  beach: "Replace the background with a beautiful tropical beach scene. Keep the person in the same pose and appearance. The new background should show turquoise water, golden sand, and palm trees. Professional photo editing style, seamless integration.",
  
  city: "Replace the background with vibrant city streets and modern architecture. Keep the person in the same pose and appearance. The new background should show urban buildings, stylish cityscape. Professional photo editing style, seamless integration.",
  
  mountain: "Replace the background with a scenic mountain landscape. Keep the person in the same pose and appearance. The new background should show mountain peaks, breathtaking valley views. Professional photo editing style, seamless integration.",
  
  cafe: "Replace the background with a cozy aesthetic cafe interior. Keep the person in the same pose and appearance. The new background should show beautiful cafe decor, warm ambiance. Professional photo editing style, seamless integration.",
  
  desert: "Replace the background with a stunning desert landscape at golden hour. Keep the person in the same pose and appearance. The new background should show sand dunes, warm desert light. Professional photo editing style, seamless integration.",
  
  forest: "Replace the background with a lush green forest scene. Keep the person in the same pose and appearance. The new background should show tall trees, natural sunlight filtering through. Professional photo editing style, seamless integration.",
};