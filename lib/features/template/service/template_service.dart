import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/account_model.dart';
import '../model/assign_task_request.dart';
import '../model/authority_model.dart';
import '../model/template_models.dart';

class TemplateService {
  final DioClient _dio;

  TemplateService(this._dio);

  Future<List<TemplateItem>> fetchTemplates({
    required String userId,
    required String compId,
    required String tabId,
    required String userFixId,
    required String userType,
  }) async {
    final response = await _dio.post(
      "task_list/task_list_templates.php",
      data: {
        "user_id": userId,
        "comp_id": compId,
        "tab_id": tabId,
        "user_fix_id": userFixId,
        "user_type": userType,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => TemplateItem.fromJson(e)).toList();
  }

  /// ---------------- APPROVAL AUTHORITIES ----------------
  Future<List<AuthorityModel>> fetchAuthorities({
    required String userId,
    required String compId,
    required String moduleId,
  }) async {
    final response = await _dio.post(
      "task_list/approval_get_authorities.php",
      data: {
        "user_id": userId,
        "comp_id": compId,
        "module_id": moduleId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => AuthorityModel.fromJson(e)).toList();
  }

  /// ---------------- APPROVE TEMPLATE ----------------
  Future<bool> templateApproval({
    required String itemId,
    required String status,
    required String approvalAuthority,
    required String userId,
    required String compId,
  }) async {
    final response = await _dio.post(
      "task_list/task_list_template_approval.php",
      data: {
        "item_id": itemId,
        "status": status,
        "approval_authority": approvalAuthority,
        "user_id": userId,
        "comp_id": compId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return response.data["status"] == true;
  }


  Future<List<AccountModel>> fetchAccounts({
    required String userFixId,
  }) async {
    final response = await _dio.post(
      "task_list/task_template_permision_auth.php",
      data: {
        "user_fix_id": userFixId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final List data = response.data["data"] ?? [];
    return data.map((e) => AccountModel.fromJson(e)).toList();
  }

  Future<bool> insertTemplate({
    required Map<String, dynamic> body,
  }) async {
    final response = await _dio.post(
      "task_list/task_template_insert.php",
      data: body,
    );

    return response.data["status"] == true;
  }

  Future<Map<String, dynamic>> assignTasks({
    required Map<String, dynamic> body,
  }) async {

    final response = await _dio.post(
      "task_list/task_template_assign.php",
      data: body,
    );

    return response.data;
  }

}
