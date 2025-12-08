import 'package:pixcraft/services/firebase/firebase_provider.dart';
import 'package:riverpod/riverpod.dart';

import 'cloud_function_datasource.dart';
import 'firebase_storage_datasource.dart';
import 'firestore_datasource.dart';

// Cloud Function Datasource Provider
final cloudFunctionDatasourceProvider = Provider<CloudFunctionDatasource>((
  ref,
) {
  final functions = ref.watch(firebaseFunctionsProvider);
  return CloudFunctionDatasourceImpl(
    functions,
  ); // Changed: Use the implementation class
});

// Firestore Datasource Provider
final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreDatasource(firestore);
});

// Storage Datasource Provider
final storageDatasourceProvider = Provider<FirebaseStorageDatasource>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  return FirebaseStorageDatasource(storage);
});
