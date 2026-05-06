import 'dart:convert';

import '../../../core/network/token_storage.dart';
import '../../../core/sse/sse_client_service.dart';
import '../../models/api_response_model.dart';
import '../../models/dashboard_model.dart';

class DashboardSseService {
  final SseClientService _sseClient;
  final TokenStorage _storage = TokenStorage();

  DashboardSseService({required SseClientService sseClient})
      : _sseClient = sseClient;

  Stream<DashboardModel> connect() async* {
    final token = await _storage.getAccessToken();

    final headers = <String, String>{
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final rawStream = _sseClient.connect(
      path: '/api/dashboard/stream',
      headers: headers,
    );

    await for (final raw in rawStream) {
      if (raw.isEmpty) continue;

      dynamic decoded;
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        continue;
      }
      if (decoded is! Map) continue;

      final map = Map<String, dynamic>.from(decoded);

      final apiResponse = ApiResponse<DashboardModel>.fromJson(
        map,
            (json) => DashboardModel.fromJson(json as Map<String, dynamic>),
      );

      final data = apiResponse.data;
      if (data == null) continue;

      yield data;
    }
  }
}