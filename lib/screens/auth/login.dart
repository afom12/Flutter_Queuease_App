import 'package:flutter/material.dart';
import 'package:queuease_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();

  String email = '';
  String password = '';
  bool isLoading = false;
  bool showPassword = false;
  String lang = 'EN';

  final Color primaryColor = const Color(0xFF004AAD);
  final Color secondaryColor = const Color(0xFF078C03);
  final Color accentColor = const Color(0xFFFCDD09);

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final user = await authService.loginWithEmail(email, password);
        if (user == null || user.uid.isEmpty) {
          _showError('Login failed: Invalid credentials.');
          return;
        }

        final role = await authService.getUserRole(user.uid);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', role);

        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          role == 'admin' ? '/admin-panel' : '/dashboard',
        );
      } catch (e) {
        _showError("Login error: ${e.toString()}");
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String tr(String en, String am) => lang == 'EN' ? en : am;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004AAD), Color(0xFF078C03)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 🌍 Header with logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/ethiopia_immigration_logo.webp', width: 40),
                      const SizedBox(width: 12),
                      Text(
                        tr("Ethiopian Immigration", "የኢትዮጵያ ኢሚግሬሽን"),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🔐 Login card
                Card(
                  elevation: 20,
                  shadowColor: Colors.black45,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 🌐 Language toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                              Switch(
                                value: lang == 'AM',
                                activeColor: secondaryColor,
                                onChanged: (val) => setState(() => lang = val ? 'AM' : 'EN'),
                              ),
                              const Text("🇪🇹", style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 🎯 Title
                          Text(
                            tr("Welcome to QueueEase", "ወደ QueueEase እንኳን ደህና መጡ"),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tr("Sign in to continue", "ለመቀጠል ይግቡ"),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),

                          // 📩 Email field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: tr("Email", "ኢሜይል"),
                              prefixIcon: Icon(Icons.email, color: primaryColor),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) =>
                                val == null || val.isEmpty ? tr("Enter email", "ኢሜይል ያስገቡ") : null,
                            onChanged: (val) => email = val,
                          ),
                          const SizedBox(height: 16),

                          // 🔒 Password field
                          TextFormField(
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              labelText: tr("Password", "የይለፍ ቃል"),
                              prefixIcon: Icon(Icons.lock, color: primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showPassword ? Icons.visibility : Icons.visibility_off,
                                  color: primaryColor,
                                ),
                                onPressed: () => setState(() => showPassword = !showPassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (val) =>
                                val == null || val.isEmpty ? tr("Enter password", "የይለፍ ቃል ያስገቡ") : null,
                            onChanged: (val) => password = val,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                tr("Forgot password?", "የይለፍ ቃል ረሳኽው?"),
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🚀 Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: isLoading ? null : _login,
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      tr("LOGIN", "ግባ"),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // OR Divider
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[400])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(tr("OR", "ወይም"), style: TextStyle(color: Colors.grey[600])),
                              ),
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 🧾 Register prompt
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tr("Don't have an account?", "መለያ የለዎትም?"),
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                                child: Text(
                                  tr("Register", "ይመዝገቡ"),
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
