import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

class LocalProfileService {
  static const _profilePrefix = 'profile_';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Profile?> loadProfile(String userId) async {
    final prefs = await _prefs;
    final rawProfile = prefs.getString('$_profilePrefix$userId');

    if (rawProfile == null) {
      return null;
    }

    final data = jsonDecode(rawProfile) as Map<String, dynamic>;
    return Profile.fromJson(data);
  }

  Future<void> saveProfile({
    required String userId,
    required Profile profile,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_profilePrefix$userId',
      jsonEncode(profile.toJson()),
    );
  }
}
