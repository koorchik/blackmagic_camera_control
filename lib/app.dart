import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/camera_connection_provider.dart';
import 'screens/connection_screen.dart';
import 'screens/main_screen.dart';

class BlackmagicControlApp extends StatelessWidget {
  const BlackmagicControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackmagic Camera Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.all(8),
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 8,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: Consumer<CameraConnectionProvider>(
        builder: (context, connection, _) {
          if (connection.isConnected) {
            return const MainScreen();
          }
          return const ConnectionScreen();
        },
      ),
    );
  }
}
