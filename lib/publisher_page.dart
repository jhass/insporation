import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/error_message.dart';
import 'src/search.dart';

class PublisherOptions {
  final String prefill;
  final PublishTarget target;

  const PublisherOptions({this.prefill = "", this.target = const PublishTarget.allAspects()});
}

class PublishTarget {
  final bool public;
  final bool allAspects;
  final List<Aspect> aspects;

  const PublishTarget.public() : public = true, allAspects = false, aspects = null;
  const PublishTarget.allAspects() : public = false, allAspects = true, aspects = null;
  PublishTarget.aspects(this.aspects) : public = false, allAspects = false;
}

class PublisherPage extends StatefulWidget {
  const PublisherPage({Key key, this.options = const PublisherOptions()}) : super(key: key);

  final PublisherOptions options;

  @override
  State<StatefulWidget> createState() => _PublisherPageState();
}

class _PublisherPageState extends State<PublisherPage> {
  final _initialFocus = FocusNode();
  final _controller = TextEditingController();
  bool _valid = false;
  bool _submitting = false;
  String _lastError;
  PublishTarget _currentTarget;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_initialFocus);
    });

    _currentTarget = widget.options.target;

    _controller.addListener(_onTextChanged);
    _controller.text = widget.options.prefill;
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("Write a new post")),
    body: Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Composer(
            focusNode: _initialFocus,
            controller: _controller,
            enabled: !_submitting,
            mentionablePeople: _mentionablePeople,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: RaisedButton.icon(
                  icon: Icon(Icons.arrow_drop_down),
                  label: Text(_currentTargetTitle),
                  onPressed: !_submitting ? _selectTarget : null
                ),
              ),
              Visibility(
                visible: !_submitting,
                replacement: CircularProgressIndicator(),
                child: RaisedButton(
                  child: Text("Publish post"),
                  onPressed: _valid && !_submitting ? _submit : null
                ),
              )
            ],
          ),
          ErrorMessage(_lastError)
        ],
      )
    )
  );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _onTextChanged() {
    final newValid = _controller.text.trim().isNotEmpty;
    if (_valid != newValid) {
      setState(() => _valid = newValid);
    }
  }

  String get _currentTargetTitle {
    if (_currentTarget.public) {
      return "Public";
    } else if (_currentTarget.allAspects) {
      return "All aspects";
    } else if (_currentTarget.aspects.length == 1) {
      return _currentTarget.aspects.first.name;
    } else {
      return "${_currentTarget.aspects.length} aspects";
    }
  }

  SearchablePeople get _mentionablePeople {
    if (_currentTarget.public) {
      return SearchablePeople.all();
    } else if (_currentTarget.allAspects) {
      return SearchablePeople.contactsOnly();
    } else {
      return SearchablePeople.inAspects(_currentTarget.aspects);
    }
  }

  _selectTarget() async {
    final PublishTarget response = await showDialog(context: context, builder: (context) =>
      _PublishTargetSelectionDialog(current: _currentTarget));

    if (response == null) {
      return; // User canceled
    }

    setState(() => _currentTarget = response);
  }

  _submit() async {
    final client = Provider.of<Client>(context, listen: false);

    setState(() => _submitting = true);

    try {
      final post = _currentTarget.public ? PublishablePost.public(_controller.text) :
        PublishablePost.private(_controller.text,
          _currentTarget.allAspects ? await client.currentUserAspects : _currentTarget.aspects);

      Navigator.pop(context, await client.createPost(post));
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);

      setState(() {
        _submitting = false;
        _lastError = e.toString();
      });
    }
  }
}

class _PublishTargetSelectionDialog extends StatefulWidget {
  _PublishTargetSelectionDialog({Key key, @required this.current}) : super(key: key) {
    assert(current != null, "Must pass the current target");
  }

  final PublishTarget current;

  @override
  State<StatefulWidget> createState() => _PublishTargetSelectionDialogState();
}

class _PublishTargetSelectionDialogState extends State<_PublishTargetSelectionDialog> {
  List<Aspect> _aspects;
  List<Aspect> _currentSelection;
  String _lastError;

  @override
  void initState() {
    super.initState();

    _currentSelection = List.of(widget.current.aspects ?? <Aspect>[]);

    Provider.of<Client>(context, listen: false).currentUserAspects
      .then((aspects) => setState(() => _aspects = aspects))
      .catchError((error) => _lastError = error.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select post visibility"),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text("Select"),
          onPressed: _aspects != null && _currentSelection.isNotEmpty ? () =>
            Navigator.pop(context, PublishTarget.aspects(_currentSelection)) : null,
        )
      ],
      content: _lastError != null ? ErrorMessage(_lastError) :
        _aspects == null ? Center(child: CircularProgressIndicator()) :
        _buildOptions()
    );
  }

  Widget _buildOptions() {
    final options = <Widget>[];

    options.add(ListTile(
      title: Text("Public"),
      onTap: () => Navigator.pop(context, PublishTarget.public()),
    ));

    options.add(Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
      child: ListTile(
        title: Text("All aspects"),
        onTap: () => Navigator.pop(context, PublishTarget.allAspects()),
      ),
    ));

    options.addAll(_aspects.map((aspect) =>
      CheckboxListTile(
        title: Text(aspect.name),
        value: _currentSelection.contains(aspect),
        onChanged: (checked) =>
          setState(() => checked ? _currentSelection.add(aspect) : _currentSelection.remove(aspect))
      )
    ));

    return ListView(children: options);
  }
}