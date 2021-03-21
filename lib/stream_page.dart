import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'publisher_page.dart';
import 'src/aspects.dart';
import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/persistence.dart';
import 'src/posts.dart';
import 'src/search.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class StreamPage extends StatefulWidget {
  StreamPage({Key? key, this.options = const StreamOptions()}) : super(key: key);

  final StreamOptions options;

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends ItemStreamState<Post, StreamPage> with PostStreamState<StreamPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.options.type != StreamType.tag) {
      context.read<PersistentState>().lastStreamOptions = widget.options;
    }
  }

  @override
  ItemStream<Post> createStream() => PostStream(options: widget.options);

  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.options.type != StreamType.tag ? NavigationBar(currentPage: PageType.stream) : null,
      appBar: widget.options.type == StreamType.tag ? AppBar(
        title: Text(title),
      ) : null,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          PublisherOptions? options;
          if (widget.options.type == StreamType.tag) {
            options = PublisherOptions(prefill: "#${widget.options.tag} ");
          } else if (widget.options.type == StreamType.aspects && widget.options.aspects != null) {
            options = PublisherOptions(target: PublishTarget.aspects(widget.options.aspects));
          }
          final Post? post = await Navigator.pushNamed(context, "/publisher", arguments: options);

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
    final selector = _StreamTypeSelector(currentType: widget.options.type);
    if (widget.options.type == StreamType.aspects) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          selector,
          Padding(
            padding: EdgeInsets.all(8),
            child: _AspectsSelector(currentSelection: widget.options.aspects),
          )
        ],
      );
    } else if (widget.options.type == StreamType.followedTags) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          selector,
          Padding(
            padding: EdgeInsets.all(8),
            child: OutlinedButton(
              child: Text(l.manageFollowedTags, style: TextStyle(fontSize: 16)),
              onPressed: () async {
                await Navigator.push(context, PageRouteBuilder(
                  pageBuilder: (context, _, __) => _FollowedTagsPage()
                ));

                items.load(context.read<Client>(), reset: true);
              },
            )
          )
        ],
      );
    } else {
      return selector;
    }
  }

  String get title {
    switch (widget.options.type) {
      case StreamType.tag:
        return "#${widget.options.tag}";
      default:
        return l.streamName(widget.options.type);
    }
  }
}

class _StreamTypeSelector extends StatelessWidget with LocalizationHelpers {
  _StreamTypeSelector({Key? key, required this.currentType}) : super(key: key);

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
          onChanged: (StreamType? newValue) {
            if (newValue != null && newValue != currentType) {
              Navigator.pushReplacementNamed(context, '/stream', arguments: StreamOptions(type: newValue));
            }
          },
          items: const [StreamType.main, StreamType.activity, StreamType.aspects, StreamType.followedTags,
            StreamType.mentions, StreamType.liked, StreamType.commented].map((type) =>
              DropdownMenuItem(child: Text(l(context).streamName(type)), value: type)).toList()
        ),
      ),
    );
  }
}

class _AspectsSelector extends StatefulWidget {
  _AspectsSelector({Key? key, required this.currentSelection}) : super(key: key);

  final List<Aspect>? currentSelection;

  @override
  State<StatefulWidget> createState() => _AspectsSelectorState();
}

class _AspectsSelectorState extends State<_AspectsSelector> with StateLocalizationHelpers {
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: Icon(Icons.arrow_drop_down, size: 28),
    label: Text(_label, style: TextStyle(fontSize: 16)),
    onPressed: _updateAspects
  );

  String get _label {
    final currentSelection = widget.currentSelection;
    if (currentSelection == null || currentSelection.length == 0) {
      return l.aspectStreamSelectorAllAspects;
    } else if (currentSelection.length == 1) {
      return currentSelection.first.name;
    } else {
      return l.aspectStreamSelectorAspects(currentSelection.length);
    }
  }

  void _updateAspects() async {
    List<Aspect>? newAspects = await showDialog(
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

    Navigator.pushReplacementNamed(context, "/stream", arguments: StreamOptions.aspects(newAspects));
  }
}

class _FollowedTagsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FollowedTagsPageState();
}

class _FollowedTagsPageState extends State<_FollowedTagsPage> with StateLocalizationHelpers {
  List<String> _tags = <String>[];
  String? _lastError;

  @override
  void initState() {
    super.initState();

    _fetch();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(l.followedTagsPageTitle)),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: _addTag
    ),
    body: _tags.isEmpty && _lastError == null ? Center(child: CircularProgressIndicator()) :
      _lastError != null ? ErrorMessage(_lastError, onRetry: _fetch) :
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
    context.read<Client>().fetchFollowedTags()
      .then((tags) => setState(() => _tags = tags))
      .catchError((error) => setState(() => _lastError = error.toString()));
  }

  _addTag() async {
    final client = context.read<Client>(),
      tag = await showDialog(context: context, builder: (context) => TagSearchDialog()) as String?;

    if (tag == null) {
      return; // user canceled
    }

    setState(() => _tags.add(tag));

    try {
      await client.followTag(tag);
    } catch (e, s) {
      showErrorSnackBar(ScaffoldMessenger.of(context), l.failedToFollowTag(tag), e, s);

      setState(() => _tags.remove(tag));
    }
  }

  _removeTag(String tag) async {
    final client = context.read<Client>(),
      position = _tags.indexOf(tag);

    setState(() => _tags.removeAt(position));

    try {
      await client.unfollowTag(tag);
    } catch (e, s) {
      showErrorSnackBar(ScaffoldMessenger.of(context), l.failedToUnfollowTag(tag), e, s);

      setState(() => _tags.insert(position, tag));
    }
  }
}
