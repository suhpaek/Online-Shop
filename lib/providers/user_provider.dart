import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service_provider.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authUserProvider).valueOrNull;
});

final currentUserEmailProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.email ?? '';
});

final currentUserIdProvider = Provider<String>((ref) {
  return ref.watch(currentUserProvider)?.uid ?? '';
});
