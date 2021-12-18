import 'package:flutter/material.dart' hide Page, NavigationBar;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/item_stream.dart';
import 'src/messages.dart';
import 'src/navigation.dart';
import 'src/persistence.dart';
import 'src/search.dart';
import 'src/timeago.dart';
import 'src/utils.dart';
import 'src/widgets.dart';
import 'src/colors.dart' as colors;

class ConversationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConversationsPageState();
}

class _ConversationsStream extends ItemStream<Conversation> {
  @override
  Future<Page<Conversation>> loadPage({required Client client, String? page}) =>
    client.fetchConversations(page: page);
}

class _ConversationsPageState extends ItemStreamState<Conversation, ConversationsPage> {
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.conversations),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final conversation = await Navigator.pushNamed(context, "/conversations/new") as Conversation?;

          if (conversation == null) {
            return; // user didn't submit a conversation
          }

          items.insert(0, conversation);
        },
      ),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Conversation> createStream() => _ConversationsStream();

  @override
  Widget buildItem(BuildContext context, Conversation conversation) {
    final theme = Theme.of(context);

    return InkWell(
      child: Slidable(
        key: ValueKey(conversation.guid),
        startActionPane: ActionPane(
          motion: StretchMotion(),
          extentRatio: 0.2,
          dismissible: DismissiblePane(
            closeOnCancel: true,
            confirmDismiss: () async {
              _toggleRead(conversation);
              return false;
            },
            onDismissed: () => _toggleRead(conversation),
          ),
          children: <Widget>[
            SlidableAction(
              icon: Icons.done,
              foregroundColor: theme.iconTheme.color,
              backgroundColor: conversation.read ? theme.colorScheme.secondary : Colors.transparent,
              onPressed: (_) => _toggleRead(conversation),
            )
          ],
        ),
        endActionPane: ActionPane(
          motion: StretchMotion(),
          extentRatio: 0.2,
          dismissible: DismissiblePane(onDismissed: () => _hide(conversation)),
          children: <Widget>[
            SlidableAction(
              icon: Icons.delete,
              backgroundColor: Colors.red,
              onPressed: (_) => _hide(conversation),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: conversation.read ? Colors.transparent : colors.unreadItemBackground(theme),
            border: Border(
              left: conversation.read ? BorderSide.none : BorderSide(color: theme.colorScheme.secondary, width: 2),
              bottom: BorderSide(color: conversation.read ? theme.dividerColor : colors.unreadItemBottomBorder(theme))
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: AvatarStack(people: conversation.participants),
            title: Text(conversation.subject)
          ),
        ),
      ),
      onTap: () {
        _show(conversation);
      },
    );
  }

  _show(Conversation conversation) {
    _setRead(conversation, true);
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, _, __) => _ConversationMessagesPage(conversation: conversation),
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        child: child,
        position: animation.drive(Tween(begin: Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.ease)))
      ),
      transitionDuration: Duration(milliseconds: 400)
    ));
  }

  _toggleRead(Conversation conversation) {
    _setRead(conversation, !conversation.read);
  }

  Future<void> _setRead(Conversation conversation, bool newStatus) async {
    if (conversation.read == newStatus) {
      return;
    }

    final client = context.read<Client>(),
      unreadCount = context.read<UnreadConversationsCount>();

    setState(() => conversation.read = newStatus);
    if (newStatus) {
      unreadCount.decrement();
    } else {
      unreadCount.increment();
    }

    try {
      await client.setConversationRead(conversation, isRead: newStatus);
    } catch (e, s)  {
      tryShowErrorSnackBar(this, newStatus ? l.failedToMarkConversationAsRead : l.failedToMarkConversationAsUnread, e, s);

      if (mounted) {
        setState(() => conversation.read = !newStatus);
      }

      if (newStatus) {
        unreadCount.increment();
      } else {
        unreadCount.decrement();
      }
    }
  }

  _hide(Conversation conversation) async {
    final client = context.read<Client>(),
      unreadCount = context.read<UnreadConversationsCount>(),
      position = items.remove(conversation);

    try {
      await client.hideConversation(conversation);

      if (!conversation.read) {
        unreadCount.decrement();
      }
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToHideConversation, e, s);

      items.insert(position, conversation);
    }
  }
}

class _ConversationMessagesPage extends StatefulWidget {
  const _ConversationMessagesPage({Key? key, required this.conversation}) : super(key: key);

  final Conversation conversation;

  @override
  State<StatefulWidget> createState() => _ConversationMessagesState();
}

class _ConversationMessagesStream extends ItemStream<ConversationMessage> {
  _ConversationMessagesStream(this.conversation);

  final Conversation conversation;

  @override
  Future<Page<ConversationMessage>> loadPage({required Client client, String? page}) =>
    client.fetchConversationMessages(conversation, page: page);

}

class _ConversationMessagesState extends ItemStreamState<ConversationMessage, _ConversationMessagesPage> {
  final _newMessage = TextEditingController();
  late DraftObserver _draftObserver;

  @override
  void initState() {
    super.initState();
    final state = context.read<PersistentState>();
    _newMessage.text = state.getMessageDraft(widget.conversation) ?? "";
    _draftObserver = DraftObserver(context: context, controller: _newMessage, onPersist: (text) =>
      state.setMessageDraft(widget.conversation, text));
  }

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.subject)),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<ConversationMessage> createStream() => _ConversationMessagesStream(widget.conversation);

  @override
  Widget buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.conversation.participants.map((person) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile", arguments: person),
              child: Tooltip(
                  message: person.nameOrId,
                  child: Avatar(person: person, size: 32)
                )
            )).toList()
          ),
        )
      ]
    );
  }

  @override
  Widget buildItem(BuildContext context, ConversationMessage item) => Card(
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: PersonHeader(person: item.author)),
              Timeago(item.createdAt, textStyle: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).hintColor,
                fontSize: 12,
              ))
            ],
          ),
          Message(body: item.body)
        ]
      )
    )
  );

  @override
  Widget? buildFooter(BuildContext context, String? lastError, String? lastErrorDetails) => lastError != null ?
    super.buildFooter(context, lastError, lastErrorDetails) : ConstrainedBox(
    constraints: BoxConstraints(maxHeight: 400),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: SimpleComposer(
        controller: _newMessage,
        submitButtonContent: Text(l.replyToConversation),
        mentionablePeople: SearchablePeople.list(widget.conversation.participants),
        onSubmit: _submit
      ),
    ),
  );

  @override
  void dispose() {
    _draftObserver.dispose();
    _newMessage.dispose();
    super.dispose();
  }

  Future<bool> _submit(String body) async {
    final client = context.read<Client>(),
      state = context.read<PersistentState>();
    try {
      final message = await client.createMessage(widget.conversation, body);
      items.add(message);
      state.clearMessageDraft(widget.conversation);
      return true;
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToReplyToConversation, e, s);
    }
    return false;
  }
}
