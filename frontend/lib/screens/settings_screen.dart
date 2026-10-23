import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'info_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Preferences'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
            activeThumbColor: theme.colorScheme.primary,
          ),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Language'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                items: _languages.map((String lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Text(lang),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Language changed to $newValue (UI only for now)')),
                    );
                  }
                },
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Information'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InfoScreen(
                    title: 'Privacy Policy',
                    content: 'We take your privacy seriously. Your data is encrypted and never sold to third parties. We collect basic analytics to improve your experience.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InfoScreen(
                    title: 'Terms of Service',
                    content: 'By using Roamly, you agree to our community guidelines. Be respectful, do not post inappropriate content, and enjoy your travels!',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InfoScreen(
                    title: 'About',
                    content: 'Roamly Version 1.0.0\n\nA beautiful way to share and discover amazing travel destinations around the world.',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
            title: Text('Logout', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
            onTap: () async {
              // Show confirmation dialog
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
