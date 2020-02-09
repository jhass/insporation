import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/comments.dart';
import 'src/client.dart';
import 'src/error_message.dart';
import 'src/messages.dart';
import 'src/posts.dart';

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
  Post _post;
  String _lastError;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _post = widget.post;
    } else {
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _loading ? Center(child: CircularProgressIndicator()) :
        _lastError != null ? Center(child: ErrorMessage(_lastError)) :
           _PostWithCommentsView(post: _post)
    );
  }

  bool get _loading => _post == null && _lastError == null;

  _fetch() async {
    final client = Provider.of<Client>(context, listen: false);

    try {
      final post = await client.fetchPost(widget.postId);
      if (mounted) {
        setState(() => _post = post);
      }
    } catch(e, s) {
      debugPrintStack(label: e.message, stackTrace: s);

      if (mounted) {
        setState(() => _lastError = e.message);
      }
    }
  }
}

class _PostWithCommentsView extends CommentListView {
  _PostWithCommentsView({Post post}) : super(post: post);

  @override
  State<StatefulWidget> createState() => _PostWithCommentsViewState();
}

class _PostWithCommentsViewState extends CommentListViewState {
  final ShowNsfwPosts _showNsfwPosts = ShowNsfwPosts(initial: true); // TODO make optional in PostView?

  @override
  Widget buildHeader(BuildContext context, String lastError) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ChangeNotifierProvider.value(
          value: _showNsfwPosts,
          child: PostView(post: widget.post, enableCommentsSheet: false),
        ),
        super.buildHeader(context, lastError)
      ],
    );

  @override
  void dispose() {
    _showNsfwPosts.dispose();
    super.dispose();
  }
}