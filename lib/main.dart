import 'package:flutter/material.dart';
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

class Insporation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
}
