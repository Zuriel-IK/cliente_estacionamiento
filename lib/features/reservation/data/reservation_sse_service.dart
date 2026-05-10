import 'dart:convert';

import '../../../core/network/token_storage.dart';
import '../../../core/sse/sse_client_service.dart';
import '../../models/reservation_model.dart';

class ReservationSseService {
  final SseClientService _sseClient;
  final TokenStorage _storage = TokenStorage();

  ReservationSseService({
    required SseClientService sseClient,
  }) : _sseClient = sseClient;

  Stream<List<ReservationModel>> connect(String userId) async* {
    try {
      final token = await _storage.getAccessToken();

      final headers = <String, String>{
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final rawStream = _sseClient.connect(
        path: '/api/sse/reservation/$userId',
        headers: headers,
      );

      await for (final message in rawStream) {
        if (message.event != 'reservation.updated') continue;
        final decoded = jsonDecode(message.data);
        final payload = Map<String, dynamic>.from(decoded);
        final data = payload['data'];
        if (data is List) {
          yield data
              .map((e) => ReservationModel.fromJson(
            Map<String, dynamic>.from(e),
          ))
              .toList();
          continue;
        }

        if (data is Map<String, dynamic>) {
          final reservations = data['reservations'];

          if (reservations is List) {
            yield reservations
                .map((e) => ReservationModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
                .toList();
          }
        }
      }
    } catch (_) {
      return;
    }
  }
}