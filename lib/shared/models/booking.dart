enum BookingStatus {
  created,
  confirmed,
  active,
  completed,
  cancelled,
}

class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.carId,
    required this.carName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.distanceKm,
    this.routeSummary,
  });

  final String id;
  final String userId;
  final String userName;
  final String carId;
  final String carName;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final double totalPrice;
  final double distanceKm;
  final String? routeSummary;

  bool get isUpcoming =>
      status == BookingStatus.created || status == BookingStatus.confirmed;

  bool get isActive => status == BookingStatus.active;

  bool get isHistory =>
      status == BookingStatus.completed || status == BookingStatus.cancelled;

  Booking copyWith({
    String? id,
    String? userId,
    String? userName,
    String? carId,
    String? carName,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    double? totalPrice,
    double? distanceKm,
    String? routeSummary,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      carId: carId ?? this.carId,
      carName: carName ?? this.carName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      distanceKm: distanceKm ?? this.distanceKm,
      routeSummary: routeSummary ?? this.routeSummary,
    );
  }
}
