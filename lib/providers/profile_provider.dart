import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/firebase_profile_service.dart';
import '../services/local_profile_service.dart';
import 'user_provider.dart';

final profileProvider = StateProvider<Profile?>((ref) => null);

final profileAuthSyncProvider = Provider<void>((ref) {
  ref.listen<User?>(currentUserProvider, (_, __) {
    ref.read(profileProvider.notifier).state = null;
  });
});

final firebaseProfileServiceProvider = Provider(
  (ref) => FirebaseProfileService(),
);

final localProfileServiceProvider = Provider((ref) => LocalProfileService());
