class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://bcstep.com/bcsteperp/bcstep_apis/task_manager/';

 // Auth Endpoints
  static const String login = '${baseUrl}v1/login.php';
  static const String logout = '${baseUrl}v1/logout.php';


  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}