import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class SseClientService {
  final String baseUrl;

  SseClientService({required this.baseUrl});

  Stream<String> connect({
    required String path,
    Map<String, String>? headers,
  }) {
    final stream = SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: '$baseUrl$path',
      header: headers ?? const {},
    );

    return stream.map((event) => event.data ?? '');
  }
}