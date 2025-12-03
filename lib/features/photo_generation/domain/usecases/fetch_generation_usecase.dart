import '../../../../core/utils/logger.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/photo_repository.dart';

class FetchGenerationsUseCase {
  final PhotoRepository _repository;

  FetchGenerationsUseCase(this._repository);

  Stream<List<PhotoModel>> execute(String userId) {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is required');
      }

      Logger.info('UseCase: Fetching user generations');
      return _repository.getUserImages(userId);
    } catch (e) {
      Logger.error('UseCase: Fetch generations failed', e);
      rethrow;
    }
  }
}
