import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/features/template/screen/widget/card_decoration.dart';
import 'package:task_manager/features/template/screen/widget/tab_name.dart';

import '../../../reusables/attachment_bottom_sheet.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';
import '../model/account_model.dart';
import '../model/create_template_insert_request.dart';

class CreateTemplateScreen extends StatefulWidget {
  final String tabId;
  final String tabName;

  const CreateTemplateScreen({
    super.key,
    required this.tabId,
    required this.tabName,
  });

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final TextEditingController titleController = TextEditingController();

  List<CategoryModel> categories = [];

  final Map<CategoryModel, TextEditingController> _categoryControllers = {};
  final Map<TaskModel, TextEditingController> _taskControllers = {};

  int? selectedAuthorityId;
  List<int> selectedAccounts = [];
  final ImagePicker _imagePicker = ImagePicker();

  // =========================================================
  // CONTROLLER HELPERS
  // =========================================================

  TextEditingController _categoryController(CategoryModel category) {
    return _categoryControllers.putIfAbsent(
      category,
          () => TextEditingController(text: category.name),
    );
  }

  TextEditingController _taskController(TaskModel task) {
    return _taskControllers.putIfAbsent(
      task,
          () => TextEditingController(text: task.name),
    );
  }

  void _disposeCategoryController(CategoryModel category) {
    _categoryControllers.remove(category)?.dispose();
    for (final task in category.tasks) {
      _disposeTaskController(task);
    }
  }

  void _disposeTaskController(TaskModel task) {
    _taskControllers.remove(task)?.dispose();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (final c in _categoryControllers.values) c.dispose();
    for (final t in _taskControllers.values) t.dispose();
    super.dispose();
  }

  // =========================================================
  // CATEGORY ACTIONS
  // =========================================================

  void _addCategory() {
    setState(() => categories.add(CategoryModel()));
  }

  void _addCategoryBelow(int index) {
    setState(() => categories.insert(index + 1, CategoryModel()));
  }

  void _removeCategory(int index) {
    _disposeCategoryController(categories[index]);
    setState(() => categories.removeAt(index));
  }

  void _shiftCategoryUp(int index) {
    if (index == 0) return;
    setState(() {
      final item = categories.removeAt(index);
      categories.insert(index - 1, item);
    });
  }

  void _shiftCategoryDown(int index) {
    if (index == categories.length - 1) return;
    setState(() {
      final item = categories.removeAt(index);
      categories.insert(index + 1, item);
    });
  }

  // =========================================================
  // TASK ACTIONS
  // =========================================================

  void _addTask(CategoryModel category) {
    setState(() => category.tasks.add(TaskModel()));
  }

  void _addTaskBelow(CategoryModel category, int taskIndex) {
    setState(() => category.tasks.insert(taskIndex + 1, TaskModel()));
  }

  void _removeTask(CategoryModel category, int taskIndex) {
    _disposeTaskController(category.tasks[taskIndex]);
    setState(() => category.tasks.removeAt(taskIndex));
  }

  void _shiftTaskUp(CategoryModel category, int taskIndex) {
    if (taskIndex == 0) return;
    setState(() {
      final task = category.tasks.removeAt(taskIndex);
      category.tasks.insert(taskIndex - 1, task);
    });
  }

  void _shiftTaskDown(CategoryModel category, int taskIndex) {
    if (taskIndex == category.tasks.length - 1) return;
    setState(() {
      final task = category.tasks.removeAt(taskIndex);
      category.tasks.insert(taskIndex + 1, task);
    });
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<TemplateBloc>();
    bloc.add(FetchAuthorities(moduleId: "33"));
    bloc.add(FetchAccounts());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<TemplateBloc, TemplateState>(
      listenWhen: (previous, current) =>
      previous.insertSuccess != current.insertSuccess,
      listener: (context, state) {
        if (state.insertSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Template created successfully"),
              backgroundColor: Colors.green,
            ),
          );
          context.read<TemplateBloc>().add(LoadTemplates(tabId: widget.tabId));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Create Task Template")),
        body: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabName(scheme,widget.tabName),
                  const SizedBox(height: 20),
                  _buildTitleSection(scheme),
                  const SizedBox(height: 20),
                  _buildCategoriesSection(scheme),
                  const SizedBox(height: 20),
                  _buildAuthoritySection(state, scheme),
                  const SizedBox(height: 20),
                  _buildVisibleAccounts(state, scheme),
                  const SizedBox(height: 30),
                  _buildCreateButton(scheme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // TITLE
  // =========================================================

  Widget _buildTitleSection(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Task List Title",
              style: TextStyle(
                  color: scheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            maxLength: 80,
            decoration: _inputDecoration(hint: "Enter title", scheme: scheme)

          ),
        ],
      ),
    );
  }

  // =========================================================
  // CATEGORIES SECTION
  // =========================================================

  Widget _buildCategoriesSection(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Document Categories",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.primary),
            ),
            _actionButton(
              icon: Icons.add,
              label: "Add Category",
              color: scheme.primary,
              onTap: _addCategory,
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (categories.isEmpty) _emptyCategoryCard(scheme),

        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = categories.removeAt(oldIndex);
              categories.insert(newIndex, item);
            });
          },
          children: List.generate(categories.length, (categoryIndex) {
            return _buildCategoryCard(
              key: ValueKey(categories[categoryIndex]),
              category: categories[categoryIndex],
              categoryIndex: categoryIndex,
              scheme: scheme,
            );
          }),
        ),
      ],
    );
  }

  // =========================================================
  // CATEGORY CARD
  // =========================================================

  Widget _buildCategoryCard({
    required CategoryModel category,
    required int categoryIndex,
    required ColorScheme scheme,
    required Key key,
  }) {
    final isFirst = categoryIndex == 0;
    final isLast = categoryIndex == categories.length - 1;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ---- CATEGORY HEADER ----
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
                Expanded(
                  child: TextField(
                    //  Controller keyed to this CategoryModel object
                    controller: _categoryController(category),
                    onChanged: (val) => category.name = val,
                    decoration: _inputDecoration(
                      hint: "Category name",
                      scheme: scheme,
                    ),


                  ),
                ),
                _iconAction(
                  icon: Icons.add,
                  color: scheme.primary,
                  onTap: () => _addCategoryBelow(categoryIndex),
                  tooltip: "Add Category Below",
                ),
                _iconAction(
                  icon: Icons.keyboard_arrow_up,
                  color: isFirst ? Colors.grey : scheme.primary,
                  onTap: isFirst ? null : () => _shiftCategoryUp(categoryIndex),
                  tooltip: "Move Up",
                ),
                _iconAction(
                  icon: Icons.keyboard_arrow_down,
                  color: isLast ? Colors.grey : scheme.primary,
                  onTap: isLast ? null : () => _shiftCategoryDown(categoryIndex),
                  tooltip: "Move Down",
                ),

                _iconAction(
                  icon: Icons.close,
                  color: Colors.redAccent,
                  onTap: () => _removeCategory(categoryIndex),
                  tooltip: "Delete Category",
                ),
              ],
            ),
          ),

          const Divider(height: 20, indent: 12, endIndent: 12),

          /// ---- TASKS ----
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tasks (${category.tasks.length})",
                      style: TextStyle(
                          fontSize: 13,
                          color: scheme.outline,
                          fontWeight: FontWeight.w500),
                    ),
                    _actionButton(
                      icon: Icons.add,
                      label: "Add Task",
                      color: scheme.primary,
                      onTap: () => _addTask(category),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (category.tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "No tasks added yet.",
                      style: TextStyle(
                          color: scheme.outline.withOpacity(0.5),
                          fontSize: 13),
                    ),
                  ),

                ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final task = category.tasks.removeAt(oldIndex);
                      category.tasks.insert(newIndex, task);
                    });
                  },
                  children: List.generate(category.tasks.length, (taskIndex) {
                    return _buildTaskRow(
                      key: ValueKey(category.tasks[taskIndex]),
                      category: category,
                      task: category.tasks[taskIndex],
                      taskIndex: taskIndex,
                      scheme: scheme,
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TASK ROW
  // =========================================================

  Widget _buildTaskRow({
    required CategoryModel category,
    required TaskModel task,
    required int taskIndex,
    required ColorScheme scheme,
    required Key key,
  }) {
    final isFirst = taskIndex == 0;
    final isLast = taskIndex == category.tasks.length - 1;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  // Controller keyed to this TaskModel object
                  controller: _taskController(task),
                  onChanged: (val) => task.name = val,
                  decoration: _inputDecoration(
                    hint: "Task name",
                    scheme: scheme,
                  ),

                ),
              ),
              _iconAction(
                icon: Icons.attach_file,
                color: scheme.primary,
                onTap: () => _addAttachments(category, taskIndex),
                tooltip: "Add Task Below",
              ),
              _iconAction(
                icon: Icons.add,
                color: scheme.primary,
                onTap: () => _addTaskBelow(category, taskIndex),
                tooltip: "Add Task Below",
              ),
              _iconAction(
                icon: Icons.keyboard_arrow_up,
                color: isFirst ? Colors.grey : scheme.primary,
                onTap: isFirst ? null : () => _shiftTaskUp(category, taskIndex),
                tooltip: "Move Up",
              ),
              _iconAction(
                icon: Icons.keyboard_arrow_down,
                color: isLast ? Colors.grey : scheme.primary,
                onTap: isLast ? null : () => _shiftTaskDown(category, taskIndex),
                tooltip: "Move Down",
              ),

              _iconAction(
                icon: Icons.close,
                color: Colors.redAccent,
                onTap: () => _removeTask(category, taskIndex),
                tooltip: "Delete Task",
              ),
            ],
          ),

          if (task.files.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${task.files.length} attachment(s)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: task.files.length,
                itemBuilder: (context, fileIndex) {
                  final file = task.files[fileIndex];
                  final fileName = file.path.split('/').last;
                  final isImage =
                      fileName.toLowerCase().endsWith('.jpg') ||
                          fileName.toLowerCase().endsWith('.jpeg') ||
                          fileName.toLowerCase().endsWith('.png');

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: scheme.outline.withOpacity(0.2)),
                    ),
                    child: Stack(
                      children: [
                        if (isImage)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.insert_drive_file, color: scheme.outline),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    fileName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ///  Delete button
                        Positioned(
                          top: 2,
                          right: 2,
                          child: InkWell(
                            onTap: () => _removeFile(task, file),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ]
        ],
      ),

    );
  }

  Widget _emptyCategoryCard(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(scheme),
      child: Center(
        child: Text(
          "No categories added yet",
          style: TextStyle(color: scheme.outline.withOpacity(0.5)),
        ),
      ),
    );
  }

  // =========================================================
  // AUTHORITY
  // =========================================================

  Widget _buildAuthoritySection(TemplateState state, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Next Authority Approval",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: selectedAuthorityId,
            hint: const Text("Select Next Authority"),
            items: state.authorities.map((auth) {
              return DropdownMenuItem(
                value: auth.userId,
                child: Text(auth.userName),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedAuthorityId = val),
            decoration: _inputDecoration(hint: "Select Authority", scheme: scheme),

          )
        ],
      ),
    );
  }

  // =========================================================
  // VISIBLE ACCOUNTS
  // =========================================================

  Widget _buildVisibleAccounts(TemplateState state, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Visible To Accounts",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: scheme.primary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: state.accounts.map((account) {
              final selected = selectedAccounts.contains(account.id) ;
              return FilterChip(
                label: Text(account.name),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      selectedAccounts.add(account.id);
                    } else {
                      selectedAccounts.remove(account.id);
                    }
                  });
                },
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // =========================================================
  // CREATE BUTTON
  // =========================================================

  Widget _buildCreateButton(ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          if (selectedAuthorityId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Select approval authority")),
            );
            return;
          }
          if (titleController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Enter template title")),
            );
            return;
          }
          if (categories.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Add at least one category")),
            );
            return;
          }

          // Sync controller text → model before reading
          for (final cat in categories) {
            cat.name = _categoryController(cat).text.trim();
            for (final task in cat.tasks) {
              task.name = _taskController(task).text.trim();
            }
          }

          final categoryRequestList = categories.map((cat) {
            return CategoryInsert(
              categoryId: 0,
              categoryName: cat.name,
              tasks: cat.tasks.map((task) {
              return TaskInsert(
                taskId: 0,
                taskName: task.name,
                files: task.files.map((file) {
                  final bytes = file.readAsBytesSync();
                  return FileInsert(
                    fileName: file.path.split('/').last,
                    fileData: base64Encode(bytes),
                  );
                }).toList(),
              );
            }).toList(),
            );
          }).toList();

          final request = CreateTemplateRequest(
            approvalAuthority: selectedAuthorityId!,
            visibleToAccounts: selectedAccounts.join(","),
            tabId: widget.tabId,
            data: TemplateData(
              itemId: 0,
              itemName: titleController.text.trim(),
              categories: categoryRequestList,
            ),
          );

          context.read<TemplateBloc>().add(InsertTemplate(request: request));
        },
        child: const Text("Create Task List Template"),
      ),
    );
  }

  // =========================================================
  // REUSABLE WIDGETS
  // =========================================================

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
  

  InputDecoration _inputDecoration({
    required String hint,
    required ColorScheme scheme,
  }) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: scheme.outline.withOpacity(0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: scheme.primary,
          width: 1.4,
        ),
      ),
    );
  }

  void _addAttachments(CategoryModel category, int taskIndex) {
    final task = category.tasks[taskIndex];
    AttachmentBottomSheet.show(
      context,
      onCameraPressed: () => _pickFromCamera(task),
      onGalleryPressed: () => _pickFromGallery(task),
      onDocumentsPressed: () => _pickDocuments(task),
    );
  }

  Future<void> _pickFromCamera(TaskModel task) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) setState(() => task.files.add(File(image.path)));
  }

  Future<void> _pickFromGallery(TaskModel task) async {
    final List<XFile> images = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => task.files.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _pickDocuments(TaskModel task) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        task.files.addAll(
          result.files.where((f) => f.path != null).map((f) => File(f.path!)),
        );
      });
    }
  }

  void _removeFile(TaskModel task, File file) {
    setState(() => task.files.remove(file));
  }
  

}