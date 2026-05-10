import 'dart:async';

import 'package:cliente_estacionamiento/core/network/dio_client.dart';
import 'package:cliente_estacionamiento/core/sse/sse_client_service.dart';
import 'package:cliente_estacionamiento/features/auth/providers/session_provider.dart';
import 'package:cliente_estacionamiento/features/models/ticket_model.dart';
import 'package:cliente_estacionamiento/features/ticket/data/ticket_repository.dart';
import 'package:cliente_estacionamiento/features/ticket/data/ticket_sse_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticket_provider.g.dart';

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dio = ref.read(dioProvider);
  return TicketRepository(dio);
});

final ticketSseClientServiceProvider = Provider<SseClientService>((ref) {
  return SseClientService();
});

final ticketSseServiceProvider = Provider<TicketSseService>((ref) {
  final sseClient = ref.watch(ticketSseClientServiceProvider);
  return TicketSseService(sseClient: sseClient);
});

@riverpod
Stream<List<TicketModel>> ticketUpdates(
    TicketUpdatesRef ref,
    ) async* {
  final session = await ref.watch(sessionControllerProvider.future);

  if (session == null || session.accessToken.isEmpty) {
    return;
  }

  final userId = session.user.id;
  if (userId.isEmpty) {
    return;
  }

  final sse = ref.watch(ticketSseServiceProvider);
  yield* sse.connect(userId);
}

@Riverpod(keepAlive: true)
class TicketList extends _$TicketList {
  @override
  Future<List<TicketModel>> build() async {
    return _fetchTickets();
  }

  Future<List<TicketModel>> _fetchTickets() async {
    final session = ref.read(sessionControllerProvider).valueOrNull;

    final userId = session?.user.id;
    if (userId == null || userId.isEmpty) {
      throw Exception('No hay sesión activa o userId no disponible');
    }

    final repository = ref.read(ticketRepositoryProvider);
    return repository.getTickets(userId: userId);
  }

  Future<void> refreshTickets() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTickets);
  }

  void applyUpdate(List<TicketModel> tickets) {
    state = AsyncValue.data(tickets);
  }
}

@riverpod
Future<num> ticketCalculatedFinalFee(
    TicketCalculatedFinalFeeRef ref,
    int code,
    ) async {
  final repository = ref.read(ticketRepositoryProvider);
  return repository.calculateFinalFee(code: code);
}

@Riverpod(keepAlive: true)
class ConfirmTicketPaymentAction extends _$ConfirmTicketPaymentAction {
  @override
  FutureOr<void> build() {}

  Future<void> confirmPayment({
    required int code,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(ticketRepositoryProvider);

      await repository.confirmTicketPayment(code: code);

      await ref.read(ticketListProvider.notifier).refreshTickets();

      ref.invalidate(ticketCalculatedFinalFeeProvider(code));
    });
  }
}