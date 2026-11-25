/// Alamat server Django. Bawaannya PWS; untuk Django lokal jalankan dengan
/// `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`.
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://alfredo-nathaniel-takarkuy.pws.cs.ui.ac.id',
  );

  /// Alamat lengkap untuk path API, misalnya `/api/planner/plans/`.
  static String url(String path) => '$baseUrl$path';
}
