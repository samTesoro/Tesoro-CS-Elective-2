import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ResponsiveAdaptiveApp());
}

class ResponsiveAdaptiveApp extends StatelessWidget {
  const ResponsiveAdaptiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const DashboardScreen(),
    );
  }
}