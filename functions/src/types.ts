export interface UploadImageRequest {
  imageBase64: string;
  userId: string;
  fileName: string;
}

export interface UploadImageResponse {
  success: boolean;
  imageUrl: string;
  storagePath: string;
  documentId?: string; // generationId
}

export interface GeneratePhotoRequest {
  imageUrl: string;
  userId: string;
  variations?: string[]; 
}

export interface GeneratedVariation {
  type: string;
  imageUrl: string;
  storagePath: string;   // ➤ hanya pakai ini
  prompt: string;
}

export interface GeneratePhotoResponse {
  success: boolean;
  generationId: string;
  message: string;
  variations: GeneratedVariation[];
}

export interface UserGenerationDocument {
  userId: string;
  originalImage: {
    url: string;
    storagePath: string;
    fileName: string;
  };
  generatedImages: GeneratedVariation[];
  status: 'processing' | 'completed' | 'failed';
  variationTypes: string[];
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
  completedAt?: FirebaseFirestore.Timestamp;
}
