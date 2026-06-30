import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_model.dart';
import '../providers/auth_service_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/profile_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.network(
                                cartItem.product.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${cartItem.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            cartNotifier.updateQuantity(
                                              cartItem.product.id,
                                              cartItem.quantity - 1,
                                            );
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        Text(cartItem.quantity.toString()),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            cartNotifier.updateQuantity(
                                              cartItem.product.id,
                                              cartItem.quantity + 1,
                                            );
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      cartNotifier.removeFromCart(
                                        cartItem.product.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${cartNotifier.getTotalPrice().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          Profile? profile = ref.read(profileProvider);

                          if (profile == null) {
                            final user = ref
                                .read(firebaseAuthServiceProvider)
                                .currentUser;

                            if (user != null) {
                              profile = await ref
                                  .read(localProfileServiceProvider)
                                  .loadProfile(user.uid);
                              ref.read(profileProvider.notifier).state =
                                  profile;

                              try {
                                final remoteProfile = await ref
                                    .read(firebaseProfileServiceProvider)
                                    .loadProfile(user.uid);

                                if (remoteProfile != null) {
                                  profile = remoteProfile;
                                  ref.read(profileProvider.notifier).state =
                                      remoteProfile;
                                  await ref
                                      .read(localProfileServiceProvider)
                                      .saveProfile(
                                        userId: user.uid,
                                        profile: remoteProfile,
                                      );
                                }
                              } on FirebaseException {
                                if (!context.mounted) {
                                  return;
                                }

                                if (profile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in your profile information first!',
                                      ),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                  context.go('/profile');
                                  return;
                                }
                              }
                            }
                          }

                          if (!context.mounted) {
                            return;
                          }

                          if (profile == null ||
                              profile.name.isEmpty ||
                              profile.email.isEmpty ||
                              profile.phone.isEmpty ||
                              profile.country.isEmpty ||
                              profile.city.isEmpty ||
                              profile.address.isEmpty ||
                              profile.postalCode.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill in your profile information first!',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                            context.go('/profile');
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order placed successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          cartNotifier.clearCart();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
