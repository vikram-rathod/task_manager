abstract class TemplateEvent {}

class LoadTemplates extends TemplateEvent {
  final String tabId;

  LoadTemplates({required this.tabId});
}

class FetchAuthorities extends TemplateEvent {
  final String moduleId;
  FetchAuthorities({required this.moduleId});
}

/// 🔥 NEW
class ApproveTemplate extends TemplateEvent {
  final String templateId;
  final String authorityId;

  ApproveTemplate({
    required this.templateId,
    required this.authorityId,
  });
}