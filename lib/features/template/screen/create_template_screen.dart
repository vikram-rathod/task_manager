import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';
import '../model/account_model.dart';
import '../model/create_template_insert_request.dart';

class CreateTemplateScreen extends StatefulWidget {
  final String tabId;

  const CreateTemplateScreen({
    super.key,
    required this.tabId,
  });

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}


class _CreateTemplateScreenState extends State<CreateTemplateScreen> {

  final TextEditingController titleController = TextEditingController();

  List<CategoryModel> categories = [];

  int? selectedAuthorityId;
  List<int> selectedAccounts = [];


  void removeCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
  }


  @override
  void initState() {
    super.initState();


    final bloc = context.read<TemplateBloc>();

    bloc.add(FetchAuthorities(moduleId: "33"));
    bloc.add(FetchAccounts());   // create this event
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

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

            // 🔥 Reload list
            context.read<TemplateBloc>()
                .add(LoadTemplates(tabId: widget.tabId));

            // 🔥 Navigate back to list
            Navigator.pop(context);
          }
        },
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Create Task Template"),
      ),
      body: BlocBuilder<TemplateBloc, TemplateState>(
        builder: (context, state) {

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// ---------------- TITLE ----------------
                _buildTitleSection(primary),

                const SizedBox(height: 20),

                /// ---------------- DOCUMENT CATEGORIES ----------------
                _buildCategoriesSection(primary),

                const SizedBox(height: 20),

                /// ---------------- AUTHORITY ----------------
                _buildAuthoritySection(state, primary),

                const SizedBox(height: 20),

                /// ---------------- VISIBLE ACCOUNTS ----------------
                _buildVisibleAccounts(state, primary),

                const SizedBox(height: 30),

                /// ---------------- CREATE BUTTON ----------------
                _buildCreateButton(primary),
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

  Widget _buildTitleSection(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Task List Title",
              style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          TextField(
            controller: titleController,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: "Enter title",
              counterText: "",
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CATEGORIES
  // =========================================================

  Widget _buildCategoriesSection(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Document Categories",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primary)),
            IconButton(
              onPressed: () {
                setState(() {
                  categories.add(CategoryModel());
                });
              },
              icon: const Icon(Icons.add),
            )
          ],
        ),

        const SizedBox(height: 10),

        if (categories.isEmpty)
          _emptyCategoryCard(),

        ...categories.map((category) => _buildCategoryCard(category)).toList(),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          TextField(
            decoration: const InputDecoration(
              hintText: "Category name",
            ),
            onChanged: (val) => category.name = val,
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tasks (${category.tasks.length})"),
              TextButton(
                onPressed: () {
                  setState(() {
                    category.tasks.add(TaskModel());
                  });
                },
                child: const Text("+ Add Task"),
              )
            ],
          ),

          const SizedBox(height: 10),

          if (category.tasks.isEmpty)
            const Text("No tasks added yet."),

          ...category.tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Task name",
                ),
                onChanged: (val) => task.name = val,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _emptyCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Center(
        child: Text("No categories added yet"),
      ),
    );
  }

  // =========================================================
  // AUTHORITY
  // =========================================================

  Widget _buildAuthoritySection(TemplateState state, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Next Authority Approval",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primary)),

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
            onChanged: (val) {
              setState(() {
                selectedAuthorityId = val;
              });
            },
          )
        ],
      ),
    );
  }

  // =========================================================
  // MULTI SELECT ACCOUNTS
  // =========================================================

  Widget _buildVisibleAccounts(TemplateState state, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text("Visible To Accounts",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primary)),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            children: state.accounts.map((account) {

              final selected =
              selectedAccounts.contains(account.id);

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

  Widget _buildCreateButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
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

          /// 🔥 Convert UI models → API request models
          final categoryRequestList = categories.map((cat) {
            return CategoryInsert(
              categoryId: 0,
              categoryName: cat.name ?? "",
              tasks: cat.tasks.map((task) {
                return TaskInsert(
                  taskId: 0,
                  taskName: task.name ?? "",
                  files: [],
                );
              }).toList(),
            );
          }).toList();

          final request = CreateTemplateRequest(
            approvalAuthority: selectedAuthorityId!,
            visibleToAccounts: selectedAccounts.join(","), // ✅ FIXED
            tabId: widget.tabId, // ✅ FIXED
            data: TemplateData(
              itemId: 0,
              itemName: titleController.text.trim(),
              categories: categoryRequestList, // ✅ FIXED
            ),
          );

          context.read<TemplateBloc>().add(
            InsertTemplate(request: request),
          );
        },
        child: const Text("Create Task List Template"),
      ),
    );
  }


  // =========================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF0F1F17),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.green.withOpacity(0.2)),
    );
  }
}
