import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

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
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/persistence.dart';
import 'src/posts.dart';
import 'stream_page.dart';

const _skipableErrors = <String>[
  // Non fatal and nothing we can handle in any way
  'Invalid image data',
  // Probably just a failed image load or so. Critical API errors should have been catched or at least rewrapped.
  'HttpException',
  'HTTP request failed, statusCode: 4',
  // Probably the video player didn't like a broken URL in the poster attribute some platforms send us,
  // or the image proxy didn't like to proxy us that video
  'PlatformException(VideoError',
  // System was probably switching networks or so, nothing we can do anything about
  'SocketException',
  'Connection closed before full header was received',
  'Connection closed while receiving data',
  // Suppress non-fatal framework bug. Should be fixed with https://github.com/flutter/flutter/pull/70638
  "NoSuchMethodError: The getter 'status' was called on null",
  // Not much we can do about bad setups
  'CERTIFICATE_VERIFY_FAILED'
];
final _navigator = GlobalKey<NavigatorState>(),
  _skipReportMode = SilentReportMode(),
  _skipErrorHandler = ConsoleHandler(
  enableApplicationParameters: false,
  enableDeviceParameters: false,
  enableStackTrace: false
);
final Map<String, ReportMode> _explicitErrorReportMode =
  Map.fromIterable(_skipableErrors, value: (_) => _skipReportMode);
final Map<String, ReportHandler> _explicitErrorHandler =
  Map.fromIterable(_skipableErrors, value: (_) => _skipErrorHandler);

void main() => Catcher(
  MultiProvider(
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
      ),
      ChangeNotifierProvider(create: (_) => CurrentNavigationItemReselectedEvents())
    ],
    child: Insporation(),
  ),
  debugConfig: CatcherOptions(
    SilentReportMode(),
    [ConsoleHandler()],
    explicitExceptionReportModesMap: _explicitErrorReportMode,
    explicitExceptionHandlersMap: _explicitErrorHandler,
    localizationOptions: catcherLocalizationOptions
  ),
  releaseConfig: CatcherOptions(
    DialogReportMode(),
    [EmailManualHandler(['insporation-bugs@jhass.eu'], emailTitle: "insporation* crash report")],
    explicitExceptionReportModesMap: _explicitErrorReportMode,
    explicitExceptionHandlersMap: _explicitErrorHandler,
    localizationOptions: catcherLocalizationOptions
  ),
  navigatorKey: _navigator
);

class Insporation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InsporationState();
}

class _InsporationState extends State<Insporation> {
  final _shareEventsChannel = EventChannel("insporation/share_receiver");
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
      sessionEventsSubscription = context.read<Client>().newAuthorizations.listen(_onAuthorizationEvent);
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
      localizationsDelegates: [
        InsporationLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: supportedLocales,
      home: SignInPage(),
      routes: {
        '/switch_user': (context) => SignInPage(resumeLastSession: false),
        '/stream': (context) {
          final StreamOptions options = ModalRoute.of(context).settings.arguments;
          final lastOptions = context.watch<PersistentState>().lastStreamOptions;
          return StreamPage(options: options ?? lastOptions ?? const StreamOptions());
        },
        '/stream/tag': (context) {
          final String tag = ModalRoute.of(context).settings.arguments;
          assert(tag != null, "Can't push tag stream without tag argument");
          return StreamPage(options: StreamOptions(type: StreamType.tag, tag: tag));
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
        _navigator.currentState.pushNamed("/publisher", arguments: PublisherOptions(prefill: prefill));
        break;
      case "images":
        final text = shareEvent["text"]?.isNotEmpty == true ? shareEvent["text"] : "";
        _navigator.currentState.pushNamed("/publisher", arguments: PublisherOptions(
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
      _navigator.currentState.pushAndRemoveUntil(PageRouteBuilder(pageBuilder: (context, _, __) =>
        SignInPage(error: event.error)), (_) => false);
    } else {
      // We got a new session from somewhere and it's different from the one we already got in the client,
      // assume this is a successful authorization and proceed to stream page
      debugPrint("Received authorization event for session for ${event.session.userId}, launching main stream");
      _navigator.currentState.pushNamedAndRemoveUntil("/stream", (_) => false);
    }
  }
}
