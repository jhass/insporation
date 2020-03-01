import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app_auth.dart';
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

class PersistentState {
  static const _key = "persistent_state";

  bool _restored = false;

  bool _wasAuthorizing = false;

  bool get wasAuthorizing => _wasAuthorizing;

  set wasAuthorizing(bool value) {
    _wasAuthorizing = value;
    persist();
  }

  Future<void> restore() async {
    if (_restored) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_key)) {
      final values = jsonDecode(prefs.getString(_key));
      _wasAuthorizing = values["was_authorizing"];
    }

    _restored = true;
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({"was_authorizing": wasAuthorizing}));
  }
}

void main() => runApp(MultiProvider(
  providers: [
    Provider(create: (_) => PersistentState()..restore(), dispose: (_, state) => state.persist(), lazy: false),
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
  StreamSubscription sessionEventsSubscription;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We need to give the MaterialApp widget some time to initialize the navigator and push the initial route,
      // as we want for any share event to only push a route after that.
      shareEventsSubscription = _shareEventsChannel.receiveBroadcastStream().listen(_onShareIntent);

      // same for pushing a new route in response to a new session
      sessionEventsSubscription = Provider.of<Client>(context, listen: false).newAuthorizations.listen(_onAuthorizationEvent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    shareEventsSubscription.cancel();
    sessionEventsSubscription.cancel();
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

  void _onAuthorizationEvent(AuthorizationEvent event) {
    if (event.error != null) {
      // We got an authorization error from somewhere, show sign in page with it
      debugPrint("Received authorization event for error: ${event.error}, launching sign page with it");
      _navigator.currentState.pushAndRemoveUntil(PageRouteBuilder(pageBuilder: (context, _, __) =>
        SignInPage(error: event.error)), (_) => false);
    } else {
      // We got a new session from somewhere and it's different from the one we already got in the client,
      // assume this is a successful authorization and proceed to stream page
      debugPrint("Received authorization event for session for ${event.session.userId}, launching main stream");
      _navigator.currentState.pushNamedAndRemoveUntil("/stream/main", (_) => false);
    }
  }
}
