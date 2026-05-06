import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/sse/sse_client_service.dart';
import '../../auth/providers/session_provider.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_sse_service.dart';
import '../../models/dashboard_model.dart';

part 'home_provider.g.dart';

@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  final dio = ref.read(dioProvider);
  return DashboardRepository(dio);
}

@riverpod
SseClientService sseClientService(SseClientServiceRef ref) {
  return SseClientService(baseUrl: 'http://192.168.1.14:3100');
}

@riverpod
DashboardSseService dashboardSseService(DashboardSseServiceRef ref) {
  final sseClient = ref.watch(sseClientServiceProvider);
  return DashboardSseService(sseClient: sseClient);
}

@Riverpod(keepAlive: true)
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardModel> build() async {
    final session = await ref.watch(sessionControllerProvider.future);

    if (session == null || session.token.isEmpty) {
      throw Exception('Sesión no disponible');
    }

    final repo = ref.read(dashboardRepositoryProvider);
    return repo.getDashboard();
  }

  Future<void> refreshDashboard() async {
    state = await AsyncValue.guard(() async {
      final session = await ref.read(sessionControllerProvider.future);

      if (session == null || session.token.isEmpty) {
        throw Exception('Sesión no disponible');
      }

      final repo = ref.read(dashboardRepositoryProvider);
      return repo.getDashboard();
    });
  }

  void applyUpdate(DashboardModel updated) {
    state = AsyncValue.data(updated);
  }
}

@riverpod
Stream<DashboardModel> dashboardUpdates(DashboardUpdatesRef ref) async* {
  final session = await ref.watch(sessionControllerProvider.future);

  if (session == null || session.token.isEmpty) {
    return;
  }

  final sse = ref.watch(dashboardSseServiceProvider);
  yield* sse.connect();
}