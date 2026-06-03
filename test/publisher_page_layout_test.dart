import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/l10n/app_localizations.dart';
import 'package:insporation/publisher_page.dart';
import 'package:insporation/src/client.dart';
import 'package:insporation/src/localizations.dart';
import 'package:insporation/src/persistence.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('publish button is placed below target selector', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Client>.value(value: Client()),
          Provider<PersistentState>.value(value: PersistentState()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          home: PublisherPage(),
        ),
      ),
    );

    await tester.pump();

    final publishButton = find.byWidgetPredicate((widget) => widget is ElevatedButton && widget.onPressed == null);
    final targetButton = find.byWidgetPredicate((widget) => widget is ElevatedButton && widget.onPressed != null);

    expect(publishButton, findsOneWidget);
    expect(targetButton, findsOneWidget);
    expect(tester.getTopLeft(publishButton).dy, greaterThan(tester.getTopLeft(targetButton).dy));
  });
}
