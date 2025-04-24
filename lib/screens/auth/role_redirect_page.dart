import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleRedirectPage extends StatelessWidget {
  const RoleRedirectPage({super.key});

  Future<String?> _getCachedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  Future<Widget> _resolveNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _RouteTo('/login');
    }

    final role = await _getCachedRole();

    if (role == 'admin') {
      return const _RouteTo('/admin-panel');
    } else {
      return const _RouteTo('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveNextScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

class _RouteTo extends StatelessWidget {
  final String route;
  const _RouteTo(this.route);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Navigator.of(context).pushReplacementNamed(route);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
