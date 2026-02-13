import 'package:dio/dio.dart';
import 'package:task_manager/core/storage/storage_keys.dart';

import '../../../core/storage/storage_service.dart';
import '../model/authority_model.dart';
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



  /// 🔥 NEW: Fetch Authorities
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

  Future<bool> approveTemplate({
    required String templateId,
    required String authorityId,
  }) async {
    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";

    return service.approveTemplate(
      userId: userId,
      compId: compId,
      templateId: templateId,
      authorityId: authorityId,
    );
  }
}

