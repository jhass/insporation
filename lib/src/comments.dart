import 'package:flutter/material.dart';
import 'package:insporation/src/item_stream.dart';
import 'package:insporation/src/timeago.dart';

import 'client.dart';
import 'error_message.dart';
import 'messages.dart';

class CommentStream extends ItemStream<Comment> {
  CommentStream(this.post);

  final Post post;

  @override
  Future<Page<Comment>> loadPage({Client client, String page}) =>
    client.fetchComments(post, page: page);
}

class CommentListView extends StatefulWidget {
  CommentListView({Key key, @required this.post}) : super(key: key);

  final Post post;

  @override
  State<StatefulWidget> createState() => CommentListViewState();
}

class CommentListViewState extends ItemStreamState<Comment, CommentListView> {
  CommentListViewState() : super(enableUpButton: false);

  @override
  ItemStream<Comment> createStream() => CommentStream(widget.post);

  @override
  Widget buildItem(BuildContext context, Comment item) =>
    CommentView(comment: item);

  @override
  Widget buildHeader(BuildContext context, String lastError) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text("Comments", style: TextStyle(fontSize: 18)),
      ),
      ErrorMessage(lastError)
    ]
  );
}

class CommentView extends StatelessWidget {
  CommentView({Key key, @required this.comment}) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
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

}