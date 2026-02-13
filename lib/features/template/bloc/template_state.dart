import '../model/authority_model.dart';
import '../model/template_models.dart';

class TemplateState {
  final bool isLoading;
  final List<TemplateItem> templates;
  final String? error;

  final bool isAuthorityLoading;
  final List<AuthorityModel> authorities;
  final bool approveSuccess;

  TemplateState({
    this.isLoading = false,
    this.templates = const [],
    this.error,

    this.isAuthorityLoading = false,
    this.authorities = const [],
    this.approveSuccess = false,
  });

  TemplateState copyWith({
    bool? isLoading,
    List<TemplateItem>? templates,
    String? error,

    bool? isAuthorityLoading,
    List<AuthorityModel>? authorities,
    bool? approveSuccess,
  }) {
    return TemplateState(
      isLoading: isLoading ?? this.isLoading,
      templates: templates ?? this.templates,
      error: error,

      isAuthorityLoading:
      isAuthorityLoading ?? this.isAuthorityLoading,
      authorities: authorities ?? this.authorities,
      approveSuccess: approveSuccess ?? this.approveSuccess,
    );
  }
}
