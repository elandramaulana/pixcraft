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

// BALANCED: Focus on pose + setting, let reference handle face
export const VARIATION_PROMPTS = {
  luxury_car: `
    Person is positioned inside a luxury sports car with a natural driving or passenger pose: hands holding steering wheel or resting naturally,
    torso angled according to car seat, relaxed shoulders. 
    pose fully redefined. NOT same as base image
    Replace entire background with premium car interior.
  `,

  cafe: `
    Person adopts a pose: sitting at cafe table, holding coffee cup with one hand, leaning slightly forward, natural relaxed posture.
    NOT the same pose with base image.
    Replace full background with warm modern cafe environment.
  `,

  travel: `
    Person adopts new tourist pose: standing casually, slightly leaning, 
    hands relaxed (or holding phone/camera), natural stance suitable for sightseeing.
     pose fully redefined. NOT same as base image
    Replace background with iconic landmark scenery.
  `,

  beach: `
    Person adopts beach pose: standing with a relaxed beach pose (light breeze posture, natural hip shift, relaxed arms or one hand touching hair).
    pose fully redefined. NOT same as base image
    Replace the background with a tropical beach.
  `,

  mountain: `
    Person adopts adventure pose: standing on trail, holding backpack straps, confident outdoor pose, mountain background.
    Pose fully redefined, not same as base image
  `,

  city: `
    Person adopts walking on city sidewalk: natural stride, arms swinging naturally, looking forward.
    Generate new outfit and body posture matching the scene NOT same base with image.
    Replace background with urban backgroud.
  `,

  office: `
    Person adopts office-appropriate pose: seated at desk, typing on laptop,
    or standing with arms lightly crossed. Reposed body, not same with base imange.
    Replace background with modern office interior.
  `,

  party: `
    Person adopts party social pose: holding a drink, slightly leaning, relaxed shoulders,
    natural nightlife posture. 
    Entire pose must be newly generated, uniquely suited for party scene.
    Replace background with elegant party venue.
  `,
};





export function getSceneInfo(sceneId: string) {
  return SCENES[sceneId as keyof typeof SCENES] || null;
}

// REBALANCED: Much stronger identity lock
export const NEGATIVE_PROMPTS = {
  identity: "different person, wrong person, face swap, altered identity, changed facial features, wrong identity",
  
  background: "keeping exact same background, identical original background, original photo background, same background, unchanged background",
  
  // Tambahan larangan pose lama
  pose: "same pose as original photo, identical selfie pose, unchanged posture, unmodified body position, stiff pose, selfie-like pose, arm position identical to selfie, same body angle as reference, original selfie framing, original pose silhouette",
  
  luxury_car: "cheap car, damaged vehicle, old car interior, no car visible",
  cafe: "empty room, no cafe elements, harsh fluorescent lighting",
  travel: "no landmark visible, generic indoor space",
  beach: "no ocean, no beach, indoor location, urban setting",
  mountain: "flat terrain, no mountains visible, indoor setting",
  city: "rural area, nature only, no urban elements",
  office: "home setting, messy room, no office furniture",
  party: "bright daylight, empty room, no party atmosphere",
};



// REFINED: Describe environment without overriding Person
export const SCENE_CONTEXTS = {
  luxury_car: {
    lighting: "soft interior ambient lighting",
    mood: "confident sophisticated",
    colorPalette: "rich blacks, chrome, warm leather",
    environment: "luxury car interior",
    backgroundElements: "car dashboard, steering wheel, premium leather seats"
  },
  cafe: {
    lighting: "warm golden hour window light",
    mood: "relaxed cozy",
    colorPalette: "warm browns, cream, natural wood",
    environment: "modern aesthetic cafe",
    backgroundElements: "cafe furniture, coffee equipment, plants, windows"
  },
  travel: {
    lighting: "natural bright daylight",
    mood: "adventurous excited",
    colorPalette: "vibrant colors, clear blues",
    environment: "iconic landmark location",
    backgroundElements: "famous landmark, architectural structure"
  },
  beach: {
    lighting: "bright tropical sunlight",
    mood: "carefree joyful",
    colorPalette: "turquoise, white sand, tropical",
    environment: "tropical beach",
    backgroundElements: "ocean, sandy beach, palm trees, blue sky"
  },
  mountain: {
    lighting: "crisp clear daylight",
    mood: "adventurous energized",
    colorPalette: "greens, grays, earth tones",
    environment: "mountain wilderness",
    backgroundElements: "mountain peaks, forest trail, rocky terrain"
  },
  city: {
    lighting: "urban daylight",
    mood: "confident stylish",
    colorPalette: "urban grays, modern tones",
    environment: "modern city street",
    backgroundElements: "tall buildings, city skyline, urban street"
  },
  office: {
    lighting: "natural office lighting",
    mood: "professional focused",
    colorPalette: "clean whites, blues, glass",
    environment: "contemporary office",
    backgroundElements: "office desk, monitors, glass walls, furniture"
  },
  party: {
    lighting: "warm ambient with bokeh",
    mood: "celebratory glamorous",
    colorPalette: "blacks, gold, jewel tones",
    environment: "upscale venue",
    backgroundElements: "party lights, bokeh, elegant decor"
  },
};