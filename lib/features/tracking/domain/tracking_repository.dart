import '../../../shared/models/tracking_snapshot.dart';

abstract class TrackingRepository {
  Stream<TrackingSnapshot> watchCar(String carId);
}
