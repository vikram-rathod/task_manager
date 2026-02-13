import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/template/screen/widget/template_item_card.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_state.dart';
import '../model/template_models.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task-Template-List"),
      ),
      body: Stack(
        children: [

          /// MAIN LIST
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

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16,16,16,120),
                itemCount: state.templates.length,
                itemBuilder: (context, index) {
                  return TemplateItemCard(
                    item: state.templates[index],
                  );
                },
              );
            },
          ),

          /// BOTTOM BUTTON
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
        // 🔥 Navigate to create template screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const CreateTemplateScreen(),
        //   ),
        // );
      },
      icon: const Icon(Icons.add, size: 22),
      label: const Text(
        "Create Template",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}



