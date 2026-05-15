class ApiConstants {
  const ApiConstants._();

  static const String defaultBaseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );
  static const bool backendEnabled = bool.fromEnvironment('USE_BACKEND');

  static const String health = '/health';
  static const String books = '/api/books';
}
