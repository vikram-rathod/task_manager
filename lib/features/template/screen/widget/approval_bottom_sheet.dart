import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/template_bloc.dart';
import '../../bloc/template_event.dart';
import '../../bloc/template_state.dart';

class ApprovalBottomSheet extends StatefulWidget {
  final String templateId;

  const ApprovalBottomSheet({
    super.key,
    required this.templateId,
  });

  @override
  State<ApprovalBottomSheet> createState() => _ApprovalBottomSheetState();
}

class _ApprovalBottomSheetState extends State<ApprovalBottomSheet> {

  int? selectedUserId;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {

            /// 🔥 Create combined list (No One + Authorities)
            final allAuthorities = [
              {
                "user_id": 0,
                "user_name": "No One (Approve by Self)"
              },
              ...state.authorities.map((e) => {
                "user_id": e.userId,
                "user_name": e.userName,
              })
            ];

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Drag Handle
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Title
                Text(
                  "Next Authority Approval",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: outline,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Select authority to forward this template",
                  style: TextStyle(
                    color: outline,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                /// Authority List Card
                Container(
                  decoration: BoxDecoration(
                    color: outline.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: allAuthorities.map((user) {

                      final int userId = user["user_id"] as int;
                      final String userName = user["user_name"] as String;

                      final isSelected = selectedUserId == userId;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedUserId = userId;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [

                              /// Radio Circle
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? primary
                                        : outline.withOpacity(0.5),
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: primary,
                                    ),
                                  ),
                                )
                                    : null,
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: userId == 0
                                        ? primary
                                        : outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 30),

                /// Buttons Row
                Row(
                  children: [

                    /// Cancel
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// Approve
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: selectedUserId == null
                            ? null
                            : () {

                          final authorityToSend = selectedUserId == 0
                              ? "1"   // ✅ self approve
                              : selectedUserId.toString();
                          context.read<TemplateBloc>().add(
                            TemplateApprovalEvent(
                              itemId: widget.templateId,
                              status: "1",
                              authorityId: authorityToSend,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Approve",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }
}
