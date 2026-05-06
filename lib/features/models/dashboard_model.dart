// lib/features/home/models/dashboard_model.dart
class DashboardModel {
  final DashboardSummary summary;
  final List<ParkingSlot> parkingSlots;

  DashboardModel({
    required this.summary,
    required this.parkingSlots,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      summary: DashboardSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      parkingSlots: (json['parking_slots'] as List<dynamic>)
          .map((i) => ParkingSlot.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardSummary {
  final int totalSlots;
  final int availableSlots;
  final int occupiedSlots;

  DashboardSummary({
    required this.totalSlots,
    required this.availableSlots,
    required this.occupiedSlots,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalSlots: (json['total_slots'] as num).toInt(),
      availableSlots: (json['available_slots'] as num).toInt(),
      occupiedSlots: (json['occupied_slots'] as num).toInt(),
    );
  }
}

class ParkingSlot {
  final String id;
  final String name;
  final String state;

  ParkingSlot({
    required this.id,
    required this.name,
    required this.state,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'].toString(),
      name: json['name'] as String,
      state: json['state'] as String,
    );
  }
}