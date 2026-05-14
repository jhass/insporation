import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/l10n/app_localizations.dart';
import 'package:insporation/notifications_page.dart';
import 'package:insporation/src/client.dart';
import 'package:insporation/src/localizations.dart';
import 'package:insporation/src/navigation.dart';
import 'package:insporation/src/timeago.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() {
  testWidgets('notifications page shows relative timestamps', (tester) async {
    final createdAt = DateTime.now().subtract(const Duration(hours: 2));
    final notification = Notification(
      guid: 'notification-1',
      type: NotificationType.liked,
      read: true,
      targetGuid: 'post-1',
      targetAuthor: null,
      eventCreators: [
        Person(
          guid: 'person-1',
          diasporaId: 'alice@example.org',
          name: 'Alice',
          avatar: null,
        ),
      ],
      createdAt: createdAt,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Client>.value(value: _FakeClient([notification])),
          ChangeNotifierProvider(create: (_) => CurrentNavigationItemReselectedEvents()),
          ChangeNotifierProvider(create: (_) => UnreadNotificationsCount()),
          ChangeNotifierProvider(create: (_) => UnreadConversationsCount()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: supportedLocales,
          home: NotificationsPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    Timeago.loadLocale(const Locale('en'));

    expect(find.textContaining('Alice'), findsOneWidget);
    expect(find.text(timeago.format(createdAt, locale: 'en')), findsOneWidget);
    expect(find.byType(Timeago), findsOneWidget);
  });
}

class _FakeClient extends Client {
  _FakeClient(this.notifications);

  final List<Notification> notifications;

  @override
  Future<Page<Notification>> fetchNotifications({bool onlyUnread = false, String? page, int? perPage}) async =>
      Page(content: notifications);
}
