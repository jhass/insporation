import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';

import 'src/comments.dart';
import 'src/client.dart';
import 'src/posts.dart';
import 'src/widgets.dart';
import 'src/item_stream.dart';

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
        _lastError != null ? Center(child: ErrorMessage(_lastError, onRetry: _fetch)) :
           _PostWithInteractionsView(post: _post)
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

class _LikesStream extends TransformingItemStream<Like, Person> {
  _LikesStream({@required this.post});

  final Post post;

  @override
  Future<Page<Like>> loadSourcePage({Client client, String page}) =>
    client.fetchLikes(post, page: page);

  @override
  Person transform(Like like) => like.author;
}

class _ResharesStream extends TransformingItemStream<ReshareReference, Person> {
  _ResharesStream({@required this.post});

  final Post post;

  @override
  Future<Page<ReshareReference>> loadSourcePage({Client client, String page}) =>
    client.fetchReshares(post, page: page);

  @override
  Person transform(ReshareReference reshare) => reshare.author;
}

class _PostWithInteractionsView extends CommentListView {
  _PostWithInteractionsView({Post post}) : super(post: post);

  @override
  State<StatefulWidget> createState() => _PostWithInteractionsViewState();
}

class _PostWithInteractionsViewState extends CommentListViewState {
  _LikesStream _likes;
  _ResharesStream _reshares;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final client = Provider.of<Client>(context, listen: false);

    if (_likes == null || _likes.post != widget.post) {
      _likes = _LikesStream(post: widget.post);
      _likes.loadAll(client);
    }

    if (_reshares == null || _reshares.post != widget.post) {
      _reshares = _ResharesStream(post: widget.post);
      _reshares.loadAll(client);
    }
  }

  @override
  Widget buildHeader(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(alignment: Alignment.topRight, child: PostActionsView(post: widget.post, orientation: Axis.horizontal)),
          PostView(post: widget.post, enableCommentsSheet: false, limitHeight: false),
          _ListPeopleView(people: _likes, header: l.likesHeader),
          _ListPeopleView(people: _reshares, header: l.resharesHeader),
        ],
      ),
      super.buildHeader(context)
    ],
  );
}

class _ListPeopleView extends StatelessWidget {
  _ListPeopleView({Key key, @required this.people, @required this.header}) : super(key: key);

  final ItemStream<Person> people;
  final String header;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: people,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(visible: people.length > 0,child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(header, style: TextStyle(fontSize: 18)),
          )),
          Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            children: people.map((person) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Tooltip(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/profile", arguments: person),
                  child: Avatar(person: person)
                ),
                message: person.nameOrId),
            )).toList()
          ),
        ],
      ),
    );
  }
}

