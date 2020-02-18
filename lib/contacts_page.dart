import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insporation/src/utils.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsPageState();
}

class _AspectsStream extends ItemStream<Aspect> {
  @override
  Future<Page<Aspect>> loadPage({Client client, String page}) async {
    final aspects = await client.currentUserAspects;
    return Page(content: aspects);
  }
}

class _ContactsPageState extends ItemStreamState<Aspect, ContactsPage> {
  _ContactsPageState() : super(listPadding: EdgeInsets.only(bottom: 72));

  final _scaffold = GlobalKey<ScaffoldState>(); // TODO extract list items into their own widgets

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addAspect
      ),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Aspect> createStream() => _AspectsStream();

  @override
  Widget buildItem(BuildContext context, Aspect item) => Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
    child: ListTile(
      title: Text(item.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(icon: Icon(Icons.edit), onPressed: () => _editAspect(item)),
          IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () => _removeAspect(item))
        ],
      ),
      onTap: item.isMock ? null : () {
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, _, __) => _AspectContactsPage(item),
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: animation
              .drive(Tween(begin: Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease))),
            child: child
          )
        ));
      },
    )
  );

  _addAspect() async {
    final name = await showDialog(context: context, builder: (context) => _AspectNameDialog(
      title: "Create an aspect",
      actionText: "Create"
    )), client = Provider.of<Client>(context, listen: false);

    if (name == null) {
      return; // user cancelled dialog
    }

    final mock = Aspect.mock(name);
    items.add(mock);

    try {
      final aspect = await client.createAspect(name);
      items.replace(toRemove: mock, replacement: aspect);
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to create aspect", e, s);
      items.remove(mock);
    }
  }

  _editAspect(Aspect aspect) async {
    final oldName = aspect.name,
      newName = await showDialog(context: context, builder: (context) => _AspectNameDialog(
      title: "Edit aspect",
      actionText: "Save",
      initialValue: oldName,
    )), client = Provider.of<Client>(context, listen: false);

    if (newName == null) {
      return; // user canceled dialog
    }

    setState(() => aspect.name = newName);

    try {
      final newAspect = await client.renameAspect(aspect, newName);
      items.replace(toRemove: aspect, replacement: newAspect);
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to rename aspect $oldName to $newName", e, s);
      setState(() => aspect.name = oldName);
    }
  }

  _removeAspect(Aspect aspect) async {
    bool confirmed = await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Delete aspect ${aspect.name}?"),
      actions: <Widget>[
        FlatButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
        FlatButton(child: Text("Confirm delete"), onPressed: () => Navigator.pop(context, true))
      ],
    ));
    final client = Provider.of<Client>(context, listen: false);

    if (confirmed != true) {
      return; // user rejected or canceled dialog
    }

    final position = items.remove(aspect);

    try {
      await client.deleteAspect(aspect);
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to remove aspect ${aspect.name}", e, s);
      items.insert(position, aspect);
    }
  }
}

class _AspectContactsPage extends StatefulWidget {
  _AspectContactsPage(this.aspect, {Key key}) : super(key: key);

  final Aspect aspect;

  @override
  State<StatefulWidget> createState() => _AspectContactsPageState();
}

class _AspectContactsStream extends ItemStream<Person> {
  _AspectContactsStream(this.aspect);

  final Aspect aspect;

  @override
  Future<Page<Person>> loadPage({Client client, String page}) =>
    client.fetchAspectContacts(aspect, page: page);

}

class _AspectContactsPageState extends ItemStreamState<Person, _AspectContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.aspect.name)),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Person> createStream() => _AspectContactsStream(widget.aspect);

  @override
  Widget buildItem(BuildContext context, Person person) {
    final placeholder = Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(Icons.person));
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListTile(
        leading: person.avatar == null ?
        placeholder : ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            imageUrl: person.avatar,
            placeholder: (context, _) => placeholder,
          )
        ),
        title: Text(person.nameOrId),
        onTap: () => Navigator.pushNamed(context, '/profile', arguments: person),
      ),
    );
  }
}

class _AspectNameDialog extends StatefulWidget {
  _AspectNameDialog({Key key, @required this.title, @required this.actionText, this.initialValue}) : super(key: key);

  final String title;
  final String actionText;
  final String initialValue;

  @override
  State<StatefulWidget> createState() => _AspectNameDialogState();
}

class _AspectNameDialogState extends State<_AspectNameDialog> {
  final _name = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialValue ?? "";
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      autofocus: true,
      controller: _name,
      decoration: InputDecoration(hintText: "Enter a name"),
      onChanged: (value) => setState(() => _valid = value.trim().isNotEmpty),
      onSubmitted: _submit,
    ),
    actions: <Widget>[
      FlatButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
      FlatButton(child: Text(widget.actionText), onPressed: _valid ? _submit : null)
    ],
  );

  _submit([String _]) async {
    final name = _name.text.trim();

    if (name.isEmpty) {
      return;
    }

    Navigator.pop(context, name);
  }
}