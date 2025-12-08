export interface UploadImageRequest {
  imageBase64: string;
  userId: string;
  fileName: string;
}

export interface UploadImageResponse {
  success: boolean;
  imageUrl: string;
  storagePath: string;
  documentId: string;
}

export interface GeneratePhotoRequest {
  imageUrl: string;
  userId: string;
  selectedScene: string; // NEW: Selected scene ID
}

export interface GeneratedVariation {
  type: string;
  imageUrl: string;
  storagePath: string;
  prompt: string;
  scene?: string; // NEW: Scene identifier
  variationNumber?: number; // NEW: Variation number (1-4)
}

export interface GeneratePhotoResponse {
  success: boolean;
  generationId: string;
  message: string;
  variations: GeneratedVariation[];
  selectedScene?: string; // NEW: Selected scene
}