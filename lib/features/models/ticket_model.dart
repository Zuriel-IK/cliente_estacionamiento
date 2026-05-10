enum TicketStateEnum {
  activo,
  pendiente_pago,
  pagado,
  finalizado,
  desconocido;

  static TicketStateEnum fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'activo':
        return TicketStateEnum.activo;
      case 'pendiente_pago':
        return TicketStateEnum.pendiente_pago;
      case 'pagado':
        return TicketStateEnum.pagado;
      case 'finalizado':
        return TicketStateEnum.finalizado;
      default:
        return TicketStateEnum.desconocido;
    }
  }
}

class TicketModel {
  final String id;
  final String userId;
  final String reservation;
  final String? placeId;
  final String place;
  final String? carId;
  final String car;
  final DateTime? timeStart;
  final DateTime? timeEnd;
  final TicketStateEnum state;
  final int? code;
  final num? baseFee;
  final num? finalFee;
  final String? discountType;
  final dynamic validationIn;
  final dynamic validationOut;
  final String folio;

  const TicketModel({
    required this.id,
    required this.userId,
    required this.reservation,
    required this.placeId,
    required this.place,
    required this.carId,
    required this.car,
    required this.timeStart,
    required this.timeEnd,
    required this.state,
    required this.code,
    required this.baseFee,
    required this.finalFee,
    required this.discountType,
    required this.validationIn,
    required this.validationOut,
    required this.folio,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'no definido') return null;
      return DateTime.tryParse(text);
    }

    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return TicketModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      reservation: json['reservation']?.toString() ?? 'no fue reservado',
      placeId: json['placeId']?.toString(),
      place: json['place']?.toString() ?? 'Sin lugar',
      carId: json['carId']?.toString(),
      car: json['car']?.toString() ?? 'Sin carro',
      timeStart: parseDate(json['timeStart']),
      timeEnd: parseDate(json['timeEnd']),
      state: TicketStateEnum.fromString(json['state']?.toString()),
      code: parseInt(json['code']),
      baseFee: parseNum(json['baseFee']),
      finalFee: parseNum(json['finalFee']),
      discountType: json['discountType']?.toString(),
      validationIn: json['validationIn'],
      validationOut: json['validationOut'],
      folio: json['folio']?.toString() ?? '',
    );
  }
}