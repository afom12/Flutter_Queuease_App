import 'package:flutter/material.dart';
import 'package:queuease_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final authService = AuthService();
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;
  String lang = 'EN';

  // Ethiopian-inspired color palette
  final Color primaryColor = const Color(0xFF004AAD); // Ethiopian blue
  final Color secondaryColor = const Color(0xFF078C03); // Ethiopian green
  final Color accentColor = const Color(0xFFFCDD09); // Ethiopian yellow

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        _showError(tr("Passwords don't match", "የይለፍ ቃሎቹ አይመሳሰሉም"));
        return;
      }

      setState(() => isLoading = true);
      try {
        await authService.registerWithEmail(email, password);
        Navigator.pushReplacementNamed(context, '/dashboard');
      } catch (e) {
        _showError(e.toString());
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F0FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Ethiopian-themed header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/ethiopia_immigration_logo.webp', width: 40),
                      const SizedBox(width: 12),
                      Text(
                        tr("Ethiopian Immigration", "የኢትዮጵያ ኢሚግሬሽን"),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Registration card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadowColor: primaryColor.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Language toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("🇬🇧", style: TextStyle(fontSize: 20)),
                              Switch(
                                value: lang == 'AM',
                                activeColor: secondaryColor,
                                onChanged: (val) {
                                  setState(() => lang = val ? 'AM' : 'EN');
                                },
                              ),
                              const Text("🇪🇹", style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            tr("Create New Account", "አዲስ መለያ ይፍጠሩ"),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr("Join QueueEase today", "ዛሬ ወደ QueueEase ይቀላቀሉ"),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Email field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: tr("Email", "ኢሜይል"),
                              prefixIcon: Icon(Icons.email, color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || val.isEmpty
                                ? tr("Enter email", "ኢሜይል ያስገቡ")
                                : null,
                            onChanged: (val) => email = val,
                          ),
                          const SizedBox(height: 20),

                          // Password field
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return tr("Enter password", "የይለፍ ቃል ያስገቡ");
                              }
                              if (val.length < 6) {
                                return tr("Minimum 6 characters", "ቢያንስ 6 ቁምፊዎች");
                              }
                              return null;
                            },
                            onChanged: (val) => password = val,
                          ),
                          const SizedBox(height: 20),

                          // Confirm password field
                          TextFormField(
                            obscureText: !showConfirmPassword,
                            decoration: InputDecoration(
                              labelText: tr("Confirm Password", "የይለፍ ቃል ያረጋግጡ"),
                              prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  showConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primaryColor,
                                ),
                                onPressed: () =>
                                    setState(() => showConfirmPassword = !showConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return tr("Confirm password", "የይለፍ ቃል ያረጋግጡ");
                              }
                              if (val != password) {
                                return tr("Passwords don't match", "የይለፍ ቃሎቹ አይመሳሰሉም");
                              }
                              return null;
                            },
                            onChanged: (val) => confirmPassword = val,
                          ),
                          const SizedBox(height: 30),

                          // Register button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              onPressed: isLoading ? null : _register,
                              child: isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      tr("REGISTER", "ይመዝገቡ"),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey[400]),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  tr("OR", "ወይም"),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Login prompt
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tr("Already have an account?", "መለያ አለዎት?"),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushReplacementNamed(context, '/login'),
                                child: Text(
                                  tr("Login", "ግባ"),
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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