enum ReservationStateEnum {
  pendiente,
  activa,
  completada,
  cancelada;

  static ReservationStateEnum fromString(String value) {
    switch (value) {
      case 'activa':
        return ReservationStateEnum.activa;
      case 'completada':
        return ReservationStateEnum.completada;
      case 'cancelada':
        return ReservationStateEnum.cancelada;
      case 'pendiente':
      default:
        return ReservationStateEnum.pendiente;
    }
  }
}

class ReservationModel {
  final String id;
  final String userId;
  final String placeId;
  final String place;
  final String? carId;
  final String car;
  final int? code;
  final DateTime timeStart;
  final DateTime timeEnd;
  final ReservationStateEnum state;

  const ReservationModel({
    required this.id,
    required this.userId,
    required this.placeId,
    required this.place,
    required this.carId,
    required this.car,
    required this.code,
    required this.timeStart,
    required this.timeEnd,
    required this.state,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      placeId: json['placeId']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
      carId: json['carId']?.toString(),
      car: json['car']?.toString() ?? '',
      code: json['code'] == null
          ? null
          : (json['code'] is int
          ? json['code']
          : int.tryParse(json['code'].toString())),
      timeStart: DateTime.parse(json['timeStart']),
      timeEnd: DateTime.parse(json['timeEnd']),
      state: ReservationStateEnum.fromString(json['state'] ?? 'pendiente'),
    );
  }
}