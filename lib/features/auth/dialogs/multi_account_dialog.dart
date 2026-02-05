import 'package:flutter/material.dart';

import '../models/user_model.dart';

class MultiAccountSheet extends StatefulWidget {
  final List<UserModel> accounts;
  final Function(UserModel) onAccountSelected;

  const MultiAccountSheet({
    super.key,
    required this.accounts,
    required this.onAccountSelected,
  });

  @override
  State<MultiAccountSheet> createState() => _MultiAccountSheetState();
}

class _MultiAccountSheetState extends State<MultiAccountSheet> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredAccounts = widget.accounts.where((a) {
      return a.userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          a.companyName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          a.userTypeName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList()
      ..sort((a, b) =>
      a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ---------- Header ----------
          Text(
            "Select an Account",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            "Choose an account to continue",
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),
          const Divider(),

          /// ---------- List ----------
          if (filteredAccounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text("No accounts found")),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filteredAccounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final account = filteredAccounts[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onAccountSelected(account);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          /// Logo
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage:
                            account.companyLogoUrl?.isNotEmpty == true
                                ? NetworkImage(account.companyLogoUrl!)
                                : null,
                            child: account.companyLogoUrl?.isEmpty == true
                                ? Text(
                              account.companyName[0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            )
                                : null,
                          ),

                          const SizedBox(width: 16),

                          /// Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.companyName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${account.companyType} • ${account.userTypeName}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

