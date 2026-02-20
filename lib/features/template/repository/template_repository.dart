import 'package:dio/dio.dart';
import 'package:task_manager/core/storage/storage_keys.dart';

import '../../../core/storage/storage_service.dart';
import '../model/account_model.dart';
import '../model/assign_task_request.dart';
import '../model/authority_model.dart';
import '../model/create_template_insert_request.dart';
import '../model/template_models.dart';
import '../service/template_service.dart';

class TemplateRepository {
  final TemplateService service;
  final StorageService storage;

  TemplateRepository(this.service, this.storage);

  Future<List<TemplateItem>> getTemplates({
    required String tabId,
  }) async {
    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";
    final userType = await storage.read(StorageKeys.userType) ?? "";

    return await service.fetchTemplates(
      userId: userId,
      compId: compId,
      userFixId: userId,
      userType: userType,
      tabId: tabId,
    );
  }



  ///  NEW: Fetch Authorities
  Future<List<AuthorityModel>> getAuthorities({
    required String moduleId,
  }) async {
    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";

    return service.fetchAuthorities(
      userId: userId,
      compId: compId,
      moduleId: moduleId,
    );
  }

  Future<bool> templateApproval({
    required String itemId,
    required String status,
    required String authorityId,
  }) async {
    final userId =
        await storage.read(StorageKeys.userId) ?? "";
    final compId =
        await storage.read(StorageKeys.companyId) ?? "";

    return service.templateApproval(
      itemId: itemId,
      status: status,
      approvalAuthority: authorityId,
      userId: userId,
      compId: compId,
    );
  }

  Future<List<AccountModel>> getAccounts() async {
    final userFixId =
        await storage.read(StorageKeys.userFixId) ?? "";

    return service.fetchAccounts(userFixId: userFixId);
  }

  Future<bool> insertTemplate({
    required CreateTemplateRequest request,
  }) async {
    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";

    final body = request.toJson(
      userId: userId,
      compId: compId,
    );

    return service.insertTemplate(body: body);
  }



  Future<Map<String, dynamic>> assignTasks(
      AssignTaskRequest request) async {

    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";

    final body = request.toJson(
      userId: userId,
      compId: compId,
    );

    return await service.assignTasks(body: body);
  }


}

