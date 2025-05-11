import 'package:flutter/material.dart';
import '../features/main_screen/main_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'डेपो व्यवस्थापन',
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
