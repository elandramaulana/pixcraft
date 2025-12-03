export interface GeneratePhotoRequest {
  imageUrl: string;
  userId: string;
  variations?: string[]; // e.g., ['beach', 'city', 'mountain']
}

export interface GeneratePhotoResponse {
  success: boolean;
  generationId: string;
  message: string;
  variations?: GeneratedVariation[];
  error?: string;
}

export interface GeneratedVariation {
  type: string; // 'beach', 'city', etc.
  imageUrl: string;
  storageRef: string;
  prompt: string;
}

export interface UploadImageRequest {
  imageBase64: string;
  userId: string;
  fileName: string;
}

export interface UploadImageResponse {
  success: boolean;
  imageUrl: string;
  storagePath: string;
  error?: string;
}