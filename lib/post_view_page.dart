import 'package:flutter/material.dart';

import 'src/client.dart';

class PostViewPage extends StatefulWidget {
  PostViewPage({Key key, this.post, @required this.postId}) {
    if (post != null && postId != null && post.guid != postId) {
      throw "Conflicting post and post id given!";
    } else if (post == null && postId == null) {
      throw "No post or post id given!";
    }
  }

  factory PostViewPage.forPost({Key key, @required Post post}) =>
    PostViewPage(key: key, post: post, postId: post.guid);

  factory PostViewPage.forId({Key key, @required String postId}) =>
    PostViewPage(key: key, postId: postId);

  final String postId;
  final Post post;

  @override
  State<StatefulWidget> createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Post ${widget.postId}")),
      body: Center(child: Text("TODO"))
    );
  }
}