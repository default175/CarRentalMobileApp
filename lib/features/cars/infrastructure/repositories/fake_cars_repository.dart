import '../../../../shared/demo/demo_data_store.dart';
import '../../../../shared/models/car.dart';
import '../../domain/cars_repository.dart';

class FakeCarsRepository implements CarsRepository {
  FakeCarsRepository(this._store);

  final DemoDataStore _store;

  @override
  Future<List<Car>> fetchCars() async {
    return _store.cars;
  }

  @override
  Future<Car?> getCarById(String carId) async {
    return _store.findCarById(carId);
  }

  @override
  Future<void> saveCar(Car car) async {
    _store.saveCar(car);
  }

  @override
  Future<void> deleteCar(String carId) async {
    _store.deleteCar(carId);
  }
}
