import 'package:cliente_estacionamiento/core/navigation/main_navigation_screen.dart';
import 'package:cliente_estacionamiento/features/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/session_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerListenableProvider = Provider<AuthRefreshListenable>((ref) {
  final listenable = AuthRefreshListenable(ref);
  ref.onDispose(listenable.dispose);
  return listenable;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerListenableProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final sessionState = ref.read(sessionControllerProvider);

      if (sessionState.isLoading) {
        return null;
      }

      final bool isLoggedIn = sessionState.valueOrNull != null;
      final bool isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [

      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/reservation',
        name: 'reservation',
        builder: (context, state) => const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const MainNavigationScreen(),
      ),
    ],
  );
});

class AuthRefreshListenable extends ChangeNotifier {
  late final ProviderSubscription<AsyncValue<AuthResponse?>> _subscription;

  AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen<AsyncValue<AuthResponse?>>(
      sessionControllerProvider,
          (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}