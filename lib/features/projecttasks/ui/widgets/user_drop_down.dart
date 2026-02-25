import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../reusables/searchable_dropdown.dart';
import '../../../auth/models/user_model.dart';
import '../../bloc/project_wise_task_bloc.dart';
import '../../bloc/project_wise_task_event.dart';
import '../../bloc/project_wise_task_state.dart';

class UserDropdownSection extends StatelessWidget {
  final ProjectWiseTaskState state;

  const UserDropdownSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // Maker dropdown
          if (state.selectedRole == UserRoleType.maker)
            UserDropdown(
              label: 'Select Maker',
              placeholder: 'Search makers...',
              userStatus: state.checkerMakerUserStatus,
              selectedUser: state.selectedMaker,
              onUserSelected: (user) {
                context.read<ProjectWiseTaskBloc>().add(
                  MakerUserSelected(user),
                );
              },
            ),

          // Checker dropdown
          if (state.selectedRole == UserRoleType.checker)
            UserDropdown(
              label: 'Select Checker',
              placeholder: 'Search checkers...',
              userStatus: state.checkerMakerUserStatus,
              selectedUser: state.selectedChecker,
              onUserSelected: (user) {
                context.read<ProjectWiseTaskBloc>().add(
                  CheckerUserSelected(user),
                );
              },
            ),

          // Planner/Coordinator dropdown
          if (state.selectedRole == UserRoleType.pcEngineer)
            UserDropdown(
              label: 'Select Planner/Coordinator',
              placeholder: 'Search planner/coordinator...',
              userStatus: state.pcEngineerUserStatus,
              selectedUser: state.selectedPcEngineer,
              onUserSelected: (user) {
                context.read<ProjectWiseTaskBloc>().add(
                  PcEngineerSelected(user),
                );
              },
            ),
        ],
      ),
    );
  }
}

class UserDropdown extends StatelessWidget {
  final String label;
  final String placeholder;
  final UserListStatus userStatus;
  final UserModel? selectedUser;
  final ValueChanged<UserModel> onUserSelected;

  const UserDropdown({
    required this.label,
    required this.placeholder,
    required this.userStatus,
    required this.selectedUser,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    final users = userStatus is UserListSuccess
        ? (userStatus as UserListSuccess).users
        : <UserModel>[];
    final isError = userStatus is UserListError;
    final isLoading = userStatus is UserListLoading;

    final supportingText = isError
        ? (userStatus as UserListError).message
        : isLoading
        ? 'Loading...'
        : "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SearchableDropdown(
        label: label,
        hint: placeholder,
        items: users,
        selectedItem: selectedUser,
        itemAsString: (user) => user.userName ?? '',
        onChanged: (user) {
          if (user != null) onUserSelected(user);
        },
        isEnabled: !isLoading,
        isLoading: isLoading,
        icon: Icons.search,
        supportingText: supportingText ,
      ),
    );
  }
}