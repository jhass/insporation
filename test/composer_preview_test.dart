import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/src/composer.dart';
import 'package:insporation/src/messages.dart';

void main() {
  testWidgets('composer can toggle rendered preview', (tester) async {
    final controller = TextEditingController(text: '**hello**');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: Composer(controller: controller),
          ),
        ),
      ),
    );

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(Message), findsNothing);
    expect(find.byIcon(Icons.format_bold), findsOneWidget);

    await tester.tap(find.byIcon(Icons.preview).first);
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(Message), findsOneWidget);
    expect(find.byIcon(Icons.format_bold), findsNothing);
    expect(tester.widget<Message>(find.byType(Message)).body, '**hello**');

    controller.text = '*updated*';
    await tester.pumpAndSettle();
    expect(tester.widget<Message>(find.byType(Message)).body, '*updated*');

    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.byType(Message), findsNothing);
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
  });
}
