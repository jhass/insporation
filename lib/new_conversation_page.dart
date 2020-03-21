import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/localizations.dart';
import 'src/messages.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/colors.dart' as colors;
import 'src/widgets.dart';

class NewConversationOptions {
  final List<Person> recipients;
  final String prefillSubject;
  final String prefillBody;

  const NewConversationOptions({this.recipients = const [], this.prefillSubject = "", this.prefillBody = ""});
}

class NewConversationPage extends StatelessWidget with LocalizationHelpers {
  NewConversationPage({Key key, this.options = const NewConversationOptions()}) : super(key: key);

  final NewConversationOptions options;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l(context).newConversationTitle)),
    body: SingleChildScrollView(child: _NewConversationPageBody(options: options))
  );
}

class _NewConversationPageBody extends StatefulWidget {
  _NewConversationPageBody({Key key, this.options = const NewConversationOptions()}) : super(key: key);

  final NewConversationOptions options;

  @override
  State<StatefulWidget> createState() => _NewConversationPageBodyState();
}

class _NewConversationPageBodyState extends State<_NewConversationPageBody> with StateLocalizationHelpers {
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l.newConversationRecipientsLabel, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        Wrap(
          spacing: 4,
          children: _buildRecipients()
        ),
        Divider(thickness: 1.0, color: colors.inputBorder(Theme.of(context))),
        Text(l.newConversationSubjectLabel, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        TextField(
          controller: _subject,
          focusNode: _subjectFocus,
        ),
        Divider(color: Colors.transparent),
        Text(l.newConversationMessageLabel, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size(double.infinity, 400)),
          child: SimpleComposer(
            controller: _body,
            submittable: _validSubject && _recipients.isNotEmpty,
            submitButtonContent: Text(l.sendNewConversation),
            onSubmit: _submit,
          )
        )
      ],
    )
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
    final Person response = await showDialog(context: context, builder: (context) =>
      PeopleSearchDialog(people: SearchablePeople.mutualContacts()));

    if (response == null) {
      return; // user cancelled dialog
    }

    if (_recipients.contains(response)) {
        Scaffold.of(context).showSnackBar(errorSnackbar(context, l.failedToAddConversationParticipantDuplicate(response.nameOrId)));
        return;
      }

    setState(() => _recipients.add(response));
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
      tryShowErrorSnackBar(this, l.failedToCreateConversation, e, s);
    }
    return false;
  }
}
