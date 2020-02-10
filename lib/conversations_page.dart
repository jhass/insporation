import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:insporation/src/utils.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/messages.dart';
import 'src/navigation.dart';
import 'src/widgets.dart';

class ConversationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ConversationsPageState();
}

class _ConversationsStream extends ItemStream<Conversation> {
  @override
  Future<Page<Conversation>> loadPage({Client client, String page}) =>
    client.fetchConversations(page: page);
}

class _ConversationsPageState extends ItemStreamState<Conversation, ConversationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.conversations),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (context, _, __) => _NewConversationPage())),
      ),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Conversation> createStream() => _ConversationsStream();

  @override
  Widget buildItem(BuildContext context, Conversation conversation) => InkWell(
    child: Slidable(
      key: UniqueKey(),
      actionPane: SlidableStrechActionPane(),
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        onDismissed: (_) => _hide(conversation),
      ),
      actions: <Widget>[
        IconSlideAction(
          icon: Icons.delete,
          color: Colors.red,
          onTap: () => _hide(conversation),
        )
      ],
      child: Container(
        decoration: BoxDecoration(
          color: conversation.read ? Colors.transparent : Colors.lightBlue[50],
          border: Border(
            left: conversation.read ? BorderSide.none : BorderSide(color: Colors.blueAccent, width: 2),
            bottom: BorderSide(color: conversation.read ? Colors.grey[200] : Colors.blueGrey[100])
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

  _show(Conversation conversation) {
    setState(() => conversation.read = true);
    Provider.of<UnreadConversationsCount>(context, listen: false).decrement();
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (context, _, __) => _ConversationMessagesPage(conversation: conversation),
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        child: child,
        position: animation.drive(Tween(begin: Offset(1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.ease)))
      ),
      transitionDuration: Duration(milliseconds: 400)
    ));
  }

  _hide(Conversation conversation) async {
    final client = Provider.of<Client>(context, listen: false),
      position = items.remove(conversation);

    try {
      await client.hideConversation(conversation);
    } catch (e, s) {
      tryShowErrorSnackBar(this, "Failed to hide conversation", e, s);

      items.insert(position, conversation);
    }
  }
}

class _ConversationMessagesPage extends StatefulWidget {
  const _ConversationMessagesPage({Key key, this.conversation}) : super(key: key);

  final Conversation conversation;

  @override
  State<StatefulWidget> createState() => _ConversationMessagesState();
}

class _ConversationMessagesStream extends ItemStream<ConversationMessage> {
  _ConversationMessagesStream(this.conversation);

  final Conversation conversation;

  @override
  Future<Page<ConversationMessage>> loadPage({Client client, String page}) =>
    client.fetchConversationMessages(conversation, page: page);

}

class _ConversationMessagesState extends ItemStreamState<ConversationMessage, _ConversationMessagesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.subject)),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<ConversationMessage> createStream() => _ConversationMessagesStream(widget.conversation);

  @override
  Widget buildHeader(BuildContext context, String lastError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        super.buildHeader(context, lastError),
        Padding(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: widget.conversation.participants.map((person) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, "/profile", arguments: person),
              child: person.avatar == null ?
                Icon(Icons.person) :
                Tooltip(
                  message: person.nameOrId,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      imageUrl: person.avatar
                    )
                  ),
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
          PersonHeader(person: item.author),
          Message(body: item.body)
        ]
      )
    )
  );
}

class _NewConversationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<_NewConversationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New conversation")),
      body: Center(child: Text("TODO"))
    );
  }
}
