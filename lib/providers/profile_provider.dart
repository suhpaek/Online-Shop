import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/firebase_profile_service.dart';
import '../services/local_profile_service.dart';

final profileProvider = StateProvider<Profile?>((ref) => null);

final firebaseProfileServiceProvider = Provider(
  (ref) => FirebaseProfileService(),
);

final localProfileServiceProvider = Provider((ref) => LocalProfileService());
