import 'package:flutter/material.dart';
import 'package:timetiles/screens/home_screen.dart';

void main() {
  runApp(const TimeTilesApp());
}

class TimeTilesApp extends StatelessWidget {
  const TimeTilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeTiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1E1E1E),
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
