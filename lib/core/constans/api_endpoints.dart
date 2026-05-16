class ApiEndpoints {
  static const String baseUrl = 'https://api.lumipos.com/v1'; // Ganti dengan URL kamu

  // Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String inventory = '$baseUrl/inventory';
  static const String salesReport = '$baseUrl/reports/sales';
  static const String dashboardStats = '$baseUrl/dashboard/stats';
}
