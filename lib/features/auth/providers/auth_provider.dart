import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../../models/auth_model.dart';
import '../../../core/network/dio_client.dart';
import 'session_provider.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return AuthRepository(dio);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthResponse?> build() {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authData =
      await ref.read(authRepositoryProvider).login(email, password);

      await ref.read(sessionControllerProvider.notifier).setSession(authData);

      state = AsyncValue.data(authData);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await ref.read(sessionControllerProvider.notifier).logout();
    state = const AsyncValue.data(null);
  }

  void clearState() {
    state = const AsyncValue.data(null);
  }
}