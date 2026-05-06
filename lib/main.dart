import 'package:cliente_estacionamiento/core/theme/app_theme.dart';
import 'package:cliente_estacionamiento/features/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './core/router/app_router.dart';
import './core/notifications/app_notifier.dart';
import './features/auth/providers/session_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    const ProviderScope(
      child: AppBootstrap(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PointSpace',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: AppNotifier.scaffoldMessengerKey,
      theme:  AppTheme.light,
      routerConfig: router,
    );
  }
}

class AppBootstrap extends ConsumerWidget {
  final Widget child;

  const AppBootstrap({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionControllerProvider);

    return sessionAsync.when(
      loading: () => MaterialApp(

        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: AppNotifier.scaffoldMessengerKey,
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: AppCircleLoading(),
          ),
        ),
      ),
      error: (_, __) => child,
      data: (_) => child,
    );
  }
}