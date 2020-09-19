import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/localizations.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

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

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l.aspectsListTitle)),
      floatingActionButton: _AddAspectButton(),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Aspect> createStream() => _AspectsStream();

  @override
  Widget buildItem(BuildContext context, Aspect item) => _AspectItem(aspect: item);
}

class _AddAspectButton extends StatefulWidget {
  @override
  _AddAspectButtonState createState() => _AddAspectButtonState();
}

class _AddAspectButtonState extends State<_AddAspectButton> with StateLocalizationHelpers {
  @override
  Widget build(BuildContext context) => FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: _addAspect
  );

  _addAspect() async {
    final name = await showDialog(context: context, builder: (context) => _AspectNameDialog(
      title: l.createAspectPrompt,
      actionText: l.createButtonLabel
    )),
      client = Provider.of<Client>(context, listen: false),
      items = Provider.of<ItemStream<Aspect>>(context, listen: false);

    if (name == null) {
      return; // user cancelled dialog
    }

    final mock = Aspect.mock(name);
    items.add(mock);

    try {
      final aspect = await client.createAspect(name);
      items.replace(toRemove: mock, replacement: aspect);
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToCreateAspect, e, s);
      items.remove(mock);
    }
  }
}

class _AspectItem extends StatefulWidget {
  const _AspectItem({Key key, @required this.aspect}) : super(key: key);

  final Aspect aspect;

  @override
  State<StatefulWidget> createState() => _AspectItemState();
}

class _AspectItemState extends State<_AspectItem> with StateLocalizationHelpers {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListTile(
        title: Text(widget.aspect.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(icon: Icon(Icons.edit), onPressed: _edit),
            IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: _remove)
          ],
        ),
        onTap: widget.aspect.isMock ? null : () {
          Navigator.push(context, PageRouteBuilder(
            pageBuilder: (context, _, __) => _AspectContactsPage(widget.aspect),
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
  }

  _edit() async {
    final oldName = widget.aspect.name,
      newName = await showDialog(context: context, builder: (context) => _AspectNameDialog(
      title: l.editAspectPrompt,
      actionText: l.saveButtonLabel,
      initialValue: oldName,
    )),
      client = Provider.of<Client>(context, listen: false),
      items = Provider.of<ItemStream<Aspect>>(context, listen: false);

    if (newName == null) {
      return; // user canceled dialog
    }

    setState(() => widget.aspect.name = newName);

    try {
      final newAspect = await client.renameAspect(widget.aspect, newName);
      items.replace(toRemove: widget.aspect, replacement: newAspect);
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToRenameAspect(oldName, newName), e, s);
      setState(() => widget.aspect.name = oldName);
    }
  }

  _remove() async {
    bool confirmed = await showDialog(context: context, builder: (context) => AlertDialog(
      title: Text(l.deleteAspectPrompt(widget.aspect.name)),
      actions: <Widget>[
        FlatButton(child: Text(ml.cancelButtonLabel), onPressed: () => Navigator.pop(context)),
        FlatButton(child: Text(l.confirmDeleteButtonLabel), onPressed: () => Navigator.pop(context, true))
      ],
    ));
    final client = Provider.of<Client>(context, listen: false),
      items = Provider.of<ItemStream<Aspect>>(context, listen: false);

    if (confirmed != true) {
      return; // user rejected or canceled dialog
    }

    final position = items.remove(widget.aspect);

    try {
      await client.deleteAspect(widget.aspect);
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToDeleteAspect(widget.aspect.name), e, s);
      items.insert(position, widget.aspect);
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
  Widget buildBody(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.aspect.name)),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Person> createStream() => _AspectContactsStream(widget.aspect);

  @override
  Widget buildItem(BuildContext context, Person person) => Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
    child: ListTile(
      leading: Avatar(person: person, size: 32),
      title: Text(person.nameOrId),
      onTap: () => Navigator.pushNamed(context, '/profile', arguments: person),
    ),
  );
}

class _AspectNameDialog extends StatefulWidget {
  _AspectNameDialog({Key key, @required this.title, @required this.actionText, this.initialValue}) : super(key: key);

  final String title;
  final String actionText;
  final String initialValue;

  @override
  State<StatefulWidget> createState() => _AspectNameDialogState();
}

class _AspectNameDialogState extends State<_AspectNameDialog> with StateLocalizationHelpers {
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
      decoration: InputDecoration(hintText: l.aspectNameHint),
      onChanged: (value) => setState(() => _valid = value.trim().isNotEmpty),
      onSubmitted: _submit,
    ),
    actions: <Widget>[
      FlatButton(child: Text(ml.cancelButtonLabel), onPressed: () => Navigator.pop(context)),
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
