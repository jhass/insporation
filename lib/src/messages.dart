import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';
import 'markdown_extensions.dart' as mde;

class PersonHeader extends StatelessWidget {
  const PersonHeader({Key key, @required this.person}) : super(key: key);

  final Person person;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "/profile", arguments: person),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
            child: Container(
              width: 24,
              height: 24,
              child: person.avatar != null ? ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Icon(Icons.person),
                  imageUrl: person.avatar,
                  fadeInDuration: Duration(milliseconds: 250),
                  fit: BoxFit.cover,
                )
              ) : Icon(Icons.person),
            )
          ),
          Flexible(
            child: Text(
              person.name ?? person.diasporaId,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12
              )
            )
          )
        ],
      ),
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
      shrinkWrap: true,
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
            mentionedPeople != null ? mentionedPeople[diasporaId] : null),
          mde.DiasporaAutolinkSyntax()
        ]
      ),
      onLinkTap: (url) {
        if (url.startsWith('eu.jhass.insporation://tags/')) {
          final tag = Uri.decodeFull(url.split(r'/').last);
          Navigator.pushNamed(context, '/stream/tag', arguments: tag);
        } else if (url.startsWith('eu.jhass.insporation://people/')) {
          Navigator.pushNamed(context, '/profile', arguments: url.split('/').last);
        } else if (url.startsWith('eu.jhass.insporation://posts/')) {
          Navigator.pushNamed(context, '/post', arguments: url.split('/').last);
        } else {
          launch(url);
        }
      },
      onImageTap: (url) => Photobox.show(context, url)
    );
  }
}

class Photobox extends StatelessWidget {
  static show(BuildContext context, String url) => Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, _, __) => Photobox(url),
      opaque: false,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
      barrierColor: Colors.black54,
      barrierDismissible: true,
      maintainState: true,
      fullscreenDialog: false,
    )
  );

  Photobox(this.imageUrl, {Key key}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureZoomBox(
      maxScale: 3,
      doubleTapScale: 2,
      onPressed: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Center(child: CircularProgressIndicator())
        )
      )
    );
  }
}

class NsfwShield extends StatefulWidget {
  NsfwShield({Key key, @required this.author, @required this.nsfwPost}) : super(key: key);

  final Person author;
  final bool nsfwPost;

  @override
  State<StatefulWidget> createState() => _NsfwShieldState();
}

class ShowNsfwPosts extends ValueNotifier<bool> {
  ShowNsfwPosts({bool initial = false}) : super(initial);
}

class _NsfwShieldState extends State<NsfwShield> {
  bool _hide;

  @override
  Widget build(BuildContext context) {
    final showNsfw = Provider.of<ShowNsfwPosts>(context);
    return Visibility(
        visible: widget.nsfwPost == true && _hide != false && showNsfw.value == false,
        child: Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.95),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "NSFW post by ${widget.author.name}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: FlatButton(
                          child: Text(
                            "Show all NSFW posts",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue)
                          ),
                          onPressed: () => showNsfw.value = true
                        ),
                      ),
                      SizedBox(height: 32, child: VerticalDivider(color: Colors.white)),
                      Flexible(
                        child: FlatButton(
                          child: Text(
                            "Show this post",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue)
                          ),
                          onPressed: () => setState(() => _hide = false),
                        )
                      )
                    ],
                  )
                )
            ],
          )
      )
    );
  }
}
