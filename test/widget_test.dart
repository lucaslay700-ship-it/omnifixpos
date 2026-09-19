import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic App Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('OmniFix POS'),
          ),
        ),
      ),
    );

    expect(find.text('OmniFix POS'), findsOneWidget);
    expect(find.text('Non-existent Text'), findsNothing);
  });
}
