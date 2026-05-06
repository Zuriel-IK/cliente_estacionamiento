import 'dart:async';

import 'package:cliente_estacionamiento/features/auth/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/auth_model.dart';
import '../../../core/network/token_storage.dart';

part 'session_provider.g.dart';

@riverpod
class SessionController extends _$SessionController {
  TokenStorage get _tokenStorage => TokenStorage();

  @override
  FutureOr<AuthResponse?> build() async {
    final token = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (token == null || refreshToken == null) {
      return null;
    }

    try {
      final user = await ref.read(authRepositoryProvider).getUserProfile();
      return AuthResponse(
        token: token,
        refreshToken: refreshToken,
        user: user,
      );
    } catch (e) {
      return AuthResponse(
        token: token,
        refreshToken: refreshToken,
        user: User(
          id: '',
          firstName: '',
          lastName: '',
        ),
      );
    }
  }

  Future<void> setSession(AuthResponse authData) async {
    await _tokenStorage.saveTokens(authData.token, authData.refreshToken);
    state = AsyncValue.data(authData);
  }

  Future<void> refreshProfile() async {
    final current = state.valueOrNull;
    if (current == null) return;

    try {
      final user = await ref.read(authRepositoryProvider).getUserProfile();

      state = AsyncValue.data(
        AuthResponse(
          token: current.token,
          refreshToken: current.refreshToken,
          user: user,
        ),
      );
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
    } finally {
      await _tokenStorage.clearTokens();
      state = const AsyncValue.data(null);
    }
  }

  Future<void> clearSession() async {
    await _tokenStorage.clearTokens();
    state = const AsyncValue.data(null);
  }
}