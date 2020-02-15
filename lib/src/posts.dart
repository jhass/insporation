import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';
import 'comments.dart';
import 'item_stream.dart';
import 'messages.dart';
import 'timeago.dart';
import 'utils.dart';

enum StreamType { main, activity, tag }

class PostStream extends ItemStream<Post> {
  final StreamType type;
  final String tag;
  bool loading = false;

  PostStream({this.type, this.tag});

  addMock(Post post) {
    assert(post.mock, "Post is not a mock!");
    insert(0, post);
  }

  removeMock(Post post) {
    assert(post.mock, "Post is not a mock!");
    assert(length > 0, "No stream created!");
    assert(contains(post), "Post was not in stream!");
    remove(post);
  }

  replaceMock({@required Post mock, @required Post replacement}) {
    assert(length > 0, "No stream created!");
    assert(contains(mock), "Mock not in stream!");

    replace(toRemove: mock, replacement: replacement);
  }

  @override
  Future<Page<Post>> loadPage({Client client, String page}) {
      switch (type) {
        case StreamType.main:
          return client.fetchMainStream(page: page);
        case StreamType.activity:
          return client.fetchActivityStream(page: page);
        case StreamType.tag:
          return client.fetchTagStream(tag, page: page);
      }

      throw "Unimplemented stream type: $type";
  }
}

mixin PostStreamState<W extends StatefulWidget> on ItemStreamState<Post, W> {
  final ShowNsfwPosts _showNsfw = ShowNsfwPosts();

  @override
  Widget buildStream(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _showNsfw,
      child: super.buildStream(context)
    );
  }

  @override
  Widget buildItem(BuildContext context, Post post) => PostStreamItem(post: post);

  @override
  void onReset() => _showNsfw.value = false;

  @override
  void dispose() {
    _showNsfw.dispose();
    super.dispose();
  }
}

class PostStreamItem extends StatelessWidget {
  PostStreamItem({Key key, @required this.post})  : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      child: PostView(post: post),
      actionPane: SlidableDrawerActionPane(),
      actions: <Widget>[PostActionsView(post: post)],
    );
  }
}

class PostView extends StatelessWidget {
  PostView({Key key, @required this.post, this.enableCommentsSheet = true})  : super(key: key);

  final Post post;
  final bool enableCommentsSheet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    PersonHeader(person: post.root != null ? post.root.author : post.author),
                    Visibility(
                        visible: post.root != null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                !post.reshareOfDeleted ? Message(body: post.body, mentionedPeople: post.mentionedPeople) :
                  Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.black87,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.warning, color: Colors.white)
                        ),
                        Text("Reshare of a deleted post", style: TextStyle(color: Colors.white))
                     ]
                    )
                  ),
                _PollView(post: post),
                _OEmbedView(oEmbed: post.oEmbed),
                _OpenGraphView(object: post.openGraphObject),
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
                      _PostInteractionsView(post: post, enableCommentsSheet: enableCommentsSheet)
                    ],
                  )
                )
              ],
            ),
          ),
          Positioned.fill(child: NsfwShield(author: post.author, nsfwPost: post.nsfw))
        ]
      ),
    );
  }
}

class _PostInteractionsView extends StatefulWidget {
  _PostInteractionsView({Key key, this.post, this.enableCommentsSheet = true}) : super(key: key);

  final Post post;
  final bool enableCommentsSheet;

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
            onPressed: !widget.enableCommentsSheet || !widget.post.canComment ? null : () =>
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (context, _, __) =>  FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.65,
                  child: BottomSheet(
                    onClosing: () {},
                    builder: (context) => Scaffold(
                      body: CommentListView(post: widget.post)
                    )
                  )
                ),
                opaque: false,
                transitionDuration: Duration(milliseconds: 400),
                transitionsBuilder: (context, animation, _, child) => FadeTransition(
                  opacity: animation, child: child
                ),
                barrierColor: Colors.black54,
                barrierDismissible: true,
                maintainState: true,
                fullscreenDialog: false,
              )
            )
          ),
          FlatButton.icon(
            icon: Icon(
                Icons.repeat,
                size: 16,
                color: widget.post.interactions.reshared ? Colors.blue[500] : null
            ),
            label: Text(widget.post.interactions.reshares.toString()),
            textColor: Colors.grey[600],
            onPressed: !widget.post.canReshare ? null : _promptReshare,
          ),
          FlatButton.icon(
            icon: Icon(
                Icons.favorite,
                size: 16,
                color: widget.post.interactions.liked ? Colors.red[900] : Colors.grey[600]
            ),
            label: Text(widget.post.interactions.likes.toString()),
            textColor: Colors.grey[600],
            onPressed: _updatingLike || !widget.post.canLike ? null : _toggleLike
          )
        ]
      ),
    );
  }

  _toggleLike() async {
    final scaffold = Scaffold.of(context),
      client = Provider.of<Client>(context, listen: false),
      current = widget.post.interactions.liked,
      currentCount = widget.post.interactions.likes;
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
      showErrorSnackBar(scaffold, "Failed to ${current ? "unlike" : "like"} post", e, s);

      widget.post.interactions.liked = current;
      widget.post.interactions.likes = currentCount;

      if (mounted) {
        setState(() => _updatingLike = false);
      }
    }
  }

  _promptReshare() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text("Reshare post?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FlatButton(
            child: Text("Reshare"),
            onPressed: () {
              _createReshare();
              Navigator.pop(dialogContext);
            },
          )
        ]
      )
    );
  }

  _createReshare() async {
    final scaffold = Scaffold.of(context),
      client = Provider.of<Client>(context, listen: false),
      postStream = tryProvide<ItemStream<Post>>(context) as PostStream;
    setState(() {
      widget.post.interactions.reshared = true;
      widget.post.interactions.reshares++;
    });

    var mockReshare;
    try {
      final author = await client.currentUser;
      mockReshare = widget.post.mockReshare(author.person);
      postStream?.addMock(mockReshare);

      final reshare = await client.resharePost(widget.post);
      if (reshare != null) {
        postStream?.replaceMock(mock: widget.post, replacement: reshare);
      } else {
        postStream?.removeMock(mockReshare);
      }
    } catch (e, s) {
      showErrorSnackBar(scaffold, "Failed to reshare post", e, s);

      setState(() {
        widget.post.interactions.reshared = false;
        widget.post.interactions.reshares--;
      });

      if (mockReshare != null) {
        postStream?.removeMock(mockReshare);
      }
    }
  }
}

class PostActionsView extends StatefulWidget {
  PostActionsView({Key key, @required this.post, this.orientation = Axis.vertical}) : super(key: key);

  final Post post;
  final Axis orientation;

  @override
  State<StatefulWidget> createState() => _PostActionsViewState();
}

class _PostActionsViewState extends State<PostActionsView> {
  final _reportField = TextEditingController();
  bool _updatingSubscription = false;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      IconButton(
        icon: Icon(Icons.notifications, color: widget.post.interactions.subscribed ? Colors.blue : null),
        onPressed: _updatingSubscription ? null : _toggleSubscription,
        tooltip: widget.post.interactions.subscribed ? "Stop notifications" : "Enable notifications"
      ),
      IconButton(
        icon: Icon(widget.post.ownPost ? Icons.delete : Icons.visibility_off),
        onPressed: widget.post.ownPost ? _promptDelete : _removePost,
        tooltip: widget.post.ownPost ? "Delete" : "Hide",
      )
    ];
    if (!widget.post.ownPost && !widget.post.interactions.reported) {
      actions.add(IconButton(icon: Icon(Icons.flag), onPressed: _promptReport, tooltip: "Report"));
    }

    return widget.orientation ==  Axis.vertical ? Column(children: actions) : Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  @override
  void dispose() {
    super.dispose();
    _reportField.dispose();
  }

  _toggleSubscription() async {
    final scaffold = Scaffold.of(context),
      client = Provider.of<Client>(context, listen: false),
      current = widget.post.interactions.subscribed;
    setState(() {
      _updatingSubscription = true;
      widget.post.interactions.subscribed = !current;
    });
    Slidable.of(context)?.close();

    try {
      if (!current) {
        await client.subscribeToPost(widget.post);
      } else {
        await client.unsubscribeFromPost(widget.post);
      }

      if (mounted) {
        setState(() => _updatingSubscription = false);
      }
    } catch (e, s) {
      showErrorSnackBar(scaffold, "Failed to ${current ? "unsubscribe from" : "subscribe to"} post", e, s);
      debugPrintStack(label: e.toString(), stackTrace: s);

      widget.post.interactions.subscribed = current;

      if (mounted) {
        setState(() => _updatingSubscription = false);
      }
    }
  }

  _promptDelete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete post?"),
        actions: <Widget>[
          FlatButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FlatButton(
            child: Text("Yes"),
            onPressed: () {
              _removePost();
              Navigator.pop(dialogContext);
            },
          )
        ],
      )
    );
  }

  _removePost() async {
    final scaffold = Scaffold.of(context),
      client = Provider.of<Client>(context, listen: false),
      postStream = tryProvide<ItemStream<Post>>(context);

    Slidable.of(context)?.close();

    final position = postStream?.remove(widget.post);

    try {
      if (widget.post.ownPost) {
        await client.deletePost(widget.post);
      } else {
        await client.hidePost(widget.post);
      }

      if (postStream == null && mounted) {
        // we're inside SPV, pop
        Navigator.pop(context);
      }
    } catch (e, s) {
      showErrorSnackBar(scaffold, "Failed to ${widget.post.ownPost ? "delete" : "hide"} post", e, s);

      postStream?.insert(position, widget.post);
    }
  }

  _promptReport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text("Report post"),
        content: TextField(
          controller: _reportField,
          minLines: 1,
          decoration: InputDecoration(
            hintText: "Please describe the issue"
          )
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          FlatButton(
            child: Text("Submit"),
            onPressed: () {
              if (_reportField.text.isNotEmpty) {
                _createReport(_reportField.text);
                Navigator.pop(dialogContext);
              }
            },
          )
        ],
      )
    );
  }

  _createReport(String report) async {
    final scaffold = Scaffold.of(context),
      client = Provider.of<Client>(context, listen: false);
    setState(() => widget.post.interactions.reported = true);
    Slidable.of(context)?.close();

    try {
      await client.reportPost(widget.post, report);

      if (scaffold.mounted) {
        scaffold.showSnackBar(SnackBar(
          content: Text("Report sent.")
        ));
      }
    } catch(e, s) {
      showErrorSnackBar(scaffold, "Failed to create report", e, s);

      widget.post.interactions.reported = false;
      if (mounted) {
        setState(() {});
      }
    }
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
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => Photobox.show(context, widget.photos[index].sizes.large),
            child: CachedNetworkImage(
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              imageUrl: widget.photos[index].sizes.large,
              fadeInDuration: Duration(milliseconds: 250),
            )
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

class _PollView extends StatefulWidget {
  _PollView({Key key, @required this.post}) : poll = post.poll, super(key: key);

  final Post post;
  final Poll poll;

  @override
  State<StatefulWidget> createState() => _PollViewState();
}

class _PollViewState extends State<_PollView> {
  bool _showAnswers = false;
  int _currentAnswer;

  @override
  Widget build(BuildContext context) {
    if (widget.poll == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.poll.question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.poll.answers.map((answer) =>
            widget.poll.alreadyParticipated ?
              ListTile(
                title: _answerTitle(answer),
                subtitle: _answerSubtitle(answer),
                selected: answer.own,
              ) :
              RadioListTile(
                title: _answerTitle(answer),
                subtitle: _showAnswers ? _answerSubtitle(answer) : null,
                value: answer.id,
                groupValue: _currentAnswer,
                onChanged: (value) => setState(() => _currentAnswer = value)
              )
          ).toList(),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("${widget.poll.participationCount} votes so far", style: TextStyle(fontSize: 12)),
            ),
            Spacer(),
            Visibility(
              visible: !widget.poll.alreadyParticipated && widget.poll.participationCount > 0 && !_showAnswers,
              child: FlatButton(
                child: Text("View results", style: TextStyle(color: Colors.blueAccent)),
                onPressed: () => setState(() => _showAnswers = true)
              )
            ),
            Visibility(
              visible: !widget.poll.alreadyParticipated,
              child: RaisedButton(
                child: Text("Vote"),
                onPressed: _currentAnswer == null ? null : _submit,
              ),
            )
          ],
        )
      ],
    );
  }

  bool get showAnswers => widget.poll.alreadyParticipated || _showAnswers;

  Widget _answerTitle(PollAnswer answer) => Row(
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Expanded(flex: 2, child: Padding(padding: EdgeInsets.only(bottom: 4), child: Text(answer.answer))),
      Expanded(
        child: Visibility(
          visible: showAnswers,
          child: Text(_percentFormat(_answerPercentage(answer)), textAlign: TextAlign.end)
        )
      )
    ]
  );

  Widget _answerSubtitle(PollAnswer answer) =>
    answer.voteCount == 0 ? null : LinearProgressIndicator(
      value: _answerPercentage(answer),
      backgroundColor: Colors.transparent
    );

  double _answerPercentage(PollAnswer answer) {
    if (widget.poll.participationCount == 0) {
      return 0;
    }

    return answer.voteCount / widget.poll.participationCount;
  }

  _submit() async {
    final answer = widget.poll.answers.singleWhere((answer) => answer.id == _currentAnswer);

    setState(() {
      _showAnswers = true;
      widget.poll.alreadyParticipated = true;
      widget.poll.participationCount++;
      answer.voteCount++;
      answer.own = true;
    });

    final client = Provider.of<Client>(context, listen: false);
    try {
      await client.vote(widget.post, answer);
    } catch(e, s) {
      tryShowErrorSnackBar(this, "Failed to vote on post", e, s);

      setState(() {
        widget.poll.alreadyParticipated = false;
        widget.poll.participationCount--;
        answer.voteCount--;
        answer.own = false;
      });
    }

  }

  static _percentFormat(double percentage) => (percentage * 100).toStringAsFixed(0) + "%";
}

class _OEmbedView extends StatelessWidget {
  _OEmbedView({Key key, this.oEmbed}) : super(key: key);

  final OEmbed oEmbed;

  @override
  Widget build(BuildContext context) {
    if (oEmbed is ThumbnailOEmbed) {
      return _buildThumbnail(context);
    } else if (oEmbed is HtmlTextOEmbed) {
      return _buildHtmlText(context);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildThumbnail(BuildContext context) {
    final ThumbnailOEmbed oEmbed = this.oEmbed;
    return Center(
      child: GestureDetector(
        onTap: () => launch(oEmbed.url),
        child: Stack(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: oEmbed.thumbnail,
              height: 300
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(32)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(Icons.play_arrow, size: 32, color: Colors.white)
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              oEmbed.title,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
                            ),
                            Text(
                              "by ${oEmbed.author}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white)
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
            )
          ],
        ),
      )
    );
  }

  Widget _buildHtmlText(BuildContext context) {
    final HtmlTextOEmbed oEmbed = this.oEmbed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => launch(oEmbed.url),
            child: Text(
              "${oEmbed.author} on ${oEmbed.provider}:",
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            )
          )
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.black54))),
          child: Html(
            onLinkTap: launch,
            data: oEmbed.html,
            style: {"blockquote": Style(margin: EdgeInsets.only(left: 8))},
          )
        )
      ]
    );
  }
}

class _OpenGraphView extends StatelessWidget {
  _OpenGraphView({Key key, this.object}) : super(key: key);

  final OpenGraphObject object;

  @override
  Widget build(BuildContext context) {
    if (object == null || (object.title == null && object.image == null && object.description == null)) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        _handleTap(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                object.image != null ?
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(imageUrl: object.image, fit: BoxFit.cover)
                    )
                  ) : SizedBox.shrink(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: object.image != null ? 8 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        object.title != null ?
                          Padding(
                            padding: EdgeInsets.only(bottom: object.description != null ? 4 : 0),
                            child: Text(
                              object.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500)
                            )
                          ) : SizedBox.shrink(),
                        object.description != null ?
                          Text(
                            object.description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ) : SizedBox.shrink()
                      ],
                    )
                  )
                )
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _handleTap({Widget child}) {
    if (object.url == null) {
      return child;
    }

    return InkWell(
      child: child,
      onTap: () => launch(object.url)
    );
  }
}
