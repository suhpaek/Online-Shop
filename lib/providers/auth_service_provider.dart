import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider((ref) => FirebaseAuthService());
