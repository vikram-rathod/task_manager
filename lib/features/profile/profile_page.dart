import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/theme/theme_cubit.dart';

import '../../core/storage/storage_keys.dart';
import '../../core/storage/storage_service.dart';
import '../../reusables/logout_confirmation.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import 'bloc/profile_bloc.dart';

// ─────────────────────────────────────────────
//  ProfilePage
// ─────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _showLogoutDialog = false;
  bool _showFullImagePreview = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;
    final isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .background,
              appBar: AppBar(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .background,
                elevation: 0,
                actions: [
                  IconButton(
                      icon: Icon(
                        isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      onPressed: () => context.read<ThemeCubit>().toggle()
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
                    // ── Contact Information ──────────────────────
                    _SectionTitle(title: 'Contact Information'),
                    const SizedBox(height: 8),

                    if (user.userEmail.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.userEmail,
                      ),
                    if (user.userMobileNumber.isNotEmpty)
                      _ProfileDetailItem(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.userMobileNumber,
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

                    const SizedBox(height: 24),

                    // ── Settings ─────────────────────────────────
                    _SectionTitle(title: 'Settings'),
                    const SizedBox(height: 8),

                    _SettingsItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () =>
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('Coming Soon'))),
                    ),
                    _SettingsItem(
                      icon: Icons.security_outlined,
                      label: 'Change Password',
                      onTap: () =>
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('Coming Soon'))),
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () =>
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('Coming Soon'))),
                    ),

                    if (user.userId.toString() == '700417')
                      _SettingsItem(
                        icon: Icons.phone_android_outlined,
                        label: 'Sessions',
                        onTap: () =>
                        {
                          Navigator.pushNamed(context, '/sessions')
                        },
                      ),

                    const SizedBox(height: 24),

                    // ── App Version ──────────────────────────────
                    _SettingsItem(
                      icon: Icons.phone_android_outlined,
                      label: 'App Version: [ 1.0.0 ]',
                      onTap: () {},
                      showNavigation: false,
                    ),

                    const SizedBox(height: 8),

                    // ── Logout Button ────────────────────────────
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme
                                .of(context)
                                .colorScheme
                                .error,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 20),
                          label: const Text('Logout'),
                          onPressed: () =>
                              _showLogoutConfirmation(context)
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Full Image Preview ───────────────────────────────────────────
            if (_showFullImagePreview && state.user?.userProfileUrl != null)
              _FullImagePreview(
                imageUrl: state.user!.userProfileUrl!,
                onDismiss: () => setState(() => _showFullImagePreview = false),
              ),
          ],
        );
      },
    );
  }
}
Future<void> _showLogoutConfirmation(BuildContext context) async {
  final profileBloc = context.read<ProfileBloc>();

  final sessionId = await profileBloc.storageService
      .read(StorageKeys.loginSessionId);

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => LogoutConfirmationDialog(
      onConfirm: () {
        context.read<AuthBloc>().add(
          LogoutRequested(
            sessionId: sessionId ?? '',
          ),
        );
      },
    ),
  );
}

// ─────────────────────────────────────────────
//  Profile Image With Initials
// ─────────────────────────────────────────────
class _ProfileImageWithInitials extends StatelessWidget {
  final String? imageUrl;
  final String userName;
  final double size;

  const _ProfileImageWithInitials({
    required this.imageUrl,
    required this.userName,
    this.size = 100,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: colorScheme.primary,
        child: (imageUrl != null && imageUrl!.isNotEmpty)
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsWidget(colorScheme),
        )
            : _initialsWidget(colorScheme),
      ),
    );
  }

  Widget _initialsWidget(ColorScheme colorScheme) {
    return Center(
      child: Text(
        _getInitials(userName),
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
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
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme
                        .of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
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
    final colorScheme = Theme
        .of(context)
        .colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showNavigation)
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
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
        style: Theme
            .of(context)
            .textTheme
            .titleMedium
            ?.copyWith(
          fontWeight: FontWeight.bold,
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
                  errorBuilder: (_, __, ___) =>
                  const Icon(
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
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
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

// ─────────────────────────────────────────────
//  Helper alias so the old Card shape string
//  compiles (Flutter uses BorderRadius directly)
// ─────────────────────────────────────────────
ShapeBorder RoundedCornerShape(double radius) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));