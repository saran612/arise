import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arise/main.dart';

void main() {
  testWidgets('Arise App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AriseApp());

    // Verify that the title logo image is displayed.
    expect(find.byType(Image), findsOneWidget);

    // Verify that the default tasks are rendered.
    expect(find.text('Design Arise brand identity'), findsOneWidget);
    expect(find.text('Implement Flutter state management'), findsOneWidget);

    // Tap the floating action button to open the Add Task modal sheet
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle(); // Wait for bottom sheet animation

    // Enter a new task title
    await tester.enterText(find.byType(TextField).last, 'Learn Flutter Testing');
    await tester.pump();

    // Tap the submit/create task button
    await tester.tap(find.text('Create Task'));
    await tester.pumpAndSettle();

    // Verify that the new task is added to the list
    expect(find.text('Learn Flutter Testing'), findsOneWidget);
  });
}
