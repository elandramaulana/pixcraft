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

export const SCENES = {
  luxury_car: {
    id: 'luxury_car',
    name: 'Luxury Car',
    icon: '🚗',
    description: 'Sitting in a luxury sports car',
  },
  cafe: {
    id: 'cafe',
    name: 'Cozy Cafe',
    icon: '☕',
    description: 'Relaxing in a modern cafe',
  },
  travel: {
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    description: 'Exploring iconic landmarks',
  },
  beach: {
    id: 'beach',
    name: 'Beach Paradise',
    icon: '🏖️',
    description: 'Enjoying tropical paradise',
  },
  mountain: {
    id: 'mountain',
    name: 'Mountain',
    icon: '🏔️',
    description: 'Adventure in the mountains',
  },
  city: {
    id: 'city',
    name: 'Urban Life',
    icon: '🌆',
    description: 'Modern city lifestyle',
  },
  office: {
    id: 'office',
    name: 'Professional',
    icon: '💼',
    description: 'Modern office setting',
  },
  party: {
    id: 'party',
    name: 'Party Night',
    icon: '🎉',
    description: 'Glamorous night out',
  },
} as const;

// ULTRA-SIMPLE: Just describe the scene, let [1] preserve the face
export const VARIATION_PROMPTS = {
  luxury_car: `person sitting naturally in luxury car driver seat, hands on steering wheel, casual comfortable driving position, looking forward through windshield`,
  
  cafe: `person sitting at cafe table, holding coffee cup with hands, leaning slightly forward, natural relaxed posture`,
  
  travel: `person standing casually at landmark, hands in pockets or by sides, natural tourist pose, slight smile`,
  
  beach: `person standing on beach, arms relaxed at sides or one hand running through hair, natural beach pose, ocean behind`,
  
  mountain: `person standing on trail, hands on hips or holding backpack straps, confident outdoor pose, mountain background`,
  
  city: `person walking on city sidewalk, natural stride, arms swinging naturally, looking forward, urban background`,
  
  office: `person sitting at office desk, typing on laptop or holding pen, professional working posture, office background`,
  
  party: `person standing at venue, holding drink in one hand, relaxed social pose, ambient party lighting behind`,
};

export function getSceneInfo(sceneId: string) {
  return SCENES[sceneId as keyof typeof SCENES] || null;
}

// FIXED: Stronger negative prompts focused on preventing face changes
export const NEGATIVE_PROMPTS = {
  common: "different person, wrong identity, face replacement, altered face, face morph, inconsistent features",
  
  luxury_car: "cheap car, damaged interior, old vehicle, messy",
  cafe: "empty cafe, messy, fluorescent harsh lighting, corporate chain",
  travel: "crowded, photoshopped fake background, empty landmarks",
  beach: "polluted beach, overcast, dirty sand, crowded",
  mountain: "flat land, urban setting, wrong season clothes",
  city: "empty streets, suburban, rural, wrong time of day",
  office: "cluttered messy desk, outdated office, poor lighting",
  party: "empty venue, bright daylight, casual daytime outfit",
};

// FIXED: Cleaner, more focused scene contexts
export const SCENE_CONTEXTS = {
  luxury_car: {
    lighting: "soft natural light with subtle interior glow",
    mood: "confident sophisticated",
    colorPalette: "rich blacks, chrome, warm leather",
    environment: "luxury car interior"
  },
  cafe: {
    lighting: "warm golden hour window light",
    mood: "relaxed cozy",
    colorPalette: "warm browns, cream, natural wood",
    environment: "modern aesthetic cafe"
  },
  travel: {
    lighting: "golden hour warm glow",
    mood: "adventurous excited",
    colorPalette: "vibrant natural colors",
    environment: "iconic landmark location"
  },
  beach: {
    lighting: "bright natural sunlight",
    mood: "carefree joyful",
    colorPalette: "turquoise, white sand, tropical",
    environment: "tropical beach paradise"
  },
  mountain: {
    lighting: "crisp clear daylight",
    mood: "adventurous energized",
    colorPalette: "greens, grays, earth tones",
    environment: "mountain wilderness"
  },
  city: {
    lighting: "urban mixed natural and artificial",
    mood: "confident stylish",
    colorPalette: "urban grays, warm lights",
    environment: "modern city street"
  },
  office: {
    lighting: "natural daylight with office lighting",
    mood: "professional approachable",
    colorPalette: "clean whites, blues, glass",
    environment: "contemporary office"
  },
  party: {
    lighting: "warm ambient with bokeh",
    mood: "celebratory glamorous",
    colorPalette: "rich blacks, gold, jewel tones",
    environment: "upscale nightlife venue"
  },
};