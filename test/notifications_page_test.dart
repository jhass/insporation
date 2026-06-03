import 'package:flutter/material.dart' hide Notification, Page;
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
    Timeago.loadLocale(const Locale('en'));
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
          Provider<Client>.value(value: TestClient([notification])),
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

    expect(find.textContaining('Alice'), findsOneWidget);
    expect(find.text(timeago.format(createdAt, locale: 'en')), findsOneWidget);
    expect(find.byType(Timeago), findsOneWidget);
  });

  testWidgets('notifications page shows post body preview', (tester) async {
    final createdAt = DateTime.now().subtract(const Duration(hours: 1));
    Timeago.loadLocale(const Locale('en'));

    final author = Person(
      guid: 'person-1',
      diasporaId: 'alice@example.org',
      name: 'Alice',
      avatar: null,
    );
    final post = Post(
      guid: 'post-1',
      type: PostType.status,
      body: '**Hello** from the *test post*!',
      author: author,
      public: true,
      nsfw: false,
      root: null,
      photos: [],
      poll: null,
      mentionedPeople: {},
      interactions: PostInteractions(),
      oEmbed: null,
      openGraphObject: null,
      location: null,
      createdAt: createdAt,
      ownPost: false,
      mock: false,
    );
    final notification = Notification(
      guid: 'notification-2',
      type: NotificationType.liked,
      read: true,
      targetGuid: 'post-1',
      targetAuthor: author,
      eventCreators: [author],
      createdAt: createdAt,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Client>.value(value: TestClient([notification], post: post)),
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

    expect(find.text('Hello from the test post!'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
    expect(find.textContaining('*'), findsNothing);
  });
}

class TestClient extends Client {
  TestClient(this.notifications, {this.post});

  final List<Notification> notifications;
  final Post? post;

  @override
  Future<Page<Notification>> fetchNotifications({bool onlyUnread = false, String? page, int? perPage}) async =>
      Page(content: notifications);

  @override
  Future<Post> fetchPost(String guid) async {
    final p = post;
    if (p != null) return p;
    throw UnsupportedError('No test post configured');
  }
}
