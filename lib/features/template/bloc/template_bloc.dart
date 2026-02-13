import 'package:bloc/bloc.dart';
import 'package:task_manager/features/template/bloc/template_event.dart';
import 'package:task_manager/features/template/bloc/template_state.dart';

import '../repository/template_repository.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository repository;

  TemplateBloc(this.repository) : super(TemplateState()) {
    on<LoadTemplates>(_onLoadTemplates);

    /// 🔥 FETCH AUTHORITIES
    on<FetchAuthorities>((event, emit) async {
      emit(state.copyWith(isAuthorityLoading: true));

      final list =
      await repository.getAuthorities(moduleId: event.moduleId);

      emit(state.copyWith(
        isAuthorityLoading: false,
        authorities: list,
      ));
    });

    /// 🔥 APPROVE TEMPLATE
    on<ApproveTemplate>((event, emit) async {
      final success = await repository.approveTemplate(
        templateId: event.templateId,
        authorityId: event.authorityId,
      );

      emit(state.copyWith(approveSuccess: success));
    });
  }

  Future<void> _onLoadTemplates(
      LoadTemplates event,
      Emitter<TemplateState> emit,
      ) async {
    print("🔥 LoadTemplates triggered");
    emit(state.copyWith(isLoading: true));

    try {
      final templates =
      await repository.getTemplates(tabId: event.tabId);
      print("🔥 Template count: ${templates.length}");

      emit(state.copyWith(
        isLoading: false,
        templates: templates,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
