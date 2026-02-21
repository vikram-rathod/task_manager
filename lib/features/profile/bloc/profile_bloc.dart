import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/storage/storage_keys.dart';

import '../../../core/storage/storage_service.dart';
import '../../auth/models/user_model.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StorageService storageService;

  ProfileBloc(this.storageService,) : super(const ProfileState()) {

    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isProfileLoading: true));

    try {
      final userId = await storageService.read(StorageKeys.userId);
      final userType = await storageService.read(StorageKeys.userType);
      final companyId = await storageService.read(StorageKeys.companyId);
      final refCandidateId =
      await storageService.read(StorageKeys.refCandidateId);
      final userFixId = await storageService.read(StorageKeys.userFixId);
      final userAccAutoCreate =
      await storageService.read(StorageKeys.userAccAutoCreate);

      final user = UserModel(
        userName:
        await storageService.read(StorageKeys.userDisplayName) ?? '',
        userId: int.tryParse(userId ?? '') ?? 0,
        userType: int.tryParse(userType ?? '') ?? 0,
        userTypeName:
        await storageService.read(StorageKeys.userTypeName) ?? '',
        companyId: int.tryParse(companyId ?? '') ?? 0,
        companyName:
        await storageService.read(StorageKeys.companyName) ?? '',
        companyType:
        await storageService.read(StorageKeys.companyType) ?? '',
        companyLogoUrl:
        await storageService.read(StorageKeys.companyLogoUrl) ?? '',
        userProfileUrl:
        await storageService.read(StorageKeys.userProfileUrl) ?? '',
        profileType:
        await storageService.read(StorageKeys.profileType) ?? '',
        userMobileNumber:
        await storageService.read(StorageKeys.userMobile) ?? '',
        userEmail:
        await storageService.read(StorageKeys.userEmail) ?? '',
        designation:
        await storageService.read(StorageKeys.designation) ?? '',
        userAccAutoCreate:
        userAccAutoCreate == "true",
        refCandidateId:
        int.tryParse(refCandidateId ?? '') ?? 0,
        userFixId:
        int.tryParse(userFixId ?? '') ?? 0,
        userPassword: '',
        loginSessionId: '',
      );

      emit(state.copyWith(
        user: user,
        isProfileLoading: false,
        profileError: "",
      ));
    } catch (e) {
      emit(state.copyWith(
        isProfileLoading: false,
        profileError: e.toString(),
      ));
    }
  }



}
