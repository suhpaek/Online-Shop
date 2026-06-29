import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';


class DetailsScreen extends ConsumerWidget {
  final int productId;

  const DetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productDetailsAsyncValue = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/catalog');
          },
        ),
      ),
      body: productDetailsAsyncValue.when(
        data: (product) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(product.image, height: 200),
                const SizedBox(height: 16),
                Text(product.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Text(product.description),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}