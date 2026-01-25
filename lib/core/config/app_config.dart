import 'app_runtime_config.dart';

class AppConfig {
  const AppConfig._();

  static const appName = 'Car Rental GPS';
  static final runtime = AppRuntimeConfig.fromEnvironment();
  static const coordinateRefreshSeconds = 3;
  static const apiTimeoutSeconds = 15;
}
