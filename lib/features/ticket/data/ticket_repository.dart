import 'package:cliente_estacionamiento/features/models/ticket_model.dart';
import 'package:dio/dio.dart';

class TicketRepository {
  final Dio dio;

  TicketRepository(this.dio);

  Future<List<TicketModel>> getTickets({
    required String userId,
  }) async {
    final response = await dio.get('/api/ticket/$userId');
    final data = response.data;

    if (data == null) return [];

    if (data is List) {
      return data
          .map((e) => TicketModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final possibleLists = [
        data['tickets'],
        data['data'],
        data['items'],
      ];

      for (final value in possibleLists) {
        if (value is List) {
          return value
              .map((e) => TicketModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
    }

    return [];
  }

  Future<num> calculateFinalFee({
    required int code,
  }) async {
    final response = await dio.post(
      '/api/ticket/calculate',
      data: {
        'code': code,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final dynamic finalFee = data['finalFee'] ?? data['data']?['finalFee'];

      if (finalFee is num) return finalFee;

      final parsed = num.tryParse(finalFee.toString());
      if (parsed != null) return parsed;
    }

    throw Exception('No se pudo calcular el monto final');
  }

  Future<void> confirmTicketPayment({
    required int code,
  }) async {
    await dio.post(
      '/api/ticket/pay',
      data: {
        'code': code,
        'payIsValid': true,
      },
    );
  }
}