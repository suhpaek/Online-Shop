import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_auth_service.dart';

final localAuthServiceProvider = Provider((ref) => LocalAuthService());
