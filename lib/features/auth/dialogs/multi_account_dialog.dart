import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../models/user_model.dart';

class MultiAccountSheet extends StatefulWidget {
  final List<UserModel> accounts;
  final UserModel? currentUser;
  final bool isSwitch;
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final Function(UserModel) onAccountSelected;

  const MultiAccountSheet({
    super.key,
    required this.accounts,
    required this.currentUser,
    required this.isSwitch,
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    required this.onAccountSelected,
  });

  @override
  State<MultiAccountSheet> createState() => _MultiAccountSheetState();
}

enum _SwitchStatus { idle, switching, success, failed }

class _MultiAccountSheetState extends State<MultiAccountSheet> {
  String _searchQuery = '';
  UserModel? _pendingAccount;
  _SwitchStatus _status = _SwitchStatus.idle;
  String _statusMessage = '';

  // For the empty-list retry flow
  bool _isRetrying = false;
  String? _retryError;

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ]),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  void _retryFetchAccounts() {
    setState(() {
      _isRetrying = true;
      _retryError = null;
    });
    // Re-fire login with same credentials — the bloc will return
    // AuthMultipleAccountsFound again with (hopefully) a populated list,
    // or AuthError if the server is down.
    context.read<AuthBloc>().add(LoginRequested(
      username: widget.username,
      password: widget.password,
      deviceName: widget.deviceName,
      deviceType: widget.deviceType,
      deviceUniqueId: widget.deviceUniqueId,
      deviceToken: widget.deviceToken,
      isSwitch: widget.isSwitch,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final filteredAccounts = widget.accounts.where((a) {
      return a.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.companyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.userTypeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()
      ..sort((a, b) =>
          a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!mounted) return;

        // ── Retry flow: waiting for account list to reload ──────────────────
        if (_isRetrying) {
          if (state is AuthMultipleAccountsFound) {
            // New list came back — close this sheet so AuthFlowHandler opens
            // a fresh one with the updated list.
            setState(() => _isRetrying = false);
            Navigator.of(context).pop();
            return;
          }
          if (state is AuthError) {
            setState(() {
              _isRetrying = false;
              _retryError = state.message.isNotEmpty
                  ? state.message
                  : 'Failed to load accounts. Please try again.';
            });
            _showSnackBar(_retryError!, isError: true);
            return;
          }
          // Still loading — keep spinner
          return;
        }

        // ── Account-switch flow (home screen only) ───────────────────────────
        // During login flow isSwitch=false — skip switching status entirely.
        // The login screen handles navigation on AuthAuthenticated itself.
        if (!widget.isSwitch) return;

        if (state is AuthLoading || state is AuthSwitching) {
          setState(() {
            _status = _SwitchStatus.switching;
            _statusMessage = 'Switching account…';
          });
          return;
        }

        if (state is AuthAuthenticated) {
          final msg = 'Switched to ${state.user.companyName} successfully!';
          setState(() {
            _status = _SwitchStatus.success;
            _statusMessage = msg;
          });
          _showSnackBar(msg, isError: false);
          // Brief delay so the user sees the success banner, then close.
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) Navigator.of(context).pop();
          });
          return;
        }

        if (state is AuthError) {
          final msg = state.message.isNotEmpty
              ? state.message
              : 'Switch failed. Please try again.';
          setState(() {
            _status = _SwitchStatus.failed;
            _statusMessage = msg;
            _pendingAccount = null; // allow retrying a different account
          });
          _showSnackBar(msg, isError: true);
          return;
        }
      },
      child: PopScope(
        canPop: _status != _SwitchStatus.switching,
        onPopInvoked: (didPop) {
          if (didPop && !widget.isSwitch) {
            // Reset pending selection so rows are selectable again if the
            // sheet is reopened or the user navigates back.
            setState(() => _pendingAccount = null);
          }
        },
        child: Padding(
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
              // ── Handle bar ──────────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header row ───────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Multiple Account Found',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Choose an account to continue',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  // Hide close button while switching to prevent interruption
                  if (_status != _SwitchStatus.switching && !_isRetrying)
                    GestureDetector(
                      onTap: () {
                        if (!widget.isSwitch) {
                          setState(() => _pendingAccount = null);
                        }
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: scheme.surfaceVariant.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close,
                            size: 18, color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),

              // ── Status banner (switching / success / failed) ──────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SizeTransition(sizeFactor: anim, child: child),
                ),
                child: _status != _SwitchStatus.idle
                    ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StatusBanner(
                    key: ValueKey(_status),
                    status: _status,
                    message: _statusMessage,
                    scheme: scheme,
                    onRetry: _status == _SwitchStatus.failed
                        ? () => setState(() {
                      _status = _SwitchStatus.idle;
                      _pendingAccount = null;
                    })
                        : null,
                  ),
                )
                    : const SizedBox.shrink(key: ValueKey('idle')),
              ),

              // ── Empty list: full error + retry ────────────────────────────────
              if (widget.accounts.isEmpty)
                _EmptyAccountsView(
                  isRetrying: _isRetrying,
                  retryError: _retryError,
                  scheme: scheme,
                  onRetry: _retryFetchAccounts,
                )

              // ── Search filtered, nothing matches ──────────────────────────────
              else if (filteredAccounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No accounts match your search')),
                )

              // ── Account list ──────────────────────────────────────────────────
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: filteredAccounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final account = filteredAccounts[index];
                      final isCurrentAccount = widget.currentUser != null &&
                          widget.currentUser!.userId == account.userId;
                      final isPending =
                          _pendingAccount?.userId == account.userId;
                      // In switch flow: block taps while switching/success.
                      // In login flow: _status is always idle so block only
                      // the tapped row briefly via _pendingAccount, then reset.
                      final isBusy = widget.isSwitch
                          ? (_status == _SwitchStatus.switching ||
                          _status == _SwitchStatus.success)
                          : false; // login flow never locks all rows

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isCurrentAccount || isBusy
                            ? null
                            : () {
                          if (widget.isSwitch) {
                            setState(() {
                              _pendingAccount = account;
                              _status = _SwitchStatus.switching;
                              _statusMessage = 'Switching account…';
                            });
                          }
                          widget.onAccountSelected(account);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: isCurrentAccount
                                ? Border.all(color: scheme.primary, width: 2)
                                : isPending
                                ? Border.all(
                                color: scheme.primary.withOpacity(0.4),
                                width: 1.5)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            color: isCurrentAccount
                                ? scheme.primary.withOpacity(0.1)
                                : isPending
                                ? scheme.primary.withOpacity(0.05)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // ── Logo ─────────────────────────────────────────
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: account.companyLogoUrl.isNotEmpty
                                    ? NetworkImage(account.companyLogoUrl)
                                    : null,
                                child: account.companyLogoUrl.isEmpty
                                    ? Text(
                                  account.companyName[0].toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                                    : null,
                              ),

                              const SizedBox(width: 16),

                              // ── Details ───────────────────────────────────────
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            account.companyName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                              fontWeight: isCurrentAccount
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        if (isCurrentAccount)
                                          _Chip(
                                              label: 'Current',
                                              color: scheme.primary),
                                        const SizedBox(width: 6),
                                        if (isPending &&
                                            _status == _SwitchStatus.switching)
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        if (isPending &&
                                            _status == _SwitchStatus.success)
                                          Icon(Icons.check_circle_rounded,
                                              color: Colors.green.shade600,
                                              size: 18),
                                        if (isPending &&
                                            _status == _SwitchStatus.failed)
                                          Icon(Icons.error_outline_rounded,
                                              color: scheme.error, size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${account.companyType} • ${account.userTypeName}',
                                      style:
                                      Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),

                              // if (isCurrentAccount)
                              //   Icon(Icons.check_circle,
                              //       color: scheme.primary, size: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty accounts view with retry ───────────────────────────────────────────

class _EmptyAccountsView extends StatelessWidget {
  final bool isRetrying;
  final String? retryError;
  final ColorScheme scheme;
  final VoidCallback onRetry;

  const _EmptyAccountsView({
    required this.isRetrying,
    required this.retryError,
    required this.scheme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.error.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded,
                size: 40, color: scheme.error),
          ),
          const SizedBox(height: 16),
          Text(
            'No Accounts Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            retryError ??
                'Your account list could not be loaded.\nPlease try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isRetrying ? null : onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: isRetrying
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: scheme.onPrimary),
              )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(isRetrying ? 'Loading…' : 'Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final _SwitchStatus status;
  final String message;
  final ColorScheme scheme;
  final VoidCallback? onRetry;

  const _StatusBanner({
    super.key,
    required this.status,
    required this.message,
    required this.scheme,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final Color color;
    final Color bgColor;
    final Widget leading;

    switch (status) {
      case _SwitchStatus.switching:
        color = scheme.primary;
        bgColor = scheme.primary.withOpacity(0.08);
        leading = SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
        );
        break;
      case _SwitchStatus.success:
        color = Colors.green.shade700;
        bgColor = Colors.green.withOpacity(0.08);
        leading = Icon(Icons.check_circle_outline_rounded, color: color, size: 18);
        break;
      case _SwitchStatus.failed:
        color = scheme.error;
        bgColor = scheme.error.withOpacity(0.08);
        leading = Icon(Icons.error_outline_rounded, color: color, size: 18);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: color,
              ),
              child: const Text('Retry',
                  style:
                  TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

// ── Small label chip ──────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}