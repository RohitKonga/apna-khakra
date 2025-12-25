class Config {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://apna-khakra.onrender.com',
  );

  static String get baseUrl => apiUrl;
}
