import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'comments.dart';
import 'messages.dart';
import 'timeago.dart';

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

class PostView extends StatelessWidget {
  PostView({Key key, @required this.post})  : super(key: key);

  final Post post;

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
          Positioned.fill(child: NsfwShield(author: post.author, nsfwPost: post.nsfw))
        ]
      ),
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
  _PollView({@required this.post}) : poll = post.poll;

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
      debugPrintStack(label: e.message, stackTrace: s);
      setState(() {
        widget.poll.alreadyParticipated = false;
        widget.poll.participationCount--;
        answer.voteCount--;
        answer.own = false;
      });

      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Failed to vote on post: ${e.message}", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }

  }

  static _percentFormat(double percentage) => (percentage * 100).toStringAsFixed(0) + "%";
}