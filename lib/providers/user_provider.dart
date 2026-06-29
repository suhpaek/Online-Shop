import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);
