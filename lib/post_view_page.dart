import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'src/client.dart';

class PostViewPage extends StatelessWidget {
  PostViewPage({Key key, @required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post")),
      body: Center(child: Text("TODO"))
    );
  }
}