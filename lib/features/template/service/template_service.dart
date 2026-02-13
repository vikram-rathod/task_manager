import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
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
  Future<bool> approveTemplate({
    required String userId,
    required String compId,
    required String templateId,
    required String authorityId,
  }) async {
    final response = await _dio.post(
      "task_list/template_approve.php",
      data: {
        "user_id": userId,
        "comp_id": compId,
        "template_id": templateId,
        "authority_id": authorityId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return response.data['status'] == true;
  }
}
