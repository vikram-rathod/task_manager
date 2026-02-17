part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final UserModel? user;
  final bool isProfileLoading;

  final String? profileError;

  const ProfileState({
    this.user,
    this.isProfileLoading = false,
    this.profileError,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isProfileLoading,
    String? profileError,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      profileError: profileError ?? this.profileError,
    );
  }

  @override
  List<Object?> get props => [user, isProfileLoading, profileError];
}
