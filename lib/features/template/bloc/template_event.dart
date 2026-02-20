import 'dart:io';

import 'package:equatable/equatable.dart';

import '../model/assign_task_request.dart';
import '../model/create_template_insert_request.dart';

class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class LoadTemplates extends TemplateEvent {
  final String tabId;

  LoadTemplates({required this.tabId});
}

class FetchAuthorities extends TemplateEvent {
  final String moduleId;
  FetchAuthorities({required this.moduleId});
}

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
class FetchAccounts extends TemplateEvent {}

class InsertTemplate extends TemplateEvent {
  final CreateTemplateRequest request;

  InsertTemplate({required this.request});
}

class AssignTasks extends TemplateEvent {
  final AssignTaskRequest request;

  AssignTasks({required this.request});
}


