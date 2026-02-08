class ApiConfig {
  // Change this to your backend URL
  static const String baseUrl = 'http://172.167.50.12:3000';
  // Token refresh threshold (refresh 2 minutes before expiry)
  static const Duration tokenRefreshThreshold = Duration(minutes: 2);

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);
}
