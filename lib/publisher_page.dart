import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geojson/geojson.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'src/client.dart';
import 'src/composer.dart';
import 'src/localizations.dart';
import 'src/persistence.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class PublisherOptions {
  final String prefill;
  final List<String> images;
  final PublishTarget target;

  const PublisherOptions({this.prefill = "", this.images = const <String>[], this.target = const PublishTarget.allAspects()});
}

class PublishTarget {
  final bool public;
  final bool allAspects;
  final List<Aspect>? aspects;

  const PublishTarget.public() : public = true, allAspects = false, aspects = null;
  const PublishTarget.allAspects() : public = false, allAspects = true, aspects = null;
  PublishTarget.aspects(this.aspects) : public = false, allAspects = false;
}
class PublisherPage extends StatelessWidget with LocalizationHelpers {
  PublisherPage({Key? key, this.options = const PublisherOptions()}) : super(key: key);

  final PublisherOptions options;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l(context).publisherTitle)),
    body: Padding(
      padding: EdgeInsets.all(8),
      child: _PublisherPageBody(options: options)
    )
  );
}

class _PublisherPageBody extends StatefulWidget {
  _PublisherPageBody({Key? key, this.options = const PublisherOptions()}) : super(key: key);

  final PublisherOptions options;

  @override
  State<StatefulWidget> createState() => _PublisherPageBodyState();
}

class _PublisherPageBodyState extends State<_PublisherPageBody> with StateLocalizationHelpers {
  static const _maxPhotoWidth = 900.0;
  final _initialFocus = FocusNode();
  final _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<_AttachedPhoto> _attachedPhotos = [];
  _Poll? _poll;
  Location? _location;
  bool _valid = false;
  bool _submitting = false;
  String? _lastError;
  late PublishTarget _currentTarget;
  late DraftObserver _draftObserver;
  bool _handledInitialPhotos = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<PersistentState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_initialFocus);
    });

    _currentTarget = widget.options.target;

    _controller.addListener(_onTextChanged);
    _controller.text = presence(widget.options.prefill) ?? state.postDraft ?? "";
    _draftObserver = DraftObserver(context: context, controller: _controller, onPersist: (text) => state.postDraft = text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_handledInitialPhotos) {
      widget.options.images.forEach((uri) => _uploadPhotoUri(uri));
      _handledInitialPhotos = true;
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
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
              tooltip: l.takePhoto,
              onPressed: () => _uploadPhoto(ImageSource.camera)
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              tooltip: l.uploadPhoto,
              onPressed: () => _uploadPhoto(ImageSource.gallery)
            ),
            IconButton(
              icon: Icon(Icons.poll),
              tooltip: l.addPoll,
              color: _poll != null ? Theme.of(context).colorScheme.secondary : null,
              onPressed: _editPoll
            ),
            IconButton(
              icon: Icon(Icons.location_on),
              tooltip: l.addLocation,
              color: _location != null ? Theme.of(context).colorScheme.secondary : null,
              onPressed: _editLocation
            )
          ],
        ),
        ButtonBar(
          children: <Widget>[
            ElevatedButton.icon(
              icon: Icon(Icons.arrow_drop_down),
              label: Text(_currentTargetTitle),
              onPressed: !_submitting ? _selectTarget : null
            ),
            Visibility(
              visible: !_submitting,
              replacement: CircularProgressIndicator(),
              child: ElevatedButton(
                child: Text(l.publishPost),
                onPressed: _valid && !_submitting ? _submit : null
              ),
            )
          ],
        ),
        ErrorMessage(_lastError)
      ],
    )
  );

  @override
  void dispose() {
    _draftObserver.dispose();
    _controller.dispose();
    super.dispose();
  }

  _onTextChanged() => _validate();

  _validate() {
    final hasText = _controller.text.trim().isNotEmpty,
      hasPhotos = _attachedPhotos.length > 0,
      hasPendingPhotos = _attachedPhotos.any((photo) => !photo.uploaded),
      newValid = (hasText || hasPhotos) && !hasPendingPhotos;

    if (newValid != _valid) {
      // We might be called from an asynchronous callback, so make sure it's safe to call setState
      _valid = newValid;
      if (mounted) {
        setState(() {});
      }
    }
  }

  String get _currentTargetTitle {
    if (_currentTarget.public) {
      return l.publishTargetPublic;
    } else if (_currentTarget.allAspects) {
      return l.publishTargetAllAspects;
    } else if (_currentTarget.aspects!.length == 1) {
      return _currentTarget.aspects!.first.name;
    } else {
      return l.publishTargetAspects(_currentTarget.aspects!.length);
    }
  }

  SearchablePeople get _mentionablePeople {
    if (_currentTarget.public) {
      return SearchablePeople.all();
    } else if (_currentTarget.allAspects) {
      return SearchablePeople.receivingContacts();
    } else {
      return SearchablePeople.inAspects(_currentTarget.aspects);
    }
  }

  _uploadPhoto(ImageSource source) async {
    try {
      final picture = await _imagePicker.pickImage(source: source, maxWidth: _maxPhotoWidth);

      if (picture == null) {
        return; // user canceled
      }

      _uploadPhotoFile(File(picture.path));
    } on PlatformException catch (e) {
      if (e.code == "multiple_request") {
        return; // The user is in another request, ignore
      }

      throw e;
    }
  }

  _uploadPhotoUri(String uri) async {
    final source = File.fromUri(Uri.parse(uri)),
      info = await ImageCrop.getImageOptions(file: source),
      width = min(_maxPhotoWidth, info.width),
      height = info.height * (width / info.width),
      picture = info.width <= _maxPhotoWidth ? source : await ImageCrop.sampleImage(
        file: source, preferredWidth: width.floor(), preferredHeight: height.floor());

    _uploadPhotoFile(picture);
  }

  _uploadPhotoFile(File picture) async {
    final client = context.read<Client>();
    final upload = client.uploadPictureForPublishing(picture),
      attachedPhoto = _AttachedPhoto(picture, upload);

    setState(() => _attachedPhotos.add(attachedPhoto));

    try {
      final photo = await upload;
      attachedPhoto.guid = photo.guid;
      attachedPhoto.uploaded = true;
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToUploadPhoto, e, s);

      setState(() => _attachedPhotos.remove(attachedPhoto));
    } finally {
      _validate();
    }
  }

  _editPoll() async {
    final _Poll? poll = await showDialog(context: context, builder: (context) => _PollEditor(poll: _poll));

    if (poll == null) {
      return; // user canceled
    }

    if (poll.isEmpty) {
      setState(() => _poll = null); // Deleted
    } else {
      setState(() => _poll = poll);
    }
  }

  _editLocation() async {
    final Location location = await showDialog(context: context, builder: (context) =>
      _LocationEditor(location: _location));

    if (location == _location) {
      return; // user canceled
    }

    setState(() => _location = location);
  }

  _selectTarget() async {
    final PublishTarget? response = await showDialog(context: context, builder: (context) =>
      _PublishTargetSelectionDialog(current: _currentTarget));

    if (response == null) {
      return; // User canceled
    }

    setState(() => _currentTarget = response);
  }

  _submit() async {
    final client = context.read<Client>(),
      state = context.read<PersistentState>(),
      photos = _attachedPhotos.map((photo) => photo.guid!).toList();

    setState(() => _submitting = true);

    try {
      final post = _currentTarget.public ? PublishablePost.public(
        body: _controller.text,
        photos: photos,
        pollQuestion: _poll?.question,
        pollAnswers: _poll?.answers,
        location: _location
      ) : PublishablePost.private(
        _currentTarget.allAspects ? await client.currentUserAspects : _currentTarget.aspects,
        body: _controller.text,
        photos: photos,
        pollQuestion: _poll?.question,
        pollAnswers: _poll?.answers,
        location: _location
      );

      final newPost = await client.createPost(post);
      state.postDraft = null;
      Navigator.pop(context, newPost);
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
  _PublishTargetSelectionDialog({Key? key, required this.current}) : super(key: key);

  final PublishTarget current;

  @override
  State<StatefulWidget> createState() => _PublishTargetSelectionDialogState();
}

class _PublishTargetSelectionDialogState extends State<_PublishTargetSelectionDialog> with StateLocalizationHelpers {
  List<Aspect>? _aspects;
  late List<Aspect> _currentSelection;
  String? _lastError;

  @override
  void initState() {
    super.initState();

    _currentSelection = List.of(widget.current.aspects ?? <Aspect>[]);

    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l.publishTargetPrompt),
      actions: <Widget>[
        TextButton(
          child: Text(ml.cancelButtonLabel),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text(l.selectButtonLabel),
          onPressed: _aspects != null && _currentSelection.isNotEmpty ? () =>
            Navigator.pop(context, PublishTarget.aspects(_currentSelection)) : null,
        )
      ],
      content: _lastError != null ? ErrorMessage(_lastError, onRetry: _fetch) :
        _aspects == null ? Center(child: CircularProgressIndicator()) :
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: double.maxFinite, maxWidth: double.maxFinite, maxHeight: 400),
          child: _buildOptions())
    );
  }

  Widget _buildOptions() {
    final options = <Widget>[];

    options.add(ListTile(
      title: Text(l.publishTargetPublic),
      onTap: () => Navigator.pop(context, PublishTarget.public()),
    ));

    options.add(Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListTile(
        title: Text(l.publishTargetAllAspects),
        onTap: () => Navigator.pop(context, PublishTarget.allAspects()),
      ),
    ));

    options.addAll(_aspects!.map((aspect) =>
      CheckboxListTile(
        title: Text(aspect.name),
        value: _currentSelection.contains(aspect),
        onChanged: (checked) =>
          setState(() => checked == true ? _currentSelection.add(aspect) : _currentSelection.remove(aspect))
      )
    ));

    return ListView(children: options);
  }

  _fetch() {
    context.read<Client>().currentUserAspects
      .then((aspects) => setState(() => _aspects = aspects))
      .catchError((error) => _lastError = error.toString());
  }
}

class _AttachedPhoto {
  final File picture;
  final Future<Photo> upload;
  bool uploaded = false;
  String? guid;

  _AttachedPhoto(this.picture, this.upload);
}

class _AttachedPhotoView extends StatefulWidget {
  _AttachedPhotoView({Key? key, required this.photo, required this.onDelete}) : super(key: key);

  final _AttachedPhoto photo;
  final VoidCallback onDelete;

  @override
  _AttachedPhotoViewState createState() => _AttachedPhotoViewState();
}

class _AttachedPhotoViewState extends State<_AttachedPhotoView> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    widget.photo.upload.whenComplete(() {
      // On cold boot this might complete without being attached for some reason
      // so we update _loading always
      _loading = false;
      if (mounted) {
        setState(() {});
      }
    });
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
  String? question;
  List<String> answers = [];

  bool get isEmpty => question == null;
}

class _PollEditor extends StatefulWidget {
  _PollEditor({Key? key, this.poll}) : super(key: key);

  final _Poll? poll;

  @override
  _PollEditorState createState() => _PollEditorState();
}

class _PollEditorState extends State<_PollEditor> with StateLocalizationHelpers {
  final _question = TextEditingController();
  final _answers = <TextEditingController>[];
  final _discardedAnswers = <TextEditingController>[];
  late _Poll _poll;
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
      TextButton(child: Text(ml.cancelButtonLabel), onPressed: () => Navigator.pop(context)),
      TextButton(child: Text(l.saveButtonLabel), onPressed: _valid ? () => Navigator.pop(context, _poll) : null)
    ];

    if (widget.poll != null) {
      actions.insert(0, Spacer());
      actions.insert(0, TextButton(
        child: Text(l.removeButtonLabel),
        onPressed: () => Navigator.pop(context, _Poll())
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
            decoration: InputDecoration(hintText: l.pollQuestionHint),
          ),
        ),
    ];

    children.addAll(List.generate(_answers.length, (position) => SimpleDialogOption(
      child: TextField(
        controller: _answers[position],
        onChanged: (value) => _onAnswerChanged(position, value),
        decoration: InputDecoration(hintText: l.pollAnswerHint),
      )
    )));

    children.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: actions));

    return SimpleDialog(
      title: Text(widget.poll == null ? l.createPoll : l.editPoll),
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


class _LocationEditor extends StatefulWidget {
  _LocationEditor({Key? key, this.location}) : super(key: key);

  final Location? location;

  @override
  _LocationEditorState createState() => _LocationEditorState();
}

class _LocationEditorState extends State<_LocationEditor> with StateLocalizationHelpers {
  static final _apiBase = Uri.parse("https://photon.komoot.de/api/");

  final _controller = TextEditingController();
  final _results = <Location>[];
  bool _loading = false;
  CancelableFuture<GeoJsonFeatureCollection>? _currentSearch;

  @override
  void initState() {
    super.initState();

    if (widget.location != null) {
      _controller.text = widget.location!.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[
        SimpleDialogOption(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: l.enterAddressHint),
            onChanged: _search,
          )
        )
    ];

    if (_loading) {
      entries.add(SimpleDialogOption(child: Center(child: CircularProgressIndicator())));
    }

    entries.addAll(_results.map((location) => Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: SimpleDialogOption(
        onPressed: () => Navigator.pop(context, location),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.location_on),
            ),
            Expanded(child: Text(location.address)),
          ],
        )
      )
    )));

    final actions = <Widget>[
      TextButton(child: Text(ml.closeButtonLabel), onPressed: () => Navigator.pop(context, widget.location)),
    ];

    if (widget.location != null) {
      actions.insert(0, Spacer());
      actions.insert(0, TextButton(
        child: Text(l.removeButtonLabel),
        onPressed: () => Navigator.pop(context),
      ));
    }

    entries.add(Row(mainAxisAlignment: MainAxisAlignment.end, children: actions));

    return SimpleDialog(children: entries);
  }

  _search(String query) async {
    _currentSearch?.cancel();

    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        _results.clear();
        _loading = false;
      });
      return;
    }

    try {
      setState(() => _loading = true);

      final search = _currentSearch = _fetchFeatures(query),
        features = await search.get();

      setState(() {
        _results
          ..clear()
          ..addAll(features
            .collection
            .cast<GeoJsonFeature<GeoJsonPoint>>()
            .map((feature) => Location(
              address: _formatAddress(feature.properties),
              lat: feature.geometry!.geoPoint.latitude,
              lng: feature.geometry!.geoPoint.longitude))
            .fold<Set<Location>>(LinkedHashSet(), (locations, location) => locations..add(location))
            .take(15)
          );
          _loading = false;
      });
    } on FutureCanceledError {
      // ignore
    } catch (e, s) {
      tryShowErrorSnackBar(this, l.failedToSearchForAddresses, e, s);
    }
  }

  CancelableFuture<GeoJsonFeatureCollection> _fetchFeatures(String query) => CancelableFuture(
    http.get(_apiBase.replace(queryParameters: {"q": query}))
  ).then((response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return compute(featuresFromGeoJson, response.body);
    } else {
      throw ClientException.fromResponse(response);
    }
  });

  _formatAddress(Map<String, dynamic>? properties) {
    return LinkedHashSet.of([
      properties?["name"],
      properties?["street"],
      properties?["city"],
      properties?["state"],
      properties?["country"]]
      ..removeWhere((element) => element == null)).join(", ");
  }
}
