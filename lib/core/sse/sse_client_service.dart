import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class SseMessage {
  final String event;
  final String data;
  final String? id;
  final int? retry;

  const SseMessage({
    required this.event,
    required this.data,
    this.id,
    this.retry,
  });

  @override
  String toString() {
    return 'SseMessage(event: $event, data: $data, id: $id, retry: $retry)';
  }
}

class SseClientService {
  final http.Client _client;

  SseClientService({http.Client? client}) : _client = client ?? http.Client();

  Stream<SseMessage> connect({
    required String path,
    Map<String, String>? headers,
  }) async* {
    final net = NetworkApp.ip_server;
    final uri = Uri.parse('$net$path');

    final request = http.Request('GET', uri);
    request.headers.addAll({
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      ...?headers,
    });

    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Error al conectar SSE: ${response.statusCode}');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('text/event-stream')) {
      throw Exception('La respuesta no es SSE válida: $contentType');
    }

    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    String event = 'message';
    String data = '';
    String? id;
    int? retry;

    await for (final line in lines) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          yield SseMessage(
            event: event,
            data: data,
            id: id,
            retry: retry,
          );
        }

        event = 'message';
        data = '';
        id = null;
        retry = null;
        continue;
      }

      if (line.startsWith(':')) {
        continue;
      }

      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
        continue;
      }

      if (line.startsWith('data:')) {
        final value = line.substring(5).trimLeft();
        data = data.isEmpty ? value : '$data\n$value';
        continue;
      }

      if (line.startsWith('id:')) {
        id = line.substring(3).trim();
        continue;
      }

      if (line.startsWith('retry:')) {
        retry = int.tryParse(line.substring(6).trim());
      }
    }
  }

  void close() {
    _client.close();
  }
}