import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blackmagic_camera_control/app.dart';
import 'package:blackmagic_camera_control/providers/camera_connection_provider.dart';
import 'package:blackmagic_camera_control/providers/camera_state_provider.dart';

void main() {
  testWidgets('Connection screen shows on startup', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => CameraConnectionProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => CameraStateProvider(),
          ),
        ],
        child: const BlackmagicControlApp(),
      ),
    );

    // Verify connection screen elements are present
    expect(find.text('Blackmagic Camera Control'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
