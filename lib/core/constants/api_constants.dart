class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl = 'https://bcstep.com/bcsteperp/bcstep_apis/task_manager/';
  static const String bcStepUrl = 'https://bcstep.com/bcsteperp/bcstep_apis/';

  // Auth Endpoints
  static const String login = '${baseUrl}v1/login.php';
  static const String logout = '${baseUrl}v1/logout.php';
  static const String sessionCheck = '${baseUrl}v1/tm_session.php';
  static const String requestOtp = '${bcStepUrl}get_otp_for_email_mob.php';
  static const String verifyOtp = '${bcStepUrl}get_otp_for_email_mob.php';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
