import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/login_provider.dart';
import 'screens/details_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    final GoRouter router = GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/login',
      redirect: (context, state) {
        final isLoggedIn = ref.read(authProvider);
        final isLoggingIn =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final tab = state.uri.queryParameters['tab'];
            final initialIndex = tab == 'cart'
                ? 1
                : tab == 'profile'
                ? 2
                : 0;

            return MainWrapper(initialIndex: initialIndex);
          },
        ),
        GoRoute(
          path: '/details/:id',
          builder: (context, state) =>
              DetailsScreen(productId: int.parse(state.pathParameters['id']!)),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const MainWrapper(initialIndex: 2),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Product Catalog',
      routerConfig: router,
    );
  }
}
