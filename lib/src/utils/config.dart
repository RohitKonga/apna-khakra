class Config {
  // Change this to your backend URL
  // For local development: 'http://localhost:5000'
  // For production: 'https://your-backend-url.com'
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000',
  );
  
  static String get baseUrl => apiUrl;
}

