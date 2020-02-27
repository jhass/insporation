import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'src/colors.dart' as colors;
import 'contacts_page.dart';
import 'conversations_page.dart';
import 'edit_profile_page.dart';
import 'new_conversation_page.dart';
import 'notifications_page.dart';
import 'post_view_page.dart';
import 'profile_page.dart';
import 'publisher_page.dart';
import 'search_page.dart';
import 'src/client.dart';
import 'sign_in_page.dart';
import 'src/navigation.dart';
import 'src/posts.dart';
import 'stream_page.dart';

void main() => runApp(MultiProvider(
  providers: [
    Provider(create: (_) => Client()),
    ChangeNotifierProxyProvider<Client, UnreadNotificationsCount>(
      create: (context) => UnreadNotificationsCount(),
      update: (context, client, count) => count..update(client)
    ),
    ChangeNotifierProxyProvider<Client, UnreadConversationsCount>(
      create: (context) => UnreadConversationsCount(),
      update: (context, client, count) => count..update(client)
    ),
    ProxyProvider2<UnreadNotificationsCount, UnreadConversationsCount, BadgeUpdater>(
      create: (context) => BadgeUpdater(),
      update: (context, notificationsCount, conversationsCount, updater) => updater
        ..listenToNotifications(notificationsCount)
        ..listenToConversations(conversationsCount),
      lazy: false
    )
  ],
  child: Insporation(),
));

class Insporation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InsporationState();
}

class _InsporationState extends State<Insporation> {
  final _shareEventsChannel = EventChannel("insporation/share_receiver");
  final _navigator = GlobalKey<NavigatorState>();
  StreamSubscription shareEventsSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We need to give the MaterialApp widget some time to initialize the navigator and push the initial route,
      // as we want for any share event to only push a route after that.
      shareEventsSubscription = _shareEventsChannel.receiveBroadcastStream().listen(_onShareIntent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    shareEventsSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigator,
      title: 'insporation*',
      theme: ThemeData.from(colorScheme: colors.scheme),
      darkTheme: ThemeData.from(colorScheme: colors.darkScheme),
      home: SignInPage(),
      routes: {
        '/switch_user': (context) => SignInPage(resumeLastSession: false),
        '/stream/main': (context) => StreamPage(type: StreamType.main),
        '/stream/activity': (context) => StreamPage(type: StreamType.activity),
        '/stream/aspects': (context) {
          final List<Aspect> aspects = ModalRoute.of(context).settings.arguments;
          return StreamPage(type: StreamType.aspects, aspects: aspects);
        },
        '/stream/mentions': (context) => StreamPage(type: StreamType.mentions),
        '/stream/followedTags': (context) => StreamPage(type: StreamType.followedTags),
        '/stream/liked': (context) => StreamPage(type: StreamType.liked),
        '/stream/commented': (context) => StreamPage(type: StreamType.commented),
        '/stream/tag': (context) {
          final String tag = ModalRoute.of(context).settings.arguments;
          return StreamPage(type: StreamType.tag, tag: tag);
        },
        '/publisher': (context) => PublisherPage(options: ModalRoute.of(context).settings.arguments ?? PublisherOptions()),
        '/conversations': (context) => ConversationsPage(),
        '/conversations/new': (context) => NewConversationPage(options: ModalRoute.of(context).settings.arguments ?? NewConversationOptions()),
        '/search': (context) => SearchPage(),
        '/notifications': (context) => NotificationsPage(),
        '/contacts': (context) => ContactsPage(),
        '/edit_profile': (context) => EditProfilePage(),
        '/post': (context) {
          final argument = ModalRoute.of(context).settings.arguments;
          if (argument is Post) {
            return PostViewPage.forPost(post: argument);
          } else if (argument is String) {
            return PostViewPage.forId(postId: argument);
          } else {
            throw "Unsupported argument type";
          }
        },
        '/profile': (context) {
          final argument = ModalRoute.of(context).settings.arguments;
          if (argument is Person) {
            return ProfilePage.forPerson(person: argument);
          } else if (argument is String) {
            if (argument.contains('@')) {
              return ProfilePage.forDiasporaId(diasporaId: argument);
            } else {
              return ProfilePage.forId(personId: argument);
            }
          } else {
            throw "Unsupported argument type";
          }
        }
      },
    );
  }

  void _onShareIntent(event) {
    if (event is! Map) {
      return;
    }

    final shareEvent = event.cast<String, dynamic>();

    if (!shareEvent.containsKey("type")) {
        return;
    }

    switch (shareEvent["type"]) {
      case "text":
        final subject = shareEvent["subject"]?.isNotEmpty == true ? shareEvent["subject"] : null,
          text = shareEvent["text"] as String,
          prefill = subject == null ? text : text.startsWith("http") && !text.contains(RegExp(r"\s")) ? "[$subject]($text)" : "### $subject\n\n$text";
        _navigator.currentState.pushNamed("/publisher", arguments: PublisherOptions(prefill: prefill));
        break;
      case "images":
        _navigator.currentState.pushNamed("/publisher", arguments: PublisherOptions(
          images: shareEvent["images"].cast<String>()
        ));
        break;
    }
  }
}
