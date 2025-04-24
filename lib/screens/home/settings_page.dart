import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        "icon": Icons.person,
        "title": "My Profile",
        "onTap": () => Navigator.pushNamed(context, '/profile'),
      },
      {
        "icon": Icons.info_outline,
        "title": "About Us",
        "onTap": () {
          showAboutDialog(
            context: context,
            applicationName: 'QUEUEASE',
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 Ethiopian Immigration',
            children: const [Text('A digital solution for managing queues at immigration centers.')],
          );
        },
      },
      {
  "icon": Icons.language,
  "title": "Language",
  "onTap": () {
    // Show language selector
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("English"), onTap: () {}),
            ListTile(title: const Text("Amharic"), onTap: () {}),
          ],
        ),
      ),
    );
  },
},
{
  "icon": Icons.brightness_6,
  "title": "Theme",
  "onTap": () {
    // Optional: Add actual theme toggle support
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming soon!")));
  },
},

      {
        "icon": Icons.help_outline,
        "title": "Help & Support",
        "onTap": () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Help & Support"),
              content: const Text("For support, contact support@queuease.et or call 992."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          );
        },
      },
      {
        "icon": Icons.logout,
        "title": "Logout",
        "onTap": () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          }
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF004AAD),
      ),
      body: ListView.separated(
        itemCount: settingsOptions.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final item = settingsOptions[index];
          return ListTile(
            leading: Icon(item['icon'], color: const Color(0xFF004AAD)),
            title: Text(item['title']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: item['onTap'],
          );
        },
      ),
    );
  }
}
