import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/routes.dart';
import '../../core/app_settings.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text('Settings')),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _switchTile('Dark Mode', Icons.dark_mode_outlined, settings.isDark,
                    (v) => settings.setDarkMode(v)),
                _switchTile('Notifications', Icons.notifications_outlined,
                    settings.notificationsEnabled, (v) => settings.setNotificationsEnabled(v)),
                _navTile(
                  context,
                  'Accessibility',
                  Icons.accessibility_new_outlined,
                  trailing: _textSizeLabel(settings.textSize),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.accessibility),
                ),
                _navTile(
                  context,
                  'Help & Support',
                  Icons.help_outline,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport),
                ),
                SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.logout, color: AppColors.danger),
                    title: Text('Logout', style: TextStyle(color: AppColors.danger)),
                    onTap: () => _confirmLogout(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _textSizeLabel(TextSizeOption option) {
    switch (option) {
      case TextSizeOption.small:
        return 'Small';
      case TextSizeOption.medium:
        return 'Medium';
      case TextSizeOption.large:
        return 'Large';
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    }
  }

  Widget _switchTile(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(label),
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _navTile(BuildContext context, String label, IconData icon,
      {String? trailing, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(trailing, style: TextStyle(color: AppColors.grey)),
            SizedBox(width: 6),
            Icon(Icons.chevron_right, color: AppColors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
