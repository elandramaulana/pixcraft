import 'package:pixcraft/features/photo_generation/data/datasources/datasource_provider.dart';
import 'package:riverpod/riverpod.dart';

import 'photo_repository.dart';
import 'photo_repository_impl.dart';

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final cloudFunctionDatasource = ref.watch(cloudFunctionDatasourceProvider);
  final firestoreDatasource = ref.watch(firestoreDatasourceProvider);
  final storageDatasource = ref.watch(storageDatasourceProvider);

  return PhotoRepositoryImpl(
    cloudFunctionDatasource: cloudFunctionDatasource,
    firestoreDatasource: firestoreDatasource,
    storageDatasource: storageDatasource,
  );
});
