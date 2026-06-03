/// Constantes globais da aplicação GymConnect.
class AppConstants {
  AppConstants._();

  /// URL base do backend Java (Spring Boot).
  ///
  /// - Emulador Android: `http://10.0.2.2:8080` (10.0.2.2 = localhost do host).
  /// - Dispositivo físico: troque pelo IP da máquina, ex.: `http://192.168.0.10:8080`.
  /// - Pode ser sobrescrito em tempo de build com:
  ///   `flutter run --dart-define=API_BASE_URL=http://SEU_IP:8080`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  // Chaves de persistência (SharedPreferences)
  static const String tokenKey = 'gc_token';
  static const String userKey = 'gc_user';
  static const String themeKey = 'gc_theme_mode';

  // Timeouts do Dio
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String appName = 'GymConnect';
}
