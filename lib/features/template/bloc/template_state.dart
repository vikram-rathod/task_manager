import '../model/account_model.dart';
import '../model/authority_model.dart';
import '../model/template_models.dart';

class TemplateState {
  final bool isLoading;
  final List<TemplateItem> templates;
  final String? error;

  final bool isAuthorityLoading;
  final List<AuthorityModel> authorities;
  final bool approveSuccess;

  final bool isAccountsLoading;
  final List<AccountModel> accounts;
  final bool insertSuccess;


  TemplateState({
    this.isLoading = false,
    this.templates = const [],
    this.error,

    this.isAuthorityLoading = false,
    this.authorities = const [],
    this.approveSuccess = false,

    this.isAccountsLoading = false,
    this.accounts = const [],
    this.insertSuccess = false,
  });

  TemplateState copyWith({
    bool? isLoading,
    List<TemplateItem>? templates,
    String? error,

    bool? isAuthorityLoading,
    List<AuthorityModel>? authorities,
    bool? approveSuccess,

    bool? isAccountsLoading,
    List<AccountModel>? accounts,

    bool? insertSuccess,
  }) {
    return TemplateState(
      isLoading: isLoading ?? this.isLoading,
      templates: templates ?? this.templates,
      error: error,

      isAuthorityLoading:
      isAuthorityLoading ?? this.isAuthorityLoading,
      authorities: authorities ?? this.authorities,
      approveSuccess: approveSuccess ?? this.approveSuccess,

      isAccountsLoading: isAccountsLoading ?? this.isAccountsLoading,
      accounts: accounts ?? this.accounts,
      insertSuccess: insertSuccess ?? false,
    );
  }
}
