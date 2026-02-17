import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/storage/storage_keys.dart';

import '../../../core/storage/storage_service.dart';
import '../../auth/models/user_model.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final StorageService _storageService;

  ProfileBloc(this._storageService,) : super(const ProfileState()) {

    on<LoadProfile>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(isProfileLoading: true));

    try {
      final userId = await _storageService.read(StorageKeys.userId);
      final userType = await _storageService.read(StorageKeys.userType);
      final companyId = await _storageService.read(StorageKeys.companyId);
      final refCandidateId =
      await _storageService.read(StorageKeys.refCandidateId);
      final userFixId = await _storageService.read(StorageKeys.userFixId);
      final userAccAutoCreate =
      await _storageService.read(StorageKeys.userAccAutoCreate);

      final user = UserModel(
        userName:
        await _storageService.read(StorageKeys.userName) ?? '',
        userId: int.tryParse(userId ?? '') ?? 0,
        userType: int.tryParse(userType ?? '') ?? 0,
        userTypeName:
        await _storageService.read(StorageKeys.userTypeName) ?? '',
        companyId: int.tryParse(companyId ?? '') ?? 0,
        companyName:
        await _storageService.read(StorageKeys.companyName) ?? '',
        companyType:
        await _storageService.read(StorageKeys.companyType) ?? '',
        companyLogoUrl:
        await _storageService.read(StorageKeys.companyLogoUrl) ?? '',
        userProfileUrl:
        await _storageService.read(StorageKeys.userProfileUrl) ?? '',
        profileType:
        await _storageService.read(StorageKeys.profileType) ?? '',
        userMobileNumber:
        await _storageService.read(StorageKeys.userMobile) ?? '',
        userEmail:
        await _storageService.read(StorageKeys.userEmail) ?? '',
        designation:
        await _storageService.read(StorageKeys.designation) ?? '',
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
