import 'package:cliente_estacionamiento/features/models/reservation_model.dart';
import 'package:dio/dio.dart';

class ReservationRepository {
  final Dio dio;

  ReservationRepository(this.dio);

  Future<List<ReservationModel>> getReservations({
    required String userId,
  }) async {
    final response = await dio.get('/api/reservation/$userId');
    final data = response.data;
    if (data == null) {
      return [];
    }

    if (data is List) {
      return data
          .map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final possibleLists = [
        data['reservations'],
        data['reservation'],
        data['data'],
        data['items'],
      ];

      for (final value in possibleLists) {
        if (value is List) {
          return value
              .map((e) => ReservationModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      if (data.containsKey('_id')) {
        return [ReservationModel.fromJson(data)];
      }
    }

    return [];
  }

  Future<ReservationModel> createReservation({
    required String userId,
    required String placeId,
    required int time,
  }) async {

    final response = await dio.post(
      '/api/reservation',
      data: {
        'userId': userId,
        'placeId': placeId,
        'carId': null,
        'time': time,
      },
    );
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('_id')) {
        return ReservationModel.fromJson(data);
      }

      final reservation = data['reservation'];
      if (reservation is Map<String, dynamic>) {
        return ReservationModel.fromJson(
          Map<String, dynamic>.from(reservation),
        );
      }
    }

    throw Exception('Respuesta inválida al crear la reserva');
  }

  Future<void> deleteReservation({
    required String reservationId,
  }) async {
    await dio.delete('/api/reservation/$reservationId');
  }

  Future<int> getReservationCode({
    required String reservationId,
  }) async {
    final response = await dio.get('/api/reservation/$reservationId/code');
    final data = response.data;

    if (data is int) {
      return data;
    }

    if (data is String) {
      return int.parse(data);
    }

    if (data is Map<String, dynamic>) {
      final code = data['code'];

      if (code is int) {
        return code;
      }

      if (code != null) {
        return int.parse(code.toString());
      }
    }

    throw Exception('No se pudo obtener el código');
  }
}