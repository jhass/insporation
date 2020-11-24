import 'package:flutter/material.dart' hide Page;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'composer.dart';
import 'item_stream.dart';
import 'localizations.dart';
import 'messages.dart';
import 'persistence.dart';
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
  final _newComment = TextEditingController();
  DraftObserver _draftObserver;

  CommentListViewState() : super(enableUpButton: false);

  @override
  void initState() {
    super.initState();

    final state = context.read<PersistentState>();
    _newComment.text = state.getCommentDraft(widget.post) ?? "";
    _draftObserver = DraftObserver(context: context, controller: _newComment, onPersist: (text) =>
      state.setCommentDraft(widget.post, text));
  }

  @override
  ScrollController get scrollController => widget.controller ?? super.scrollController;

  @override
  ItemStream<Comment> createStream() => CommentStream(widget.post);

  @override
  Widget buildItem(BuildContext context, Comment comment) =>
    CommentView(comment: comment);

  @override
  Widget buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(l.commentsHeader, style: TextStyle(fontSize: 18)),
  );

  @override
  Widget buildFooter(BuildContext context, String lastError, String lastErrorDetails) => lastError != null ?
    super.buildFooter(context, lastError, lastErrorDetails) : ConstrainedBox(
    constraints: BoxConstraints(maxHeight: 400),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: SimpleComposer(
        controller: _newComment,
        submitButtonContent: Text(l.createComment),
        mentionablePeople: _mentionablePeople(),
        onSubmit: _insertComment,
      ),
    ),
  );

  @override
  void dispose() {
    _draftObserver?.dispose();
    _newComment.dispose();
    super.dispose();
  }

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
    final client = context.read<Client>(),
      state = context.read<PersistentState>();

    try {
      final comment = await client.commentPost(widget.post, value);
      items.add(comment);
      state.clearCommentDraft(widget.post);
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
  Widget build(BuildContext context) {
    if (comment.canDelete || !comment.reported) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actions: [
          _CommentActionsView(comment: comment)
        ],
        child: buildComment(),
      );
    } else {
      return buildComment();
    }
  }

  Card buildComment() {
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


class _CommentActionsView extends StatefulWidget {
  _CommentActionsView({Key key, this.comment}) : super(key: key);

  final Comment comment;

  @override
  _CommentActionsViewState createState() => _CommentActionsViewState();
}

class _CommentActionsViewState extends State<_CommentActionsView> with StateLocalizationHelpers {
  final _reportField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (widget.comment.canDelete) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        tooltip: ml.deleteButtonTooltip,
        onPressed: _promptDelete
      ));
    } else if (!widget.comment.reported) {
      actions.add(IconButton(
        icon: Icon(Icons.flag),
        tooltip: l.reportComment,
        onPressed: _promptReport,
      ));
    }

    return Column(children: actions);
  }

  _promptDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.deleteCommentPrompt),
        actions: <Widget>[
          FlatButton(
            child: Text(l.noButtonLabel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FlatButton(
            child: Text(l.yesButtonLabel),
            onPressed: () {
              _delete();
              Navigator.pop(dialogContext);
            },
          )
        ],
      )
    );
  }

  _delete() async {
    final client = context.read<Client>(),
      items = context.tryRead<ItemStream<Comment>>();
    int oldPosition = 0;

    if (items != null) {
      oldPosition = items.remove(widget.comment);
    }

    try {
      await client.deleteComment(widget.comment);
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToDeleteComment, e, s);
      if (items != null) {
        items.insert(oldPosition, widget.comment);
      }
    }
  }

  _promptReport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.reportCommentPrompt),
        content: TextField(
          controller: _reportField,
          minLines: 1,
          decoration: InputDecoration(
            hintText: l.reportCommentHint
          )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(ml.cancelButtonLabel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FlatButton(
            child: Text(l.submitButtonLabel),
            onPressed: () {
              if (_reportField.text.isNotEmpty) {
                _createReport(_reportField.text);
                Navigator.pop(dialogContext);
              }
            },
          )
        ],
      )
    );
  }

  _createReport(String report) async {
    final scaffold = Scaffold.of(context),
      client = context.read<Client>();
    setState(() => widget.comment.reported = true);
    Slidable.of(context)?.close();

    try {
      await client.reportComment(widget.comment, report);

      if (scaffold.mounted) {
        scaffold.showSnackBar(SnackBar(
          content: Text(l.sentCommentReport)
        ));
      }
    } catch(e, s) {
      tryShowErrorSnackBar(this, l.failedToReportComment, e, s);

      widget.comment.reported = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}
