import 'dart:async';

import 'package:cliente_estacionamiento/core/network/dio_client.dart';
import 'package:cliente_estacionamiento/core/sse/sse_client_service.dart';
import 'package:cliente_estacionamiento/features/auth/providers/session_provider.dart';
import 'package:cliente_estacionamiento/features/models/reservation_model.dart';
import 'package:cliente_estacionamiento/features/reservation/data/reservation_repository.dart';
import 'package:cliente_estacionamiento/features/reservation/data/reservation_sse_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reservation_provider.g.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ReservationRepository(dio);
});

final reservationSseClientServiceProvider = Provider<SseClientService>((ref) {
  return SseClientService();
});

final reservationSseServiceProvider = Provider<ReservationSseService>((ref) {
  final sseClient = ref.watch(reservationSseClientServiceProvider);
  return ReservationSseService(sseClient: sseClient);
});

final reservationCodeProvider =
FutureProvider.family<int, String>((ref, reservationId) async {
  final repository = ref.read(reservationRepositoryProvider);
  return repository.getReservationCode(reservationId: reservationId);
});

@riverpod
Stream<List<ReservationModel>> reservationUpdates(
    ReservationUpdatesRef ref,
    ) async* {
  final session = await ref.watch(sessionControllerProvider.future);

  if (session == null || session.accessToken.isEmpty) {
    return;
  }

  final userId = session.user.id;
  if (userId.isEmpty) {
    return;
  }

  final sse = ref.watch(reservationSseServiceProvider);
  yield* sse.connect(userId);
}

@Riverpod(keepAlive: true)
class ReservationList extends _$ReservationList {
  @override
  Future<List<ReservationModel>> build() async {
    return _fetchReservations();
  }

  Future<List<ReservationModel>> _fetchReservations() async {
    final session = ref.read(sessionControllerProvider).valueOrNull;

    final userId = session?.user.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('No hay sesión activa o userId no disponible');
    }

    final repository = ref.read(reservationRepositoryProvider);
    return repository.getReservations(userId: userId);
  }

  Future<void> refreshReservations() async {
    state = await AsyncValue.guard(_fetchReservations);
  }

  void applyUpdate(List<ReservationModel> reservations) {
    state = AsyncValue.data(reservations);
  }

  void addReservationLocally(ReservationModel reservation) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([reservation, ...current]);
  }

  void removeReservationLocally(String reservationId) {
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.where((item) => item.id != reservationId).toList(),
    );
  }
}

@Riverpod(keepAlive: true)
class CreateReservationAction extends _$CreateReservationAction {
  @override
  FutureOr<void> build() {}

  Future<void> createReservation({
    required String placeId,
    required int time,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final session = ref.read(sessionControllerProvider).valueOrNull;
      final userId = session?.user.id;

      if (userId == null || userId.isEmpty) {
        throw Exception('No hay sesión activa o userId no disponible');
      }

      final repository = ref.read(reservationRepositoryProvider);

      final created = await repository.createReservation(
        userId: userId,
        placeId: placeId,
        time: time,
      );

      ref.read(reservationListProvider.notifier).addReservationLocally(created);
    });
  }

  void clearState() {
    state = const AsyncData(null);
  }
}

@Riverpod(keepAlive: true)
class DeleteReservationAction extends _$DeleteReservationAction {
  @override
  FutureOr<void> build() {}

  Future<void> deleteReservation({
    required String reservationId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(reservationRepositoryProvider);

      await repository.deleteReservation(
        reservationId: reservationId,
      );

      ref
          .read(reservationListProvider.notifier)
          .removeReservationLocally(reservationId);
    });
  }

  void clearState() {
    state = const AsyncData(null);
  }
}