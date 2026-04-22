class CarReview {
  const CarReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.carId,
    required this.carName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String carId;
  final String carName;
  final int rating;
  final String comment;
  final DateTime createdAt;
}
