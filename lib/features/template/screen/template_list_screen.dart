import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/template/screen/widget/tab_name.dart';
import 'package:task_manager/features/template/screen/widget/template_item_card.dart';

import '../bloc/template_bloc.dart';
import '../bloc/template_state.dart';
import 'create_template_screen.dart';

class TemplateListScreen extends StatelessWidget {
  final String tabId;
  final String tabName;

  const TemplateListScreen(
      {super.key, required this.tabId, required this.tabName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme
        .of(context)
        .colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Template List"),
      ),
      body: Stack(
        children: [
          BlocBuilder<TemplateBloc, TemplateState>(
            builder: (context, state) {

              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state.templates.isEmpty) {
                return const Center(
                  child: Text("No Templates Found"),
                );
              }

              return Column(
                children: [
                  buildTabName(scheme, tabName),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      itemCount: state.templates.length,
                      itemBuilder: (context, index) {
                        return TemplateItemCard(
                          item: state.templates[index],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildCreateButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
      ),
      onPressed: () {
        // 🔥
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<TemplateBloc>(),
              child: CreateTemplateScreen(tabId: tabId, tabName: tabName),
            ),
          ),
        );
      },
      icon: const Icon(Icons.add, size: 22),
      label: const Text(
        "Create Template Format",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}



