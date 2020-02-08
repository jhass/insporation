import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'error_message.dart';
import 'messages.dart';

class CommentSheet extends StatefulWidget {
  CommentSheet({Key key, @required this.post}) : super(key: key);

  final Post post;

  @override
  State<StatefulWidget> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  var _loading = true;
  String _lastError;
  Page<Comment> _lastPage;
  List<Comment> _comments;
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();

    _listScrollController.addListener(() {
      if (_listScrollController.offset >= _listScrollController.position.maxScrollExtent - 200) {
        _fetchMoreComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        controller: _listScrollController,
        itemCount: _comments != null ? _comments.length + 2 : 2,
        itemBuilder: (context, position) =>
          position == 0 ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Comments", style: TextStyle(fontSize: 18)),
              ),
              ErrorMessage(_lastError)
            ]
          ) :
          _comments == null || position > _comments.length ?
            Visibility(
              visible: _loading,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator())
              ),
            ) :
            CommentView(comment: _comments[position - 1])
      ),
    );
  }

  _fetchMoreComments() {
    if (_loading == null || _lastPage == null || _lastPage.nextPage == null) {
      return;
    }

    _fetchComments(page: _lastPage.nextPage);
  }

  _fetchComments({page}) async {
    setState(() {
      _lastError = null;
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false),
        newComments = await client.fetchComments(widget.post, page: page);

      setState(() {
        _loading = false;
        _lastPage = newComments;
        if (_comments == null || page == null) {
          _comments = newComments.content;
        } else {
          _comments.addAll(newComments.content);
        }
      });
    } catch (e, s) {
      setState(() {
        debugPrintStack(label: e.toString(), stackTrace: s);
        _lastError = e.toString();
        _loading = false;
      });
    }

  }
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
            PersonHeader(person: comment.author),
            Divider(),
            Message(body: comment.body, mentionedPeople: comment.mentionedPeople)
          ],
        ),
      ),
    );
  }

}