import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getCachedUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userRole');
}
