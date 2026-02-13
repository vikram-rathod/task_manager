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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task-Template-List"),
      ),
      body: BlocBuilder<TemplateBloc, TemplateState>(
        builder: (context, state) {

          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(
              child: Text(state.error!),
            );
          }

          if (state.templates.isEmpty) {
            return const Center(
              child: Text("No Templates Found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.templates.length,
            itemBuilder: (context, index) {
              return TemplateItemCard(
                item: state.templates[index],
              );
            },
          );
        },
      ),
    );
  }
}



