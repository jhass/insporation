import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/error_message.dart';
import 'src/posts.dart';

class StreamPage extends StatefulWidget {
  StreamPage({Key key, this.type, this.tag}) : super(key: key);

  final StreamType type;
  final String tag;

  @override
  _StreamPageState createState() => _StreamPageState();

  String get title {
    switch (type) {
    case StreamType.main:
      return "Stream";
    case StreamType.activity:
      return "Activity";
    case StreamType.tag:
      return "#$tag";
    }

    return "Stream";
  }
}

class _StreamPageState extends State<StreamPage> {
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  PostStream _posts;
  String _lastError;
  ScrollController _listScrollController = ScrollController();
  var _upButtonVisibility = false;
  ValueNotifier<bool> _showNsfw = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _posts = PostStream(type: widget.type, tag: widget.tag);

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _refreshIndicator.currentState.show());
    _listScrollController.addListener(() {
      final newVisibility = _listScrollController.offset >= 800;
      if (newVisibility != _upButtonVisibility) {
        setState(() => _upButtonVisibility = newVisibility);
      }

      if (_listScrollController.offset >= _listScrollController.position.maxScrollExtent - 200)  {
        _loadPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: widget.type != StreamType.tag ? BottomNavigationBar(
          currentIndex: 0,
          onTap: (item) {
            if (item == 1) {
              Navigator.pushReplacementNamed(context, '/switch_user');
            }
          },
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.view_stream),
              title: Text("Stream")
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_forward),
              title: Text("Leave")
            )
          ],
        ) : null,
        appBar: widget.type == StreamType.tag ? AppBar(
          title: Text(widget.title),
        ) : null,
        body: RefreshIndicator(
          key: _refreshIndicator,
          onRefresh: () => _loadPosts(reset: true),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: _posts),
                ChangeNotifierProvider.value(value: _showNsfw)
              ],
              child: Consumer<PostStream>(
                builder: (context, posts, _) => Visibility(
                  visible:  posts.length > 0,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: posts.length > 0 ? posts.length + 2 : 0,
                        controller: _listScrollController,
                        itemBuilder: (context, position) =>
                          position == 0 ? _StreamTypeSelector(currentType: widget.type, error: _lastError) :
                            position > posts.length ?
                              Visibility(
                                visible: posts.loading,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              ) :
                              PostView(post: posts[position - 1]),
                      ),
                      Positioned(
                        right: 8,
                        top: 48,
                        child: AnimatedSwitcher(
                          transitionBuilder: (child, animation) => FadeTransition(child: child, opacity: animation),
                          duration: Duration(milliseconds: 300),
                          child: !_upButtonVisibility ? SizedBox.shrink() : ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: Colors.black38,
                              child: IconButton(
                                color: Colors.white,
                                padding: const EdgeInsets.all(0),
                                iconSize: 48,
                                icon: Icon(Icons.keyboard_arrow_up),
                                onPressed: () =>
                                  _listScrollController.animateTo(1, duration: Duration(seconds: 1), curve: Curves.easeOut),
                              ),
                            ),
                          ),
                        ),
                      )
                    ]
                  ),
                  replacement: _StreamFallback(error: _lastError, loading: _posts.loading)
                ),
              ),
          )
        )
      )
    );
  }

  @override
  dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  _loadPosts({bool reset = false}) async {
    try {
      final client = Provider.of<Client>(context, listen: false);
      Future<void> progress;
      setState(() {
        _lastError = null;
        progress = _posts.load(client, reset: reset);
      });
      if (reset) {
        _showNsfw.value = false;
      }
      await progress;
      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace:  s);
      if (mounted) {
        setState(() {
          _lastError = e.toString();
        });
      }
    }
  }
}

class _StreamTypeSelector extends StatelessWidget {
  _StreamTypeSelector({Key key, @required this.currentType, this.error}) : super(key: key);

  final StreamType currentType;
  final String error;

  @override
  Widget build(BuildContext context) {
    if (currentType == StreamType.tag) {
      return ErrorMessage(error);
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ErrorMessage(error),
          ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentType,
              icon: Icon(Icons.arrow_downward),
              iconSize: 32,
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.black
              ),
              underline: SizedBox.shrink(),
              onChanged: (newValue) {
                if (newValue != currentType) {
                  Navigator.pushReplacementNamed(context, '/stream/${describeEnum(newValue)}');
                }
              },
              items: <DropdownMenuItem>[
                DropdownMenuItem(
                    child: Text("Stream"),
                    value: StreamType.main
                ),
                DropdownMenuItem(
                    child: Text("Activity"),
                    value: StreamType.activity
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamFallback extends StatelessWidget {
  _StreamFallback({Key key, this.error, this.loading = false}) : super(key: key);

  final String error;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewportConstraints) =>
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight
          ),
          child: SafeArea(
            child: Column(
              children: <Widget>[
                ErrorMessage(error),
                Visibility(
                  visible: !loading,
                  replacement: SizedBox( // We need to take up some space so the refresh indicator renders
                    width: viewportConstraints.maxWidth,
                    height: viewportConstraints.maxHeight
                  ),
                  child: Center(
                    child: Text("Darn, no posts!"),
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}
