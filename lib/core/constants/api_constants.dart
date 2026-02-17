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

  /*
  * ───────────────── Home API Endpoints ─────────────────
  */

  static const String getProjectsList = '${baseUrl}list_projects.php';

  static const String userList = '${baseUrl}checker_maker_list.php';

  static const String pcEnggUserList = '${baseUrl}list_pc_engg_users.php';

  static String getProjectsCountList = '${baseUrl}dashboard_project_wise.php';
  static String getEmployeeWiseTaskList =
      '${baseUrl}dashboard_employee_wise.php';
  static const String taskHistory = '${baseUrl}dashboard_history.php';
  static const String tmDashboardCount = '${baseUrl}tm_dashboard_count.php';
  static const String todaysTask = '${baseUrl}todays_task.php';

  static const String listOfUsers = '${baseUrl}list_all_users.php';



  /* ───────────────── Task API Endpoints ───────────────── */

  // Task CRUD
  static const String insertNewTask = '${baseUrl}insert_new_task.php';
  static const String taskList = '${baseUrl}task_list.php';
  static const String taskDetails = '${baseUrl}get_task_details.php';

  // Task Chat
  static const String getTaskChat = '${baseUrl}get_task_chat.php';
  static const String insertTaskChat = '${baseUrl}insert_chat.php';

  // Task manager approval
  static const String taskManagerApproval = '${baseUrl}task_manager_approval.php';
  static const String taskManagerAcknowdge = '${baseUrl}task_manager_acknowledge_v1.php';

  //ProChat
  static const String prochatTaskList = '${baseUrl}prochat_task_list.php';
  static const String prochatTaskTransfer = '${baseUrl}transfer_prochat_task.php';
  static const String prochatTaskInsert = '${baseUrl}prochat_task_insert.php';




  // Task list filters
  static const String taskListByUserId =
      '${baseUrl}task_list_by_user_id.php';
  static const String taskListByProjectId =
      '${baseUrl}task_list_by_project_id.php';
  static const String employeeWiseTaskList =
      '${baseUrl}getUserPendingTasks.php';

  // Task status based
  static const String taskListOverDue =
      '${baseUrl}task_list_over_due.php';
  static const String taskListDueToday =
      '${baseUrl}task_list_due_today.php';

  /* ───────────────── Task Template APIs ───────────────── */

  static const String taskListBase = '${baseUrl}task_list';

  static const String taskListTemplate =
      '$taskListBase/task_list_templates.php';
  static const String taskListTemplateInsert =
      '$taskListBase/task_template_insert.php';
  static const String taskListTemplatePermission =
      '$taskListBase/task_template_permision_auth.php';
  static const String approvalGetAuthorities =
      '$taskListBase/approval_get_authorities.php';
  static const String taskTransfer =
      '$taskListBase/task_transfer.php';
  static const String taskListOnProject =
      '$taskListBase/task_list_on_project.php';
  static const String taskTemplateAssign =
      '$taskListBase/task_template_assign.php';
  static const String taskListTemplateApproval =
      '$taskListBase/task_list_template_approval.php';


  // Module Notification
  static const String moduleNotificationList = '${baseUrl}task_manager_acknowledge_v1.php';
  static const String moduleNotificationInsert = '${baseUrl}task_manager_approval.php';




  /* ───────────────── Timeouts ───────────────── */
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}