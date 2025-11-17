class Config {
  // Backend API URL
  // For local development: 'http://localhost:5000'
  // For production: Set via --dart-define=API_URL=... during build
  // GitHub Actions automatically uses the API_URL secret
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:5000', // Default for local development
  );
  
  static String get baseUrl => apiUrl;
  
  // Production API URL - Update this with your Render backend URL
  // Example: 'https://apna-khakra-backend.onrender.com'
  // Note: This is just for reference. Actual URL comes from API_URL environment variable
  static const String productionApiUrl = 'https://your-render-backend-url.onrender.com';
}

