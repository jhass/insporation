import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/messages.dart';
import 'src/search.dart';
import 'src/utils.dart';

class NewConversationOptions {
  final List<Person> recipients;
  final String prefillSubject;
  final String prefillBody;

  const NewConversationOptions({this.recipients = const [], this.prefillSubject = "", this.prefillBody = ""});
}

class NewConversationPage extends StatefulWidget {
  NewConversationPage({Key key, this.options = const NewConversationOptions()}) : super(key: key);

  final NewConversationOptions options;

  @override
  State<StatefulWidget> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final List<Person> _recipients = [];
  final _subject = TextEditingController();
  final _subjectFocus = FocusNode();
  final _body = TextEditingController();
  bool _validSubject = false;

  @override
  void initState() {
    super.initState();

    _recipients.addAll(widget.options.recipients);
    _subject.text = widget.options.prefillSubject;
    _body.text = widget.options.prefillBody;

    _subject.addListener(() {
      final isValid = _subject.text.trim().isNotEmpty;
      if (_validSubject != isValid) {
        setState(() => _validSubject = isValid);
      }
    });

    if (_recipients.isNotEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_subjectFocus);
    });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffold,
    appBar: AppBar(title: Text("Start a new conversation")),
    body: SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Recipients", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          Wrap(
            spacing: 4,
            children: _buildRecipients()
          ),
          Divider(color: Colors.grey),
          Text("Subject", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          TextField(
            controller: _subject,
            focusNode: _subjectFocus,
          ),
          Divider(color: Colors.transparent),
          Text("Message", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          ConstrainedBox(
            constraints: BoxConstraints.loose(Size(double.infinity, 400)),
            child: SimpleComposer(
              controller: _body,
              submittable: _validSubject && _recipients.isNotEmpty,
              submitButtonContent: Text("Send"),
              onSubmit: _submit,
            )
          )
        ],
      ),
    ))
  );

  @override
  void dispose() {
    super.dispose();
    _subject.dispose();
  }

  List<Widget> _buildRecipients() {
    final items = _recipients.map<Widget>((person) =>
      Chip(
        label: PersonHeader(person: person),
        deleteIcon: Icon(Icons.remove_circle_outline),
        onDeleted: () => setState(() => _recipients.remove(person)),
      )
    ).toList();

    items.add(IconButton(
      icon: Icon(Icons.add),
      onPressed: _selectRecipient,
    ));

    return items;
  }

  _selectRecipient() async {
    final client = Provider.of<Client>(context, listen: false);
    // TODO there's no good way to search through mutual contacts only, so we validate it after selection for now,
    // also we do allow to search through all people rather than contacts only because the contacts only
    // search is a hack too and thus a lot slower, and we have to validate anyways after
    final Person response = await showDialog(context: context, builder: (context) =>
      PeopleSearchDialog(people: SearchablePeople.all()));

    if (response == null) {
      return; // user cancelled dialog
    }

    try {
      final profile = await client.fetchProfile(response.guid);

      if (!mounted) {
        return;
      }

      if (!profile.receiving) {
        _showError("You're not sharing with ${response.nameOrId}, cannot add them as a recipient!");
        return;
      } else if (!profile.sharing) {
        _showError("${response.nameOrId} is not sharing with you, cannot add them as a recipient!");
        return;
      } else if (_recipients.contains(response)) {
        _showError("${response.nameOrId} already is a recipient, cannot add them twice.");
        return;
      }

      setState(() => _recipients.add(response));
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to add recipient", e, s);
    }
  }

  _showError(String message) {
    _scaffold.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: TextStyle(color: Colors.white)
      ),
    ));
  }

  Future<bool> _submit(String body) async {
    final client = Provider.of<Client>(context, listen: false);

    try {
      final conversation = await client.createConversation(NewConversation(
        recipients: _recipients,
        subject: _subject.text,
        body: body
      ));
      Navigator.pop(context, conversation);
      return true;
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to create conversation", e, s);
    }
    return false;
  }
}