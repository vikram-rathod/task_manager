import 'package:bloc/bloc.dart';
import 'package:task_manager/features/template/bloc/template_event.dart';
import 'package:task_manager/features/template/bloc/template_state.dart';

import '../repository/template_repository.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository repository;
  String currentTabId = "";
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
    on<TemplateApprovalEvent>((event, emit) async {
      final success = await repository.templateApproval(
        itemId: event.itemId,
        status: event.status,
        authorityId: event.authorityId,
      );

      if (success) {
        emit(state.copyWith(approveSuccess: true));

        // refresh templates automatically
        add(LoadTemplates(tabId: currentTabId));
      }
    });


    on<FetchAccounts>(_fetchAccounts);


    on<InsertTemplate>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final success =
        await repository.insertTemplate(request: event.request);

        if (success) {
          emit(state.copyWith(
            isLoading: false,
            approveSuccess: true,
            insertSuccess: true,
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            error: "Template creation failed",
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    });

    on<AssignTasks>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      try {
        final response = await repository.assignTasks(event.request);

        if (response["status"] == true) {
          emit(state.copyWith(
            isLoading: false,
            assignSuccess: true,
            message: response["message"],
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            assignSuccess: false,
            message: response["message"],
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          assignSuccess: false,
          message: "Something went wrong",
        ));
      }
    });


  }

  Future<void> _onLoadTemplates(
      LoadTemplates event,
      Emitter<TemplateState> emit,
      ) async {
    currentTabId = event.tabId;
    emit(state.copyWith(isLoading: true));

    try {
      final templates =
      await repository.getTemplates(tabId: event.tabId);

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

  Future<void> _fetchAccounts(
      FetchAccounts event,
      Emitter<TemplateState> emit,
      ) async {
    emit(state.copyWith(isAccountsLoading: true));

    final accounts = await repository.getAccounts();

    emit(state.copyWith(
      isAccountsLoading: false,
      accounts: accounts,
    ));
  }

}
