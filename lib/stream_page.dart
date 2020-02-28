import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'publisher_page.dart';
import 'src/aspects.dart';
import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/navigation.dart';
import 'src/posts.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class StreamPage extends StatefulWidget {
  StreamPage({Key key, this.type, this.aspects, this.tag}) : super(key: key);

  final StreamType type;
  final List<Aspect> aspects;
  final String tag;

  @override
  _StreamPageState createState() => _StreamPageState();

  String get title {
    switch (type) {
      case StreamType.tag:
        return "#$tag";
      default:
        return streamNames[type];
    }
  }
}

class _StreamPageState extends ItemStreamState<Post, StreamPage> with PostStreamState<StreamPage> {
  @override
  ItemStream<Post> createStream() => PostStream(type: widget.type, tag: widget.tag, aspects: widget.aspects);

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.type != StreamType.tag ? NavigationBar(currentPage: PageType.stream) : null,
      appBar: widget.type == StreamType.tag ? AppBar(
        title: Text(widget.title),
      ) : null,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          PublisherOptions options;
          if (widget.type == StreamType.tag) {
            options = PublisherOptions(prefill: "#${widget.tag} ");
          } else if (widget.type == StreamType.aspects && widget.aspects != null) {
            options = PublisherOptions(target: PublishTarget.aspects(widget.aspects));
          }
          final post = await Navigator.pushNamed(context, "/publisher", arguments: options);

          if (post == null) {
            return; // user canceled
          }

          items.insert(0, post);
        }
      ),
      body: buildStream(context)
    );
  }

  @override
  Widget buildHeader(BuildContext context) {
    final selector = _StreamTypeSelector(currentType: widget.type);
    if (widget.type == StreamType.aspects) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          selector,
          Padding(
            padding: EdgeInsets.all(8),
            child: _AspectsSelector(currentSelection: widget.aspects),
          )
        ],
      );
    } else if (widget.type == StreamType.followedTags) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          selector,
          Padding(
            padding: EdgeInsets.all(8),
            child: OutlineButton(
              child: Text("Manage followed tags", style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, _, __) => _FollowedTagsPage()
                ));

                items.load(Provider.of<Client>(context, listen: false), reset: true);
              },
            )
          )
        ],
      );
    } else {
      return selector;
    }
  }
}

class _StreamTypeSelector extends StatelessWidget {
  _StreamTypeSelector({Key key, @required this.currentType}) : super(key: key);

  final StreamType currentType;

  @override
  Widget build(BuildContext context) {
    if (currentType == StreamType.tag) {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.topLeft,
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton(
          value: currentType,
          icon: Icon(Icons.arrow_downward),
          iconSize: 32,
          style: TextStyle(
              fontSize: 32,
              color: Theme.of(context).colorScheme.onSurface
          ),
          underline: SizedBox.shrink(),
          onChanged: (newValue) {
            if (newValue != currentType) {
              Navigator.pushReplacementNamed(context, '/stream/${describeEnum(newValue)}');
            }
          },
          items: const [StreamType.main, StreamType.activity, StreamType.aspects, StreamType.followedTags,
            StreamType.mentions, StreamType.liked, StreamType.commented].map((type) =>
              DropdownMenuItem(child: Text(streamNames[type]), value: type)).toList()
        ),
      ),
    );
  }
}

class _AspectsSelector extends StatefulWidget {
  _AspectsSelector({Key key, @required this.currentSelection}) : super(key: key);

  final List<Aspect> currentSelection;

  @override
  State<StatefulWidget> createState() => _AspectsSelectorState();
}

class _AspectsSelectorState extends State<_AspectsSelector> {
  @override
  Widget build(BuildContext context) => OutlineButton.icon(
    icon: Icon(Icons.arrow_drop_down, size: 28),
    label: Text(_label, style: TextStyle(fontSize: 16)),
    onPressed: _updateAspects
  );

  String get _label {
    if (widget.currentSelection == null || widget.currentSelection.length == 0) {
      return "All aspects";
    } else if (widget.currentSelection.length == 1) {
      return widget.currentSelection.first.name;
    } else {
      return "${widget.currentSelection.length} aspects";
    }
  }

  void _updateAspects() async {
    List<Aspect> newAspects = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AspectSelectionList.buildDialog(
        context: context,
        currentSelection: widget.currentSelection
      )
    );

    if (newAspects == null) {
      return; // canceled
    }

    if (containSameElements(newAspects, widget.currentSelection)) {
      return;
    }

    if (newAspects.isEmpty) {
      newAspects = null;
    }

    Navigator.pushReplacementNamed(context, "/stream/aspects", arguments: newAspects);
  }
}

class _FollowedTagsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FollowedTagsPageState();
}

class _FollowedTagsPageState extends State<_FollowedTagsPage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  List<String> _tags;
  String _lastError;

  @override
  void initState() {
    super.initState();

    _fetch();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffold,
    appBar: AppBar(title: Text("Followed tags")),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: _addTag
    ),
    body: _tags == null && _lastError == null ?
      _lastError != null ? ErrorMessage(_lastError, onRetry: _fetch) :
      Center(child: CircularProgressIndicator()) :
      ListView.builder(
        padding: EdgeInsets.only(bottom: 72),
        itemCount: _tags.length,
        itemBuilder: (context, position) => ListTile(
          title: Text("#${_tags[position]}"),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _removeTag(_tags[position])
          ),
        )
      )
  );

  _fetch() {
    Provider.of<Client>(context, listen: false).fetchFollowedTags()
      .then((tags) => setState(() => _tags = tags))
      .catchError((error) => setState(() => _lastError = error.toString()));
  }

  _addTag() async {
    final client = Provider.of<Client>(context, listen: false),
      tag = await showDialog(context: context, builder: (context) => TagSearchDialog());

    if (tag == null) {
      return; // user canceled
    }

    setState(() => _tags.add(tag));

    try {
      await client.followTag(tag);
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to follow #$tag", e, s);

      setState(() => _tags.remove(tag));
    }
  }

  _removeTag(String tag) async {
    final client = Provider.of<Client>(context, listen: false),
      position = _tags.indexOf(tag);

    setState(() => _tags.removeAt(position));

    try {
      await client.unfollowTag(tag);
    } catch (e, s) {
      showErrorSnackBar(_scaffold.currentState, "Failed to unfollow #$tag", e, s);

      setState(() => _tags.insert(position, tag));
    }
  }
}