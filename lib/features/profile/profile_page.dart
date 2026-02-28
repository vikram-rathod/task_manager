import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

import '../../core/storage/storage_keys.dart';
import '../../core/storage/storage_service.dart';
import '../../reusables/logout_confirmation.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import 'bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showFullImagePreview = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: colorScheme.background,
              appBar: AppBar(
                backgroundColor: colorScheme.background,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined),
                    onPressed: () => context.read<ThemeCubit>().toggle(),
                  ),
                ],
              ),
              body: state.isProfileLoading
                  ? const Center(child: CircularProgressIndicator())
                  : user == null
                  ? const Center(child: Text('No Data Found'))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Profile Header Card ──────────────────────
                    _ProfileHeaderCard(
                      user: user,
                      onImageTap: user.userProfileUrl.isNotEmpty
                          ? () => setState(
                              () => _showFullImagePreview = true)
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // ── Contact Information ──────────────────────
                    const _SectionTitle(title: 'Contact Information'),
                    const SizedBox(height: 8),

                    if (user.userEmail.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: maskEmail(user.userEmail),
                      ),
                    if (user.userMobileNumber.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: maskPhone(user.userMobileNumber),
                      ),
                    if (user.userTypeName.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.badge_outlined,
                        label: 'User Type',
                        value: user.userTypeName,
                      ),
                    if (user.profileType.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.person_outlined,
                        label: 'Profile Type',
                        value: user.profileType,
                      ),

                    // ── Company Information ──────────────────────
                    if (user.companyName.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const _SectionTitle(
                          title: 'Company Information'),
                      const SizedBox(height: 8),
                      _ProfileDetailItem(
                        icon: Icons.business_outlined,
                        label: 'Company',
                        value: user.companyName,
                      ),
                      if (user.companyType.isNotEmpty)
                        _ProfileDetailItem(
                          icon: Icons.category_outlined,
                          label: 'Company Type',
                          value: user.companyType,
                        ),
                    ],

                    const SizedBox(height: 20),

                    // ── Settings ─────────────────────────────────
                    const _SectionTitle(title: 'Settings'),
                    const SizedBox(height: 8),

                    _SettingsItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Coming Soon'))),
                    ),
                    _SettingsItem(
                      icon: Icons.security_outlined,
                      label: 'Change Password',
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Coming Soon'))),
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Coming Soon'))),
                    ),

                    if (user.userId.toString() == '700417')
                      _SettingsItem(
                        icon: Icons.phone_android_outlined,
                        label: 'Sessions',
                        onTap: () =>
                            Navigator.pushNamed(context, '/sessions'),
                      ),

                    const SizedBox(height: 20),

                    // ── App Version ──────────────────────────────
                    _SettingsItem(
                      icon: Icons.info_outline,
                      label: 'App Version: [ 1.0.0 ]',
                      onTap: () {},
                      showNavigation: false,
                    ),

                    const SizedBox(height: 12),

                    // ── Logout Button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Logout'),
                        onPressed: () =>
                            _showLogoutConfirmation(context),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Full Image Preview ───────────────────────────────────────────
            if (_showFullImagePreview && user?.userProfileUrl.isNotEmpty == true)
              _FullImagePreview(
                imageUrl: user!.userProfileUrl,
                onDismiss: () => setState(() => _showFullImagePreview = false),
              ),
          ],
        );
      },
    );
  }

  String maskEmail(String userEmail) {
    if (userEmail.isEmpty || !userEmail.contains('@')) {
      return userEmail;
    }

    final parts = userEmail.split('@');
    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}*@${domain}';
    }

    final visiblePart = name.substring(0, 2);
    final maskedPart = '*' * (name.length - 2);

    return '$visiblePart$maskedPart@$domain';
  }

  String maskPhone(String userMobileNumber) {
    if (userMobileNumber.length <= 4) {
      return userMobileNumber;
    }

    final visibleDigits = userMobileNumber.substring(userMobileNumber.length - 4);
    final maskedPart = '*' * (userMobileNumber.length - 4);

    return '$maskedPart$visibleDigits';
  }
}

Future<void> _showLogoutConfirmation(BuildContext context) async {
  final profileBloc = context.read<ProfileBloc>();
  final sessionId =
  await profileBloc.storageService.read(StorageKeys.loginSessionId);
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (_) => LogoutConfirmationDialog(
      onConfirm: () {
        context.read<AuthBloc>().add(
          LogoutRequested(sessionId: sessionId ?? ''),
        );
      },
    ),
  );
}

// ─────────────────────────────────────────────
//  Profile Header Card
// ─────────────────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onImageTap;

  const _ProfileHeaderCard({required this.user, this.onImageTap});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = user.userProfileUrl.isNotEmpty;
    final hasCompany = user.companyName.isNotEmpty;
    final hasDesignation = user.designation.isNotEmpty;

    return Card(
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: onImageTap,
              child: Stack(
                children: [
                  ClipOval(
                    child: Container(
                      width: 72,
                      height: 72,
                      color: scheme.primary,
                      child: hasImage
                          ? Image.network(
                        user.userProfileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _initialsWidget(scheme, user.userName),
                      )
                          : _initialsWidget(scheme, user.userName),
                    ),
                  ),
                  if (hasImage)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: scheme.surface, width: 1.5),
                        ),
                        child: Icon(Icons.zoom_in,
                            size: 12, color: scheme.onPrimary),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasDesignation) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.designation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (hasCompany) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.business_outlined,
                            size: 12, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.companyType.isNotEmpty
                                ? '${user.companyName} • ${user.companyType}'
                                : user.companyName,
                            style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  // User ID chip
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ID: ${user.userId}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsWidget(ColorScheme scheme, String name) {
    return Center(
      child: Text(
        _getInitials(name),
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Profile Detail Item
// ─────────────────────────────────────────────
class _ProfileDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Settings Item
// ─────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showNavigation;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showNavigation = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showNavigation)
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section Title
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Full Image Preview Overlay
// ─────────────────────────────────────────────
class _FullImagePreview extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDismiss;

  const _FullImagePreview({
    required this.imageUrl,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon:
                  const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: onDismiss,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}