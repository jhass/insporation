import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'contacts_page.dart';
import 'conversations_page.dart';
import 'edit_profile_page.dart';
import 'new_conversation_page.dart';
import 'notifications_page.dart';
import 'post_view_page.dart';
import 'profile_page.dart';
import 'publisher_page.dart';
import 'search_page.dart';
import 'sign_in_page.dart';
import 'src/app_auth.dart';
import 'src/client.dart';
import 'src/colors.dart' as colors;
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/persistence.dart';
import 'src/posts.dart';
import 'stream_page.dart';

final navigator = GlobalKey<NavigatorState>();
final globalProviders = [
    Provider(create: (_) => PersistentState()..restore(), dispose: (_, PersistentState state) => state.persist(), lazy: false),
    Provider(create: (_) => Client()),
    ChangeNotifierProxyProvider<Client, UnreadNotificationsCount>(
    create: (context) => UnreadNotificationsCount(),
    update: (context, client, count) => count!..update(client)
  ),
  ChangeNotifierProxyProvider<Client, UnreadConversationsCount>(
    create: (context) => UnreadConversationsCount(),
    update: (context, client, count) => count!..update(client)
  ),
  ProxyProvider2<UnreadNotificationsCount, UnreadConversationsCount, BadgeUpdater>(
    create: (context) => BadgeUpdater(),
    update: (context, notificationsCount, conversationsCount, updater) => updater!
      ..listenToNotifications(notificationsCount)
      ..listenToConversations(conversationsCount),
    lazy: false
  ),
  ChangeNotifierProvider(create: (_) => CurrentNavigationItemReselectedEvents())
];

class Insporation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InsporationState();
}

class _InsporationState extends State<Insporation> {
  final _shareEventsChannel = EventChannel("insporation/share_receiver");
  StreamSubscription? shareEventsSubscription;
  StreamSubscription? sessionEventsSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // We need to give the MaterialApp widget some time to initialize the navigator and push the initial route,
      // as we want for any share event to only push a route after that.
      shareEventsSubscription = _shareEventsChannel.receiveBroadcastStream().listen(_onShareIntent);

      // same for pushing a new route in response to a new session
      sessionEventsSubscription = context.read<Client>().newAuthorizations.listen(_onAuthorizationEvent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    shareEventsSubscription?.cancel();
    sessionEventsSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigator,
      title: 'insporation*',
      theme: colors.theme,
      darkTheme: colors.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      builder: (context, child) => SafeArea(child: child!),
      home: SignInPage(),
      routes: {
        '/switch_user': (context) => SignInPage(resumeLastSession: false),
        '/stream': (context) {
          final options = ModalRoute.of(context)?.settings.arguments as StreamOptions?;
          final lastOptions = context.watch<PersistentState>().lastStreamOptions;
          return StreamPage(options: options ?? lastOptions ?? const StreamOptions());
        },
        '/stream/tag': (context) {
          final tag = ModalRoute.of(context)?.settings.arguments as String?;
          assert(tag != null, "Can't push tag stream without tag argument");
          return StreamPage(options: StreamOptions(type: StreamType.tag, tag: tag!));
        },
        '/conversations': (context) => ConversationsPage(),
        '/conversations/new': (context) => NewConversationPage(options: ModalRoute.of(context)?.settings.arguments as NewConversationOptions? ?? NewConversationOptions()),
        '/search': (context) => SearchPage(),
        '/notifications': (context) => NotificationsPage(),
        '/contacts': (context) => ContactsPage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/post': (context) {
          final argument = ModalRoute.of(context)?.settings.arguments;
          if (argument is Post) {
            return PostViewPage.forPost(post: argument);
          } else if (argument is String) {
            return PostViewPage.forId(postId: argument);
          } else {
            throw "Unsupported argument type or null";
          }
        },
        '/profile': (context) {
          final argument = ModalRoute.of(context)?.settings.arguments;
          if (argument is Person) {
            return ProfilePage.forPerson(person: argument);
          } else if (argument is String) {
            if (argument.contains('@')) {
              return ProfilePage.forDiasporaId(diasporaId: argument);
            } else {
              return ProfilePage.forId(personId: argument);
            }
          } else {
            throw "Unsupported argument type or null";
          }
        }
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/publisher':
            return MaterialPageRoute<Post?>(
              builder: (context) => PublisherPage(options: settings.arguments as PublisherOptions? ?? PublisherOptions()),
              settings: settings
            );
        }
      },
    );
  }

  void _onShareIntent(event) async {
    if (event is! Map) {
      return;
    }

    final shareEvent = event.cast<String, dynamic>();

    if (!shareEvent.containsKey("type")) {
        return;
    }

    // Wait for sign in page to push its route
    await context.read<Client>().waitForActiveSession();

    if (!mounted) {
      return;
    }

    switch (shareEvent["type"]) {
      case "text":
        final subject = shareEvent["subject"]?.isNotEmpty == true ? shareEvent["subject"] : null,
          text = shareEvent["text"] as String,
          prefill = subject == null ? text : text.startsWith("http") && !text.contains(RegExp(r"\s")) ? "[$subject]($text)" : "### $subject\n\n$text";
        navigator.currentState?.pushNamed("/publisher", arguments: PublisherOptions(prefill: prefill));
        break;
      case "images":
        final text = shareEvent["text"]?.isNotEmpty == true ? shareEvent["text"] : "";
        navigator.currentState?.pushNamed("/publisher", arguments: PublisherOptions(
          prefill: text,
          images: shareEvent["images"].cast<String>()
        ));
        break;
    }
  }

  void _onAuthorizationEvent(AuthorizationEvent event) {
    if (event.error != null) {
      // We got an authorization error from somewhere, show sign in page with it
      debugPrint("Received authorization event for error: ${event.error}, launching sign page with it");
      navigator.currentState?.pushAndRemoveUntil(PageRouteBuilder(pageBuilder: (context, _, __) =>
        SignInPage(error: event.error!)), (_) => false);
    } else {
      // We got a new session from somewhere and it's different from the one we already got in the client,
      // assume this is a successful authorization and proceed to stream page
      debugPrint("Received authorization event for session for ${event.session?.userId}, launching main stream");
      navigator.currentState?.pushNamedAndRemoveUntil("/stream", (_) => false);
    }
  }
}
