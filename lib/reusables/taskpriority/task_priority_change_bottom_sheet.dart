import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injection_container.dart';
import 'bloc/task_priority_bloc.dart';

void showChangePriorityBottomSheet({
  required BuildContext context,
  required String taskId,
  required String currentPriority,
  VoidCallback? onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => ChangePriorityBloc(
        repository: sl(),
        storageService: sl(),
      ),
      child: _ChangePrioritySheet(
        taskId: taskId,
        currentPriority: currentPriority,
        onSuccess: onSuccess,
      ),
    ),
  );
}

class _ChangePrioritySheet extends StatefulWidget {
  final String taskId;
  final String currentPriority;
  final VoidCallback? onSuccess;

  const _ChangePrioritySheet({
    required this.taskId,
    required this.currentPriority,
    this.onSuccess,
  });

  @override
  State<_ChangePrioritySheet> createState() => _ChangePrioritySheetState();
}

class _ChangePrioritySheetState extends State<_ChangePrioritySheet> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentPriority);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ChangePriorityBloc>().add(
        SubmitPriorityChange(
          taskId: widget.taskId,
          priority: _controller.text.trim(),
        ),
      );
    }
  }

  Color _getPriorityColor(String? p) {
    switch (p) {
      case '1': return const Color(0xFFEF4444);
      case '2': return const Color(0xFFF59E0B);
      case '3': return const Color(0xFF3B82F6);
      default:  return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<ChangePriorityBloc, ChangePriorityState>(
      listener: (context, state) {
        if (state is ChangePrioritySuccess) {
          Navigator.pop(context);
          widget.onSuccess?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is ChangePriorityFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: scheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Priority',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          'Current: P-${widget.currentPriority}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPriorityColor(widget.currentPriority),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Manual input
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter priority number (e.g. 1, 2, 3...)',
                    hintStyle: TextStyle(
                      color: scheme.onSurface.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(
                      Icons.flag_outlined,
                      color: _getPriorityColor(_controller.text),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.outline,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.outline.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFEF4444),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a priority number';
                    }
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 1) {
                      return 'Priority must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit button
                BlocBuilder<ChangePriorityBloc, ChangePriorityState>(
                  builder: (context, state) {
                    final isLoading = state is ChangePriorityLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          disabledBackgroundColor: scheme.primary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'Update Priority',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}