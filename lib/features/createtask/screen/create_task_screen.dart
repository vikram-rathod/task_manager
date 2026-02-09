import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reusables/searchable_dropdown.dart';
import '../bloc/task_create_bloc.dart';
import '../bloc/taskcreate_event.dart';
import '../bloc/taskcreate_state.dart';
import '../models/attachment_options.dart';

class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateTaskView();
  }
}

class CreateTaskView extends StatefulWidget {
  const CreateTaskView({super.key});

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final _taskDescriptionController = TextEditingController();
  final _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<CreateTaskBloc>().add(LoadProjectList());
  }

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateTaskBloc, CreateTaskState>(
      listener: (context, state) {
        // Handle success
        if (state.taskCreateStatus == TaskCreateStatus.success) {
          _showSuccessSnackbar(context, state.successMessage ?? 'Task created successfully');

          // Reset form after success
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _taskDescriptionController.clear();
              _remarkController.clear();
              context.read<CreateTaskBloc>().add(ResetCreateTaskState());
              Navigator.of(context).pop(true);
            }
          });
        }

        // Handle error
        else if (state.taskCreateStatus == TaskCreateStatus.error && state.errorMessage != null) {
          _showErrorSnackbar(context, state.errorMessage!);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<CreateTaskBloc>().add(ClearError());
            }
          });
        }

        // Handle loading errors (non-submission errors)
        else if (state.errorMessage != null && state.taskCreateStatus != TaskCreateStatus.error) {
          _showErrorSnackbar(context, state.errorMessage!);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.read<CreateTaskBloc>().add(ClearError());
            }
          });
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (state.taskCreateStatus == TaskCreateStatus.loading) {
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              elevation: 0,
              title: const Text('Create New Task'),
              centerTitle: true,
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Selection 
                    SearchableDropdown(
                      label: 'Project',
                      hint: 'Select project',
                      icon: Icons.folder_outlined,
                      items: state.projects,
                      selectedItem: state.selectedProject,
                      itemAsString: (project) => project.projectName,
                      onChanged: (project) {
                        if (project != null) {
                          context.read<CreateTaskBloc>().add(ProjectSelected(project));
                        } else {
                          context.read<CreateTaskBloc>().add(ProjectCleared());
                        }
                      },
                      isEnabled: !state.projectListLoading,
                      isLoading: state.projectListLoading,
                      isRequired: true,
                      validator: (project) {
                        if (project == null) {
                          return 'Please select a project';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Task Description
                    _buildTaskDescriptionField(context, state),

                    const SizedBox(height: 20),

                    // Optional Fields Section
                    _buildSectionHeader(context, 'Optional Details'),

                    const SizedBox(height: 16),

                    // Checker Selection 
                    SearchableDropdown(
                      label: 'Checker',
                      hint: 'Select checker',
                      icon: Icons.person_outline,
                      items: state.checkers,
                      selectedItem: state.selectedChecker,
                      itemAsString: (checker) => checker.userName ?? '',
                      onChanged: (checker) {
                        if (checker != null) {
                          context.read<CreateTaskBloc>().add(CheckerSelected(checker));
                        } else {
                          context.read<CreateTaskBloc>().add(CheckerCleared());
                        }
                      },
                      isEnabled: state.selectedProject != null && !state.checkerListLoading,
                      isLoading: state.checkerListLoading,
                    ),

                    const SizedBox(height: 16),

                    // Maker Selection 
                    SearchableDropdown(
                      label: 'Maker',
                      hint: 'Select maker',
                      icon: Icons.engineering_outlined,
                      items: state.makers,
                      selectedItem: state.selectedMaker,
                      itemAsString: (maker) => maker.userName ?? '',
                      onChanged: (maker) {
                        if (maker != null) {
                          context.read<CreateTaskBloc>().add(MakerSelected(maker));
                        } else {
                          context.read<CreateTaskBloc>().add(MakerCleared());
                        }
                      },
                      isEnabled: state.selectedChecker != null && !state.makerListLoading,
                      isLoading: state.makerListLoading,
                    ),

                    const SizedBox(height: 16),

                    // PC Engineer Selection 
                    SearchableDropdown(
                      label: 'Planner/Coordinator',
                      hint: 'Select coordinator',
                      icon: Icons.manage_accounts_outlined,
                      items: state.pcEngineers,
                      selectedItem: state.selectedPcEngineer,
                      itemAsString: (engineer) => engineer.userName ?? '',
                      onChanged: (engineer) {
                        if (engineer != null) {
                          context.read<CreateTaskBloc>().add(PcEngineerSelected(engineer));
                        } else {
                          context.read<CreateTaskBloc>().add(PcEngineerCleared());
                        }
                      },
                      isEnabled: state.selectedMaker != null && !state.pcEngineerListLoading,
                      isLoading: state.pcEngineerListLoading,
                    ),

                    const SizedBox(height: 16),

                    // Tentative Date
                    _buildDatePicker(context, state),

                    const SizedBox(height: 16),

                    // Remark
                    _buildRemarkField(context, state),

                    const SizedBox(height: 20),

                    // Attachments
                    _buildSectionHeader(context, 'Attachments'),

                    const SizedBox(height: 16),

                    _buildAttachmentsSection(context, state),

                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(context, state),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTaskDescriptionField(BuildContext context, CreateTaskState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Task Description',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _taskDescriptionController,
            decoration: InputDecoration(
              hintText: 'Describe the task in detail...',
              prefixIcon: Icon(Icons.description_outlined,
                  color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            maxLines: 5,
            maxLength: 180,
            onChanged: (value) {
              context.read<CreateTaskBloc>().add(TaskDescriptionChanged(value));
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter task description';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Text(
            '${_taskDescriptionController.text.length}/180 characters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, CreateTaskState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Date',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: state.tentativeDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              context.read<CreateTaskBloc>().add(TentativeDateChanged(date));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    state.tentativeDate != null
                        ? '${state.tentativeDate!.day.toString().padLeft(2, '0')}-${state.tentativeDate!.month.toString().padLeft(2, '0')}-${state.tentativeDate!.year}'
                        : 'Select target date',
                    style: TextStyle(
                      color: state.tentativeDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkField(BuildContext context, CreateTaskState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Remark',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              hintText: 'Add any additional notes...',
              prefixIcon: Icon(Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            maxLines: 3,
            maxLength: 180,
            onChanged: (value) {
              context.read<CreateTaskBloc>().add(RemarkChanged(value));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Text(
            '${_remarkController.text.length}/180 characters',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, CreateTaskState state) {
    if (state.selectedFiles.isEmpty) {
      return InkWell(
        onTap: () => _showAttachmentSourceSheet(context),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              style: BorderStyle.solid,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to add attachments',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload files (optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

    );
    }

    return Column(
      children: [
        ...state.selectedFiles.map((file) {
          final fileName = file.path.split('/').last;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  context.read<CreateTaskBloc>().add(AttachmentRemoved(file));
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _showAttachmentSourceSheet(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add More Files'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }



  void _showAttachmentSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add Attachment',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      AttachmentOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Take a photo',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          context.read<CreateTaskBloc>().add(PickFromCameraRequested());
                        },
                      ),
                      const SizedBox(height: 8),
                      AttachmentOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        subtitle: 'Choose from photos',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          context.read<CreateTaskBloc>().add(PickFromGalleryRequested());
                        },
                      ),
                      const SizedBox(height: 8),
                      AttachmentOption(
                        icon: Icons.insert_drive_file_outlined,
                        title: 'Documents',
                        subtitle: 'Browse files',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.of(bottomSheetContext).pop();
                          context.read<CreateTaskBloc>().add(PickDocumentsRequested());
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }





  Widget _buildSubmitButton(BuildContext context, CreateTaskState state) {
    final isLoading = state.taskCreateStatus == TaskCreateStatus.loading;
    final isSuccess = state.taskCreateStatus == TaskCreateStatus.success;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isLoading && state.isFormValid
            ? [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: isLoading || !state.isFormValid
            ? null
            : () {
          if (_formKey.currentState!.validate()) {
            context.read<CreateTaskBloc>().add(CreateTaskSubmitted());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSuccess
              ? Colors.green
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.add_task,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? 'Task Created' : 'Create Task',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}