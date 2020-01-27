import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'sign_in_page.dart';
import 'stream_page.dart';

void main() => runApp(MultiProvider(
  providers: [
    Provider(create: (_) => Client())
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
        }
      },
    );
  }
}
