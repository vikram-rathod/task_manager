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
class TemplateApprovalEvent extends TemplateEvent {
  final String itemId;
  final String status; // 0,1,2
  final String authorityId;

  TemplateApprovalEvent({
    required this.itemId,
    required this.status,
    required this.authorityId,
  });
}
