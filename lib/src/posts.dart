import 'dart:io' show Platform;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'client.dart';
import 'comments.dart';
import 'item_stream.dart';
import 'localizations.dart';
import 'messages.dart';
import 'timeago.dart';
import 'utils.dart';
import 'colors.dart' as colors;
import 'widgets.dart';

enum StreamType { main, activity, aspects, mentions, followedTags, liked, commented, tag }

class StreamOptions {
  final StreamType type;
  final List<Aspect>? aspects;
  final String? tag;

  const StreamOptions({this.type = StreamType.main, this.aspects, this.tag});
  const StreamOptions.aspects(this.aspects) : type = StreamType.aspects, tag = null;

  factory StreamOptions.from(Map<String, dynamic> object) => StreamOptions(
    type: StreamType.values.firstWhere((type) => describeEnum(type) == object["type"]),
    aspects: object["aspects"] != null ? Aspect.fromList(object["aspects"].cast<Map<String, dynamic>>()) : null,
    tag: object["tag"]
  );

  Map<String, dynamic> toJson() => {
    "type": describeEnum(type),
    "aspects": aspects,
    "tag": tag
  };
}

class PostStream extends ItemStream<Post> {
  final StreamOptions options;
  bool loading = false;

  PostStream({this.options = const StreamOptions()});

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

  replaceMock({required Post mock, required Post replacement}) {
    assert(length > 0, "No stream created!");
    assert(contains(mock), "Mock not in stream!");

    replace(toRemove: mock, replacement: replacement);
  }

  @override
  Future<Page<Post>> loadPage({required Client client, String? page}) {
      switch (options.type) {
        case StreamType.main:
          return client.fetchMainStream(page: page);
        case StreamType.activity:
          return client.fetchActivityStream(page: page);
        case StreamType.aspects:
          return client.fetchAspectsStream(options.aspects, page: page);
        case StreamType.mentions:
          return client.fetchMentionsStream(page: page);
        case StreamType.followedTags:
          return client.fetchFollowedTagsStream(page: page);
        case StreamType.liked:
          return client.fetchLikedStream(page: page);
        case StreamType.commented:
          return client.fetchCommentedStream(page: page);
        case StreamType.tag:
          return client.fetchTagStream(options.tag!, page: page);
      }
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
  PostStreamItem({Key? key, required this.post})  : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      child: PostView(post: post, linkToSPV: true),
      startActionPane: ActionPane(
        motion: ScrollMotion(),
        extentRatio: 0.2,
        children: <Widget>[PostActionsView(post: post)]
      )
    );
  }
}

class PostView extends StatelessWidget with LocalizationHelpers {
  PostView({Key? key, required this.post, this.enableCommentsSheet = true,
    this.linkToSPV = false, this.limitHeight = true})  : super(key: key);

  final Post post;
  final bool enableCommentsSheet;
  final bool linkToSPV;
  final bool limitHeight;

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
                    PersonHeader(person: post.root != null ? post.root!.author : post.author),
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
                _buildContent(context),
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
                            color: Theme.of(context).iconTheme.color?.withOpacity(0.5)
                        ),
                      ),
                      GestureDetector(
                        onTap: linkToSPV ? () { Navigator.pushNamed(context, "/post", arguments: post); } : null,
                        child: Timeago(post.createdAt, textStyle: TextStyle(fontSize: 10, fontStyle: FontStyle.italic))
                      ),
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

  Widget _buildContent(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: post.photos.length > 0,
          child: _PhotoSlider(photos: post.photos)
        ),
        !post.reshareOfDeleted ? Message(
          body: post.body,
          mentionedPeople: post.mentionedPeople,
          debugInfo: "Post ${post.guid}"
        ) : Container(
          padding: EdgeInsets.all(16),
          color: Colors.black87,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.warning, color: Colors.white)
              ),
              Expanded(child: Text(
                l(context).deletedPostReshareHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)
              ))
            ]
          )
        ),
        _PollView(post: post),
        _OEmbedView(oEmbed: post.oEmbed),
        _OpenGraphView(object: post.openGraphObject),
        _LocationView(location: post.location),
      ],
    );

    if (limitHeight) {
      return ExpandChildMaxHeight(
        child: content
      );
    } else {
      return content;
    }
  }
}

class _PostInteractionsView extends StatefulWidget {
  _PostInteractionsView({Key? key, required this.post, this.enableCommentsSheet = true}) : super(key: key);

  final Post post;
  final bool enableCommentsSheet;

  @override
  State<StatefulWidget> createState() => _PostInteractionsViewState();
}

class _PostInteractionsViewState extends State<_PostInteractionsView> with StateLocalizationHelpers, TickerProviderStateMixin {
  bool _updatingLike = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ButtonTheme(
      minWidth: 1,
      padding: const EdgeInsets.all(0),
      height: 24,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Row(
        children: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.comment, size: 16),
            label: Text(widget.post.interactions.comments.toString()),
            style: TextButton.styleFrom(foregroundColor: colors.postInteractionIcon(theme)),
            onPressed: !widget.enableCommentsSheet || !widget.post.canComment ? null : () =>
              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (context, _, __) =>  FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: 0.65,
                  child: BottomSheet(
                    onClosing: () {},
                    animationController: BottomSheet.createAnimationController(this),
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
                barrierColor: colors.barrier,
                barrierDismissible: true,
                maintainState: true,
                fullscreenDialog: false,
              )
            )
          ),
          TextButton.icon(
            icon: Icon(
                Icons.repeat,
                size: 16,
                color: widget.post.interactions.reshared ? colors.reshared : null
            ),
            label: Text(widget.post.interactions.reshares.toString()),
            style: TextButton.styleFrom(foregroundColor: colors.postInteractionIcon(theme)),
            onPressed: !widget.post.canReshare ? null : _promptReshare,
          ),
          TextButton.icon(
            icon: Icon(
                Icons.favorite,
                size: 16,
                color: widget.post.interactions.liked ? colors.liked : null
            ),
            label: Text(widget.post.interactions.likes.toString()),
            style: TextButton.styleFrom(foregroundColor: colors.postInteractionIcon(theme)),
            onPressed: _updatingLike || !widget.post.canLike ? null : _toggleLike
          ),
        ]
      ),
    );
  }

  _toggleLike() async {
    final scaffold = ScaffoldMessenger.of(context),
      client = context.read<Client>(),
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
      widget.post.interactions.liked = current;
      widget.post.interactions.likes = currentCount;

      if (mounted) {
        showErrorSnackBar(scaffold, current ? l.failedToUnlikePost : l.failedToLikePost, e, s);
        setState(() => _updatingLike = false);
      }
    }
  }

  _promptReshare() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.resharePrompt),
        actions: <Widget>[
          TextButton(
            child: Text(ml.cancelButtonLabel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text(l.confirmReshare),
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
    final scaffold = ScaffoldMessenger.of(context),
      client = context.read<Client>(),
      itemStream = context.tryRead<ItemStream<Post>>(),
      postStream = itemStream is PostStream ? itemStream : null;
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
      showErrorSnackBar(scaffold, l.failedToResharePost, e, s);

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
  PostActionsView({Key? key, required this.post, this.orientation = Axis.vertical}) : super(key: key);

  final Post post;
  final Axis orientation;

  @override
  State<StatefulWidget> createState() => _PostActionsViewState();
}

class _PostActionsViewState extends State<PostActionsView> with StateLocalizationHelpers {
  final _reportField = TextEditingController();
  bool _updatingSubscription = false;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      IconButton(
        icon: Icon(Icons.notifications, color: widget.post.interactions.subscribed ? Theme.of(context).colorScheme.secondary : null),
        onPressed: _updatingSubscription ? null : _toggleSubscription,
        tooltip: widget.post.interactions.subscribed ? l.cancelPostSubscription : l.startPostSubscription
      ),
      IconButton(
        icon: Icon(widget.post.ownPost ? Icons.delete : Icons.visibility_off),
        onPressed: widget.post.ownPost ? _promptDelete : _removePost,
        tooltip: widget.post.ownPost ? ml.deleteButtonTooltip : l.hidePost,
      )
    ];

    if (!widget.post.ownPost && !widget.post.interactions.reported) {
      actions.add(IconButton(icon: Icon(Icons.flag), onPressed: _promptReport, tooltip: l.reportPost));
    }

    if (widget.post.isReshare) {
      actions.add(IconButton(icon: Icon(Icons.keyboard_return), onPressed: _showOriginalPost, tooltip: l.showOriginalPost));
    }

    if (widget.post.public) {
      actions.add(
        IconButton(
            icon: Icon(Platform.isIOS ? Icons.ios_share : Icons.share),
            onPressed: _sharePost
        ),
      );
    }
    return widget.orientation ==  Axis.vertical ? Column(children: actions) : Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  @override
  void dispose() {
    super.dispose();
    _reportField.dispose();
  }

  _toggleSubscription() async {
    final scaffold = ScaffoldMessenger.of(context),
      client = context.read<Client>(),
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
      showErrorSnackBar(scaffold, current ? l.failedToUnsubscribeFromPost : l.failedToSubscribeToPost, e, s);
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
        title: Text(l.deletePostPrompt),
        actions: <Widget>[
          TextButton(
            child: Text(l.noButtonLabel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text(l.yesButtonLabel),
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
    final scaffold = ScaffoldMessenger.of(context),
      client = context.read<Client>(),
      postStream = context.tryRead<ItemStream<Post>>();

    Slidable.of(context)?.close();

    final position = postStream?.remove(widget.post);

    try {
      if (widget.post.ownPost) {
        await client.deletePost(widget.post);
      } else {
        await client.hidePost(widget.post);
      }

      if (mounted) {
        // we're inside SPV, pop
        Navigator.pop(context);
      }
    } catch (e, s) {
      showErrorSnackBar(scaffold, widget.post.ownPost ? l.failedToDeletePost : l.failedToHidePost, e, s);

      postStream?.insert(position ?? 0, widget.post);
    }
  }

  _promptReport() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.reportPostPrompt),
        content: TextField(
          controller: _reportField,
          minLines: 1,
          decoration: InputDecoration(
            hintText: l.reportPostHint
          )
        ),
        actions: <Widget>[
          TextButton(
            child: Text(ml.cancelButtonLabel),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text(l.submitButtonLabel),
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
    final scaffold = ScaffoldMessenger.of(context),
      client = context.read<Client>();
    setState(() => widget.post.interactions.reported = true);
    Slidable.of(context)?.close();

    try {
      await client.reportPost(widget.post, report);

      if (scaffold.mounted) {
        scaffold.showSnackBar(SnackBar(
          content: Text(l.sentPostReport)
        ));
      }
    } catch(e, s) {
      if (mounted) {
        tryShowErrorSnackBar(context, l.failedToReportPost, e, s);
      }

      widget.post.interactions.reported = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  _showOriginalPost() => Navigator.pushNamed(context, "/post", arguments: widget.post.root);

  _sharePost() {
    final client = context.read<Client>(),
      hostname = client.currentUserId!.split('@').last,
      guid = widget.post.guid;
    Share.share("https://$hostname/posts/$guid");
  }

}

class _PhotoSlider extends StatefulWidget {
  _PhotoSlider({Key? key, required this.photos}) : super(key: key);

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
          itemBuilder: (context, index, _) => GestureDetector(
            onTap: () => Photobox.show(context, widget.photos[index].sizes.large),
            child: RemoteImage(
              widget.photos[index].sizes.large
            )
          ),
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.photos.length > 1,
            onPageChanged: (index, reason) => setState(() => _current = index)
          ),
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
  _PollView({Key? key, required this.post}) : poll = post.poll, super(key: key);

  final Post post;
  final Poll? poll;

  @override
  State<StatefulWidget> createState() => _PollViewState();
}

class _PollViewState extends State<_PollView> with StateLocalizationHelpers {
  bool _showAnswers = false;
  int? _currentAnswer;

  @override
  Widget build(BuildContext context) {
    final poll = widget.poll;

    if (poll == null) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(poll.question, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: poll.answers.map((answer) =>
            poll.alreadyParticipated ?
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
                onChanged: (int? value) => setState(() => _currentAnswer = value)
              )
          ).toList(),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(l.voteCount(poll.participationCount), style: TextStyle(fontSize: 12)),
            ),
            Spacer(),
            Visibility(
              visible: !poll.alreadyParticipated && poll.participationCount > 0 && !_showAnswers,
              child: TextButton(
                child: Text(l.pollResultsButtonLabel, style: TextStyle(color: colors.link)),
                onPressed: () => setState(() => _showAnswers = true)
              )
            ),
            Visibility(
              visible: !poll.alreadyParticipated,
              child: TextButton(
                child: Text(l.voteButtonLabel),
                onPressed: _currentAnswer == null ? null : _submit,
              ),
            )
          ],
        )
      ],
    );
  }

  bool get showAnswers => widget.poll?.alreadyParticipated == true || _showAnswers;

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

  Widget? _answerSubtitle(PollAnswer answer) =>
    answer.voteCount == 0 ? null : LinearProgressIndicator(
      value: _answerPercentage(answer),
      backgroundColor: Colors.transparent
    );

  double _answerPercentage(PollAnswer answer) {
    if (widget.poll?.participationCount == 0) {
      return 0;
    }

    return answer.voteCount / widget.poll!.participationCount;
  }

  _submit() async {
    final poll = widget.poll!;
    final answer = poll.answers.singleWhere((answer) => answer.id == _currentAnswer);

    setState(() {
      _showAnswers = true;
      poll.alreadyParticipated = true;
      poll.participationCount++;
      answer.voteCount++;
      answer.own = true;
    });

    final client = context.read<Client>();
    try {
      await client.vote(widget.post, answer);
    } catch(e, s) {
      tryShowErrorSnackBar(context, l.failedToVote, e, s);

      setState(() {
        poll.alreadyParticipated = false;
        poll.participationCount--;
        answer.voteCount--;
        answer.own = false;
      });
    }

  }

  static _percentFormat(double percentage) => (percentage * 100).toStringAsFixed(0) + "%";
}

class _OEmbedView extends StatelessWidget with LocalizationHelpers {
  _OEmbedView({Key? key, this.oEmbed}) : super(key: key);

  final OEmbed? oEmbed;

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
    final oEmbed = this.oEmbed as ThumbnailOEmbed;
    return Center(
      child: GestureDetector(
        onTap: () => openExternalUrl(context, oEmbed.url),
        child: Stack(
          children: <Widget>[
            RemoteImage(
              oEmbed.thumbnail,
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
                             if (oEmbed.author != null) Text(
                              l(context).oEmbedAuthor(oEmbed.author!),
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
    final oEmbed = this.oEmbed as HtmlTextOEmbed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => openExternalUrl(context, oEmbed.url),
            child: Text(
              oEmbed.author != null ? l(context).oEmbedHeader(oEmbed.author!, oEmbed.provider) : oEmbed.provider,
              style: TextStyle(color: colors.link, decoration: TextDecoration.underline),
            )
          )
        ),
        Container(
          margin: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: Theme.of(context).dividerColor))),
          child: Html(
            onLinkTap: (url, _, __) {
              if (url != null) openExternalUrl(context, url);
            },
            data: oEmbed.html,
            extensions: [
              ImageExtension(
                builder:(context) {
                final src = context.attributes['src'];
                return src != null ? RemoteImage(src) : SizedBox();
              })
            ],
            style: {"blockquote": Style(margin: Margins.only(left: 8))},
          )
        )
      ]
    );
  }
}

class _OpenGraphView extends StatelessWidget {
  _OpenGraphView({Key? key, this.object}) : super(key: key);

  final OpenGraphObject? object;

  @override
  Widget build(BuildContext context) {
    final object = this.object;
    if (object == null || (object.title == null && object.image == null && object.description == null)) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Divider(),
        _handleTap(context,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                object.image != null ?
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: RemoteImage(object.image!, fit: BoxFit.cover)
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
                              object.title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w500)
                            )
                          ) : SizedBox.shrink(),
                        object.description != null ?
                          Text(
                            object.description!,
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

  Widget _handleTap(BuildContext context, {required Widget child}) {
    if (object?.url == null) {
      return child;
    }

    return InkWell(
      child: child,
      onTap: () => openExternalUrl(context, object!.url!)
    );
  }
}


class _LocationView extends StatelessWidget {
  _LocationView({Key? key, this.location}) : super(key: key);

  final Location? location;

  @override
  Widget build(BuildContext context) {
    final location = this.location;

    if  (location == null) {
      return SizedBox.shrink();
    }

    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(),
          InkWell(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 4.0, left: 2.0),
                  child: Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                ),
                Text(location.address, style: TextStyle(fontSize: 10)),
              ],
            ),
            onTap: () {
              if (Theme.of(context).platform == TargetPlatform.android) {
                openExternalUrl(context, "geo:0,0?q=${location.lat},${location.lng}(${Uri.encodeFull(location.address)})");
              } else {
                // TODO handle other platforms
              }
            }
          )
        ]
      )
    );
  }
}
