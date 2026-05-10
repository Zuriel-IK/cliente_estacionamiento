import 'dart:convert';

import 'package:cliente_estacionamiento/core/network/token_storage.dart';
import 'package:cliente_estacionamiento/core/sse/sse_client_service.dart';
import 'package:cliente_estacionamiento/features/models/ticket_model.dart';

class TicketSseService {
  final SseClientService _sseClient;
  final TokenStorage _storage = TokenStorage();

  TicketSseService({required SseClientService sseClient})
      : _sseClient = sseClient;

  Stream<List<TicketModel>> connect(String userId) async* {
    final token = await _storage.getAccessToken();

    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final rawStream = _sseClient.connect(
      path: '/api/sse/ticket/$userId',
      headers: headers,
    );

    await for (final message in rawStream) {
      print(message);
      if (message.event != 'ticket.updated') continue;
      final decoded = jsonDecode(message.data);


      List<dynamic>? list;

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['tickets'] is List) {
          list = decoded['tickets'] as List;
        } else if (decoded['data'] is List) {
          list = decoded['data'] as List;
        } else if (decoded['items'] is List) {
          list = decoded['items'] as List;
        }
      }

      if (list == null) continue;

      yield list
          .map((e) => TicketModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
}