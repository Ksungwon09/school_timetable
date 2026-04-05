import 'package:flutter_test/flutter_test.dart';

import 'package:school_timetable/main.dart';

void main() {
  testWidgets('App initializes', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is rendered.
    expect(find.text('Search School'), findsOneWidget);
  });
}
