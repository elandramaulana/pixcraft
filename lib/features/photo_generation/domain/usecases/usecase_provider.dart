import 'package:pixcraft/features/photo_generation/data/repositories/repository_provider.dart';
import 'package:pixcraft/features/photo_generation/domain/usecases/fetch_generation_usecase.dart';
import 'package:pixcraft/features/photo_generation/domain/usecases/generate_image_usecase.dart';
import 'package:riverpod/riverpod.dart';

import 'download_image_usecase.dart';
import 'upload_image_usecase.dart';

final uploadImageUseCaseProvider = Provider<UploadImageUseCase>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  return UploadImageUseCase(repository);
});

final generateImagesUseCaseProvider = Provider<GenerateImagesUseCase>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  return GenerateImagesUseCase(repository);
});

final fetchGenerationsUseCaseProvider = Provider<FetchGenerationsUseCase>((
  ref,
) {
  final repository = ref.watch(photoRepositoryProvider);
  return FetchGenerationsUseCase(repository);
});

final downloadImageUseCaseProvider = Provider<DownloadImageUseCase>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  return DownloadImageUseCase(repository);
});
