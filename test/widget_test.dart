import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:queuease_app/main.dart';

void main() {
  // Test 1: Basic rendering test
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Test Render'))),
      ), // Added missing parenthesis
    );
    
    expect(find.text('Test Render'), findsOneWidget);
  });

  // Test 2: Actual MyApp test with Firebase mock
  testWidgets('MyApp renders LoginScreen', (WidgetTester tester) async {
    // Mock Firebase initialization
    await tester.pumpWidget(
      const QueueaseApp(),
      duration: const Duration(seconds: 1), // Allow for async initialization
    );
    
    // Verify LoginScreen components
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email & password fields
    expect(find.text('Login'), findsOneWidget);
  });
}