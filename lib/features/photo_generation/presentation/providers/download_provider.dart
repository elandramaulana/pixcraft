import 'package:pixcraft/features/photo_generation/domain/usecases/usecase_provider.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../core/utils/logger.dart';

class DownloadNotifier extends StateNotifier<Map<String, bool>> {
  final Ref ref;

  DownloadNotifier(this.ref) : super({});

  Future<bool> downloadImage({
    required String imageUrl,
    required String fileName,
  }) async {
    try {
      // Set downloading state
      state = {...state, imageUrl: true};

      Logger.info('Downloading image: $fileName');

      final downloadUseCase = ref.read(downloadImageUseCaseProvider);
      final success = await downloadUseCase.execute(
        imageUrl: imageUrl,
        fileName: fileName,
      );

      // Remove downloading state
      state = {...state}..remove(imageUrl);

      return success;
    } catch (e) {
      Logger.error('Download failed', e);

      // Remove downloading state
      state = {...state}..remove(imageUrl);

      return false;
    }
  }

  bool isDownloading(String imageUrl) {
    return state[imageUrl] ?? false;
  }
}

final downloadProvider =
    StateNotifierProvider<DownloadNotifier, Map<String, bool>>((ref) {
      return DownloadNotifier(ref);
    });
