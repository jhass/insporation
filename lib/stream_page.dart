import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'src/client.dart';
import 'src/error_message.dart';
import 'src/markdown_extensions.dart' as mde;
import 'src/timeago.dart';

enum StreamType { main, activity, tag }

class PostStream extends ChangeNotifier {
  final StreamType type;
  final String tag;
  bool loading = false;
  Page<Post> _lastPage;
  List<Post> _posts;

  PostStream({this.type, this.tag});

  int get length => _posts?.length ?? 0;

  Post operator [](int index) => _posts[index];

  addMock(Post post) {
    assert(post.mock, "Post is not a mock!");
    if (_posts == null) {
      _posts = [post];
    } else {
      _posts.insert(0, post);
    }
    notifyListeners();
  }

  removeMock(Post post) {
    assert(post.mock, "Post is not a mock!");
    assert(_posts != null, "No stream created!");
    if (_posts != null) {
      final removed = _posts.remove(post);
      assert(removed, "Post was not in stream!");
      if (removed) {
        notifyListeners();
      }
    }
  }

  replaceMock({@required Post mock, @required Post replacement}) {
    assert(_posts != null, "No stream created!");
    if (_posts == null) {
      _posts = [replacement];
      notifyListeners();
      return;
    }

    final mockIndex = _posts.indexOf(mock);
    assert(mockIndex >= 0, "Mock post not in stream!");
    if (mockIndex >= 0) {
      _posts[mockIndex] = replacement;
    } else {
      _posts.insert(0, replacement);
    }
    notifyListeners();
  }

  Future<void> load(Client client, {bool reset = false}) {
    if (loading) {
      return Future.value();
    } else if (reset) {
      _lastPage = null;
      _posts = null;
    } else if (_lastPage != null && _lastPage.nextPage == null) {
      return Future.value();
    }

    return _load(client, page: _lastPage?.nextPage);
  }

  Future<void> _load(Client client, {page}) async {
    loading = true;

    try {
      Page<Post> newPage;
      switch (type) {
        case StreamType.main:
          newPage = await client.fetchMainStream(page: page);
          break;
        case StreamType.activity:
          newPage = await client.fetchActivityStream(page: page);
          break;
        case StreamType.tag:
          newPage = await client.fetchTagStream(tag, page: page);
          break;
      }
      _lastPage = newPage;
      if (_posts == null || page == null) {
        _posts = newPage.content;
      } else {
        _posts.addAll(newPage.content);
      }
      notifyListeners();
    } finally {
      loading = false;
    }
  }
}

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
            child: ChangeNotifierProvider.value(
              value: _posts,
              child: Consumer<PostStream>(
                builder: (context, posts, _) => Visibility(
                  visible:  posts.length > 0,
                  child: Stack(
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

class PostView extends StatelessWidget {
  PostView({Key key, @required this.post})  : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                PersonHeader(person: post.root != null ? post.root.author : post.author),
                Visibility(
                    visible: post.root != null,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.repeat, size: 18),
                        ),
                        PersonHeader(person: post.author)
                      ],
                    )
                )
              ],
            ),
            Divider(),
            Visibility(
              visible: post.photos != null && post.photos.length > 0,
              child: _PhotoSlider(photos: post.photos ?? const <Photo>[])
            ),
            Message(body: post.body, mentionedPeople: post.mentionedPeople),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                        post.public ? Icons.public : Icons.lock,
                        size: 14,
                        color: Colors.grey[600]
                    ),
                  ),
                  Timeago(post.createdAt, textStyle: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                  Spacer(),
                  _PostInteractionsView(post: post)
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

class PersonHeader extends StatelessWidget {
  const PersonHeader({Key key, @required this.person}) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Container(
            width: 24,
            height: 24,
            child: Stack(
              children: <Widget>[
                Center(child: Icon(Icons.person)),
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: FadeInImage(
                      fadeInDuration: Duration(milliseconds: 250),
                      image: person.avatar != null ?
                        NetworkImage(person.avatar) : MemoryImage(kTransparentImage),
                      placeholder: MemoryImage(kTransparentImage)
                    ),
                  )
                )
              ]
            ),
          )
        ),
        Text(
          person.name ?? person.diasporaId,
          style: TextStyle(
            fontSize: 12
          )
        )
      ],
    );
  }
}

class Message extends StatelessWidget {
  Message({Key key, @required this.body, this.mentionedPeople}) : super(key: key);

  final String body;
  final Map<String, Person> mentionedPeople;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: md.markdownToHtml(
        body,
        blockSyntaxes: [const md.TableSyntax(), const md.FencedCodeBlockSyntax()],
        inlineSyntaxes: [
          md.InlineHtmlSyntax(),
          mde.SuperscriptSyntax(),
          mde.SubscriptSyntax(),
          md.StrikethroughSyntax(),
          md.AutolinkExtensionSyntax(),
          mde.TagLinkSyntax(),
          mde.MentionLinkSyntax((diasporaId, inlineName) =>
            (mentionedPeople != null ?
              mentionedPeople[diasporaId].name  : null) ?? inlineName)
        ]
      ),
      onLinkTap: (url) {
        if (url.startsWith('eu.jhass.insporation://tags/')) {
          final tag = Uri.decodeFull(url.split(r'/').last);
          Navigator.pushNamed(context, '/stream/tag', arguments: tag);
        } else if (url.startsWith('eu.jhass.insporation://people/')) {
          // TODO
        } else {
          launch(url);
        }
      }
    );
  }
}

class _PostInteractionsView extends StatefulWidget {
  _PostInteractionsView({Key key, this.post}) : super(key: key);

  final Post post;

  @override
  State<StatefulWidget> createState() => _PostInteractionsViewState();
}

class _PostInteractionsViewState extends State<_PostInteractionsView> {
  bool _updatingLike = false;

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 1,
      padding: const EdgeInsets.all(0),
      height: 24,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row(
        children: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.comment, size: 16),
            label: Text(widget.post.interactions.comments.toString()),
            textColor: Colors.grey[600],
            onPressed: !widget.post.canComment ? null : () =>
              showModalBottomSheet(context: context, builder: (context) => CommentSheet(post: widget.post)),
          ),
          FlatButton.icon(
            icon: Icon(
                Icons.repeat,
                size: 16,
                color: widget.post.interactions.reshared ? Colors.blue[500] : null
            ),
            label: Text(widget.post.interactions.reshares.toString()),
            textColor: Colors.grey[600],
            onPressed: !widget.post.canReshare ? null : () => _promptReshare(context),
          ),
          FlatButton.icon(
            icon: Icon(
                Icons.favorite,
                size: 16,
                color: widget.post.interactions.liked ? Colors.red[900] : Colors.grey[600]
            ),
            label: Text(widget.post.interactions.likes.toString()),
            textColor: Colors.grey[600],
            onPressed: _updatingLike || !widget.post.canLike ? null : () => _toggleLike(context)
          )
        ]
      ),
    );
  }

  _toggleLike(BuildContext context) async {
    final client = Provider.of<Client>(context, listen: false);
    final current = widget.post.interactions.liked;
    final currentCount = widget.post.interactions.likes;
    setState(() {
      _updatingLike = true;
      widget.post.interactions.liked = !current;
      widget.post.interactions.likes = currentCount + (current ? -1 : 1);
    });
    try {
      if (!current) {
        await client.likePost(widget.post);
      } else {
        await client.unlikePost(widget.post);
      }
      if (mounted) {
        setState(() => _updatingLike = false);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);

      widget.post.interactions.liked = current;
      widget.post.interactions.likes = currentCount;

      if (mounted) {
        setState(() {
          _updatingLike = false;
        });
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed to ${current ? "unlike" : "like"} post: $e",
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.red
      ));
    }
  }

  _promptReshare(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text("Reshare post?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          FlatButton(
            child: Text("Reshare"),
            onPressed: () {
              _createReshare(context);
              Navigator.of(dialogContext).pop();
            },
          )
        ]
      )
    );
  }

  _createReshare(BuildContext context) async {
    final client = Provider.of<Client>(context, listen: false);
    final postStream = Provider.of<PostStream>(context, listen: false);
    setState(() {
      widget.post.interactions.reshared = true;
      widget.post.interactions.reshares++;
    });

    var mockReshare;
    try {
      final author = await client.currentUser;
      mockReshare = widget.post.mockReshare(author.person);
      postStream.addMock(mockReshare);

      final reshare = await client.resharePost(widget.post);
      if (reshare != null) {
        postStream.replaceMock(mock: widget.post, replacement: reshare);
      } else {
        postStream.removeMock(mockReshare);
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);

      setState(() {
        widget.post.interactions.reshared = false;
        widget.post.interactions.reshares--;
      });

      if (mockReshare != null) {
        postStream.removeMock(mockReshare);
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed to reshare post: $e",
          style: TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.red
      ));
    }
  }
}

class CommentSheet extends StatefulWidget {
  CommentSheet({Key key, @required this.post}) : super(key: key);

  final Post post;

  @override
  State<StatefulWidget> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  var _loading = true;
  String _lastError;
  Page<Comment> _lastPage;
  List<Comment> _comments;
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();

    _listScrollController.addListener(() {
      if (_listScrollController.offset >= _listScrollController.position.maxScrollExtent - 200) {
        _fetchMoreComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        controller: _listScrollController,
        itemCount: _comments != null ? _comments.length + 2 : 2,
        itemBuilder: (context, position) =>
          position == 0 ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text("Comments", style: TextStyle(fontSize: 18)),
              ),
              ErrorMessage(_lastError)
              ]
            ) :
            _comments == null || position > _comments.length ?
              Visibility(
                visible: _loading,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator())
                ),
              ) :
              CommentView(comment: _comments[position - 1])
      ),
    );
  }

  _fetchMoreComments() {
    if (_loading == null || _lastPage == null || _lastPage.nextPage == null) {
      return;
    }

    _fetchComments(page: _lastPage.nextPage);
  }

  _fetchComments({page}) async {
    setState(() {
      _lastError = null;
      _loading = true;
    });

    try {
      final client = Provider.of<Client>(context, listen: false),
        newComments = await client.fetchComments(widget.post, page: page);

      setState(() {
        _loading = false;
        _lastPage = newComments;
        if (_comments == null || page == null) {
          _comments = newComments.content;
        } else {
          _comments.addAll(newComments.content);
        }
      });
    } catch (e, s) {
      setState(() {
        debugPrintStack(label: e.toString(), stackTrace: s);
        _lastError = e.toString();
        _loading = false;
      });
    }

  }
}

class CommentView extends StatelessWidget {
  CommentView({Key key, @required this.comment}) : super(key: key);

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            PersonHeader(person: comment.author),
            Divider(),
            Message(body: comment.body, mentionedPeople: null) // TODO
          ],
        ),
      ),
    );
  }

}

class _PhotoSlider extends StatefulWidget {
  _PhotoSlider({Key key, @required this.photos}) : super(key: key);

  final List<Photo> photos;

  @override
  State<StatefulWidget> createState() => _PhotoSliderState();
}

class _PhotoSliderState extends State<_PhotoSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CarouselSlider.builder(
          itemCount: widget.photos.length,
          itemBuilder: (context, index) => Stack(
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
              Center(
                child: FadeInImage.memoryNetwork(
                  fadeInDuration: Duration(milliseconds: 250),
                  image: widget.photos[index].sizes.large,
                  placeholder: kTransparentImage,
                )
              )
            ]
          ),
          height: 300,
          viewportFraction: 1.0,
          enableInfiniteScroll: widget.photos.length > 1,
          onPageChanged: (index) => setState(() => _current = index),
        ),
        Visibility(
          visible: widget.photos.length > 1,
          child: Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.photos.length, (index) =>
                Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _current ?
                      Color.fromRGBO(0, 0, 0, 0.9) :
                      Color.fromRGBO(0, 0, 0, 0.4)
                  ),
                )
              )
            )
          ),
        )
      ],
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
