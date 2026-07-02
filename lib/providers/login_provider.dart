import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_provider.dart';

final authProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final emailProvider = Provider<String>((ref) {
  return ref.watch(currentUserEmailProvider);
});
