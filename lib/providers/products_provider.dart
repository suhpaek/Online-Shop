import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getProducts();
});

final productDetailsProvider = FutureProvider.family<Product, int>((ref, id) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getProductDetails(id);
});