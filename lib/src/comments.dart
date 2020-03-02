import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'composer.dart';
import 'item_stream.dart';
import 'messages.dart';
import 'search.dart';
import 'timeago.dart';
import 'utils.dart';

class CommentStream extends ItemStream<Comment> {
  CommentStream(this.post);

  final Post post;

  @override
  Future<Page<Comment>> loadPage({Client client, String page}) =>
    client.fetchComments(post, page: page);
}

class CommentListView extends StatefulWidget {
  CommentListView({Key key, @required this.post, this.controller}) : super(key: key);

  final Post post;
  final ScrollController controller;

  @override
  State<StatefulWidget> createState() => CommentListViewState();
}

class CommentListViewState extends ItemStreamState<Comment, CommentListView> {
  CommentListViewState() : super(enableUpButton: false);

  @override
  ScrollController get scrollController => widget.controller ?? super.scrollController;

  @override
  ItemStream<Comment> createStream() => CommentStream(widget.post);

  @override
  Widget buildItem(BuildContext context, Comment item) =>
    CommentView(comment: item);

  @override
  Widget buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(l.commentsHeader, style: TextStyle(fontSize: 18)),
  );

  @override
  Widget buildFooter(BuildContext context, String lastError) => lastError != null ?
    super.buildFooter(context, lastError) : ConstrainedBox(
    constraints: BoxConstraints(maxHeight: 400),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: SimpleComposer(
        submitButtonContent: Text(l.createComment),
        mentionablePeople: _mentionablePeople(),
        onSubmit: _insertComment,
      ),
    ),
  );

  SearchablePeople _mentionablePeople() {
    if (widget.post.public) {
      return SearchablePeople.all();
    } else if (items == null) {
      return SearchablePeople.none();
    } else {
      return SearchablePeople.list(
        (items as CommentStream).map((comment) => comment.author).toSet().toList()
      );
    }
  }

  Future<bool> _insertComment(String value) async {
    final client = Provider.of<Client>(context, listen: false);

    try {
      final comment = await client.commentPost(widget.post, value);
      items.add(comment);
       // TODO invalidate other widgets depending on the post
      widget.post.interactions.comments++;
      widget.post.interactions.subscribed = true;
      return true;
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToCommentOnPost, e, s);
      return false;
    }
  }
}

class CommentView extends StatelessWidget {
  CommentView({Key key, @required this.comment}) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: PersonHeader(person: comment.author)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Timeago(comment.createdAt, textStyle: TextStyle(fontSize: 10))
              )
            ],
          ),
          Divider(),
          Message(body: comment.body, mentionedPeople: comment.mentionedPeople)
        ],
      ),
    ),
  );
}
