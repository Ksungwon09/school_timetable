import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:school_timetable/main.dart';

void main() {
  testWidgets('App initializes', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(initialScreen: Scaffold(body: Text('Test Screen'))));

    // Verify that the title is rendered.
    expect(find.text('Test Screen'), findsOneWidget);
  });
}
