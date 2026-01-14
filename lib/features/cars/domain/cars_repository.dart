import '../../../shared/models/car.dart';

abstract class CarsRepository {
  Future<List<Car>> fetchCars();
  Future<Car?> getCarById(String carId);
  Future<void> saveCar(Car car);
  Future<void> deleteCar(String carId);
}
