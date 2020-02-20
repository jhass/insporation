import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/composer.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

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
  final _scaffold = GlobalKey<ScaffoldState>(); // TOOD extract things so this not necessary
  final _initialFocus = FocusNode();
  final _controller = TextEditingController();
  final List<_AttachedPhoto> _attachedPhotos = [];
  _Poll _poll;
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
    key: _scaffold,
    appBar: AppBar(title: Text("Write a new post")),
    body: Padding(
      padding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Composer(
              focusNode: _initialFocus,
              controller: _controller,
              enabled: !_submitting,
              mentionablePeople: _mentionablePeople,
            ),
            Visibility(
              visible: _attachedPhotos.length > 0,
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(Size(double.infinity, 64)),
                            child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachedPhotos.length,
                  itemBuilder: (context, position) => _AttachedPhotoView(
                    photo: _attachedPhotos[position],
                    onDelete: () => setState(() => _attachedPhotos.removeAt(position)),
                  )
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_camera),
                  tooltip: "Take a photo",
                  onPressed: () => _uploadPhoto(ImageSource.camera)
                ),
                IconButton(
                  icon: Icon(Icons.photo_library),
                  tooltip: "Upload a photo",
                  onPressed: () => _uploadPhoto(ImageSource.gallery)
                ),
                IconButton(
                  icon: Icon(Icons.poll),
                  tooltip: "Add a poll",
                  color: _poll != null ? Theme.of(context).colorScheme.secondary : null,
                  onPressed: _editPoll
                ),
                IconButton(
                  icon: Icon(Icons.location_on),
                  tooltip: "Add your location",
                  onPressed: null
                )
              ],
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.arrow_drop_down),
                  label: Text(_currentTargetTitle),
                  onPressed: !_submitting ? _selectTarget : null
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
    )
  );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _onTextChanged() => _validate();

  _validate() {
    final hasText = _controller.text.trim().isNotEmpty,
      hasPhotos = _attachedPhotos.length > 0,
      hasPendingPhotos = _attachedPhotos.any((photo) => !photo.uploaded),
      newValid = (hasText || hasPhotos) && !hasPendingPhotos;

    if (newValid != _valid) {
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

  _uploadPhoto(ImageSource source) async {
    final picture = await ImagePicker.pickImage(source: source, maxWidth: 700),
      client = Provider.of<Client>(context, listen: false);

    if (picture == null) {
      return; // user canceled
    }
    final upload = client.uploadPictureForPublishing(picture),
      attachedPhoto = _AttachedPhoto(picture, upload);

    setState(() => _attachedPhotos.add(attachedPhoto));

    try {
      final photo = await upload;
      attachedPhoto.guid = photo.guid;
      attachedPhoto.uploaded = true;
    } catch (e, s) {
      if (mounted) {
        showErrorSnackBar(_scaffold.currentState, "Failed to upload photo", e, s);
      }

      setState(() => _attachedPhotos.remove(attachedPhoto));
    } finally {
      _validate();
    }
  }

  _editPoll() async {
    final _Poll poll = await showDialog(context: context, builder: (context) => _PollEditor(poll: _poll));

    if (poll == null) {
      return; // user canceled
    }

    if (poll.isEmpty) {
      setState(() => _poll = null); // Deleted
    } else {
      setState(() => _poll = poll);
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
    final client = Provider.of<Client>(context, listen: false),
      photos = _attachedPhotos.map((photo) => photo.guid).toList();

    setState(() => _submitting = true);

    try {
      final post = _currentTarget.public ? PublishablePost.public(
        body: _controller.text,
        photos: photos,
        pollQuestion: _poll?.question,
        pollAnswers: _poll?.answers
      ) : PublishablePost.private(
        _currentTarget.allAspects ? await client.currentUserAspects : _currentTarget.aspects,
        body: _controller.text,
        photos: photos,
        pollQuestion: _poll?.question,
        pollAnswers: _poll?.answers
      );

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
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
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

class _AttachedPhoto {
  final File picture;
  final Future<Photo> upload;
  bool uploaded = false;
  String guid;

  _AttachedPhoto(this.picture, this.upload);
}

class _AttachedPhotoView extends StatefulWidget {
  _AttachedPhotoView({Key key, @required this.photo, @required this.onDelete}) : super(key: key);

  final _AttachedPhoto photo;
  final Function onDelete;

  @override
  _AttachedPhotoViewState createState() => _AttachedPhotoViewState();
}

class _AttachedPhotoViewState extends State<_AttachedPhotoView> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    widget.photo.upload.whenComplete(() => setState(() => _loading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Positioned(
          child: Image.file(
            widget.photo.picture,
            width: 64,
            height: 64,
          ),
        ),
        Visibility(
          visible: _loading,
          child: CircularProgressIndicator(),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Visibility(
            visible: !_loading,
            child:  IconButton(
              alignment: Alignment.bottomRight,
              icon: Icon(Icons.delete),
              onPressed: widget.onDelete
            ),
          )
        ),
      ],
    );
  }
}

class _Poll {
  String question;
  List<String> answers = [];

  bool get isEmpty => question == null;
}

class _PollEditor extends StatefulWidget {
  _PollEditor({Key key, this.poll}) : super(key: key);

  final _Poll poll;

  @override
  _PollEditorState createState() => _PollEditorState();
}

class _PollEditorState extends State<_PollEditor> {
  final _question = TextEditingController();
  final _answers = <TextEditingController>[];
  final _discardedAnswers = <TextEditingController>[];
  _Poll _poll;
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _poll = widget.poll ?? _Poll();
    _question.text = _poll.question ?? "";
    _answers.addAll(_poll.answers.map((answer) => TextEditingController()..text = answer));
    _answers.add(TextEditingController());
    if (_answers.length < 2) {
      _answers.add(TextEditingController());
    }
    _validate();
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      FlatButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
      FlatButton(child: Text("Save"), onPressed: _valid ? () => Navigator.pop(context, _poll) : null)
    ];

    if (widget.poll != null) {
      actions.insert(0, Expanded(
        child: FlatButton(
          child: Text("Delete"),
          onPressed: () => Navigator.pop(context, _Poll())
        )
      ));
    }

    final children = <Widget>[
        SimpleDialogOption(
          child: TextField(
            controller: _question,
            onChanged: (value) {
              _poll.question = value;
              _validate();
            },
            decoration: InputDecoration(hintText: "Enter a question"),
          ),
        ),
    ];

    children.addAll(List.generate(_answers.length, (position) => SimpleDialogOption(
      child: TextField(
        controller: _answers[position],
        onChanged: (value) => _onAnswerChanged(position, value),
        decoration: InputDecoration(hintText: "Enter an answer"),
      )
    )));

    children.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: actions));

    return SimpleDialog(
      title: Text(widget.poll == null ? "Create poll" : "Edit poll"),
      children: children);
  }

  @override
  void dispose() {
    super.dispose();
    _question.dispose();
    (_answers + _discardedAnswers).forEach((answer) => answer.dispose());
  }

  _onAnswerChanged(int position, String value) {
    if (value.trim().isNotEmpty) {
      if (position < _poll.answers.length) {
        _poll.answers[position] = value;
      } else {
        _poll.answers.add(value);
      }

      if (position == _answers.length - 1) {
        setState(() => _answers.add(_discardedAnswers.length > 0 ?
          (_discardedAnswers.removeLast()..text = "") : TextEditingController()));
      }
    } else {
      if (position < _poll.answers.length) {
        _poll.answers.removeAt(position);
      }

      if (position < _answers.length - 1) {
        setState(() => _discardedAnswers.add(_answers.removeAt(position)));
      }
    }

    _validate();
  }

  _validate() {
    final newValid = _question.text.trim().isNotEmpty &&
      _answers.where((answer) => answer.text.trim().isNotEmpty).length >= 2;
    if (newValid != _valid) {
      setState(() => _valid = newValid);
    }
  }
}