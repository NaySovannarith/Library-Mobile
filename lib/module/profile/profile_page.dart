// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:library_app/auth/service/auth_service.dart';
import 'package:provider/provider.dart';
import '../../auth/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, _) {
          final user = authService.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Not logged in'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile header
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white24,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            if (user.role != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.role!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // User Information Section
              _sectionTitle('User Information'),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Phone'),
                  subtitle: Text(user.phoneNumber!),
                ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email'),
                subtitle: Text(user.email),
              ),
              if (user.isEmailConfirmed != null)
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('Email Verified'),
                  trailing: user.isEmailConfirmed!
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red),
                ),

              const Divider(),

              // Account section
              _sectionTitle('Account'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showMessage('Edit Profile - Coming soon');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showChangePasswordDialog(context, authService);
                },
              ),

              const Divider(),

              // Preferences
              _sectionTitle('Preferences'),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _notificationsEnabled,
                title: const Text('Notifications'),
                secondary: const Icon(Icons.notifications_none),
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),

              const Divider(),

              // Security & help
              _sectionTitle('Security & Support'),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Feedback'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showMessage('Open help center'),
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, authService),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AuthService authService,
  ) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    hintText: 'Current Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureOld
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureOld = !obscureOld);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureNew = !obscureNew);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setDialogState(() => obscureConfirm = !obscureConfirm);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New password is required')),
                  );
                  return;
                }

                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                final success = await authService.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password changed successfully'
                            : authService.error ?? 'Failed to change password',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
