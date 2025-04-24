import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final String requiredRole;

  const RoleGuard({super.key, required this.child, required this.requiredRole});

  Future<bool> _hasAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRole = prefs.getString('userRole');
    return storedRole == requiredRole;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasAccess(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return child;
        } else {
          return const AccessDeniedPage(); // Optional fallback
        }
      },
    );
  }
}

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Access Denied",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("You don’t have permission to access this page."),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
              child: const Text("Go to Dashboard"),
            ),
          ],
        ),
      ),
    );
  }
}
