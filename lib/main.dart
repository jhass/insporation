import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'contacts_page.dart';
import 'conversations_page.dart';
import 'edit_profile_page.dart';
import 'notifications_page.dart';
import 'post_view_page.dart';
import 'profile_page.dart';
import 'publisher_page.dart';
import 'search_page.dart';
import 'src/client.dart';
import 'sign_in_page.dart';
import 'src/notifications.dart';
import 'src/posts.dart';
import 'stream_page.dart';

void main() => runApp(MultiProvider(
  providers: [
    Provider(create: (_) => Client()),
    ChangeNotifierProxyProvider<Client, UnreadNotificationsCount>(
      create: (context) => UnreadNotificationsCount(),
      update: (context, client, count) => count..update(client)
    )
  ],
  child: Insporation(),
));

class Insporation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'insporation*',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent
      ),
      home: SignInPage(),
      routes: {
        '/switch_user': (context) => SignInPage(resumeLastSession: false),
        '/stream/main': (context) => StreamPage(type: StreamType.main),
        '/stream/activity': (context) => StreamPage(type: StreamType.activity),
        '/stream/tag': (context) {
          final String tag = ModalRoute.of(context).settings.arguments;
          return StreamPage(type: StreamType.tag, tag: tag);
        },
        '/publisher': (context) => PublisherPage(),
        '/conversations': (context) => ConversationsPage(),
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
            return ProfilePage.forId(personId: argument);
          } else {
            throw "Unsupported argument type";
          }
        }
      },
    );
  }
}
