export const CONFIG = {
  IMAGEN_MODEL: "imagen-3.0-capability-001",
  REGION: "us-central1",
  MAX_VARIATIONS: 4,
  
  COLLECTIONS: {
    USERS: "users",
    USER_GENERATIONS: "user_generations",
  },
  
  STORAGE_PATHS: {
    ORIGINALS: "originals",
    GENERATED: "generated",
  },
};

// IMPROVED PROMPTS - More detailed and descriptive
export const VARIATION_PROMPTS = {
  beach: "stunning tropical beach background with crystal clear turquoise ocean water, white sandy shore, tall swaying palm trees, bright sunny sky with few clouds, paradise island atmosphere, highly detailed, photorealistic",
  
  city: "modern urban cityscape background with towering glass skyscrapers, busy street scene, contemporary architecture, evening golden hour lighting, metropolitan atmosphere, sharp details, photorealistic",
  
  mountain: "majestic mountain landscape background with snow-capped peaks, dramatic alpine scenery, green valley below, clear blue sky, breathtaking vista, natural lighting, highly detailed, photorealistic",
  
  cafe: "cozy modern cafe interior background with warm ambient lighting, wooden furniture, potted plants, large windows, aesthetic minimalist decor, soft natural light, inviting atmosphere, photorealistic",
};