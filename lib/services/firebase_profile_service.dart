import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/profile_model.dart';

class FirebaseProfileService {
  FirebaseProfileService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection('profiles');

  Future<Profile?> loadProfile(String userId) async {
    final snapshot = await _profiles.doc(userId).get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      return null;
    }

    return Profile.fromJson(data);
  }

  Future<void> saveProfile({
    required String userId,
    required Profile profile,
  }) async {
    await _profiles.doc(userId).set(profile.toJson(), SetOptions(merge: true));
  }
}
