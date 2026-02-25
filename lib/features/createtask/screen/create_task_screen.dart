import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/file_preview_screen.dart';
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
  CreateTaskBloc? _bloc;
  final _taskDescriptionController = TextEditingController();
  final _remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<CreateTaskBloc>().add(LoadProjectList());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<CreateTaskBloc>();
  }

  @override
  void dispose() {
    _taskDescriptionController.dispose();
    _remarkController.dispose();
    _bloc?.add(ResetCreateTaskState());
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
              _bloc?.add(ResetCreateTaskState());
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

                    // Planner/Coordinator Selection 
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
    final scheme = Theme.of(context).colorScheme;

    if (state.selectedFiles.isEmpty) {
      return InkWell(
        onTap: () => _showAttachmentSourceSheet(context),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outline.withOpacity(0.4),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 56,
                color: scheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to add attachments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Supported: images, PDFs, docs, etc. (optional)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...state.selectedFiles.map((file) {
          final fileName = file.path.split('/').last;
          final extension = fileName.split('.').last.toLowerCase();
          final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outline.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              // ── Leading: Image preview or file icon ──
              leading: isImage
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: scheme.surfaceVariant,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: scheme.onSurfaceVariant,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
              )
                  : Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getFileIcon(extension),
                  color: scheme.primary,
                  size: 28,
                ),
              ),

              // Title & subtitle
              title: Text(
                fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB • $extension',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),

              // Remove button
              trailing: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: scheme.error,
                ),
                onPressed: () {
                  context.read<CreateTaskBloc>().add(AttachmentRemoved(file));
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FilePreviewScreen.fromFile(
                      file: file,
                      fileName: fileName,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),

        const SizedBox(height: 16),

        OutlinedButton.icon(
          onPressed: () => _showAttachmentSourceSheet(context),
          icon: Icon(Icons.add_rounded, color: scheme.primary),
          label: Text(
            'Add More Attachments',
            style: TextStyle(color: scheme.primary),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.outline),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
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
          disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        // action: SnackBarAction(
        //   label: 'DISMISS',
        //   textColor: Colors.white,
        //   onPressed: () {
        //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
        //   },
        // ),
      ),
    );
  }
}