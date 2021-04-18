import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:gesture_zoom_box/gesture_zoom_box.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';
import 'localizations.dart';
import 'markdown_extensions.dart' as mde;
import 'colors.dart'  as colors;
import 'utils.dart';
import 'widgets.dart';

class PersonHeader extends StatelessWidget {
  const PersonHeader({Key? key, required this.person}) : super(key: key);

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
            child: Avatar(person: person)
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

class Message extends StatelessWidget with LocalizationHelpers {
  Message({Key? key, required this.body, this.mentionedPeople, this.debugInfo}) : super(key: key);

  final String body;
  final Map<String, Person>? mentionedPeople;
  final String? debugInfo;

  @override
  Widget build(BuildContext context) {
    try {
      return Html(
        shrinkWrap: true,
        data: md.markdownToHtml(
          body,
          blockSyntaxes: [
            md.TableSyntax(),
            md.FencedCodeBlockSyntax()
          ],
          inlineSyntaxes: [
            md.InlineHtmlSyntax(),
            mde.SuperscriptSyntax(),
            mde.SubscriptSyntax(),
            md.StrikethroughSyntax(),
            md.AutolinkExtensionSyntax(),
            mde.TagLinkSyntax(),
            mde.MentionLinkSyntax((diasporaId, inlineName) {
              final people = mentionedPeople;
              return people != null ? people[diasporaId] : null;
            }),
            mde.DiasporaAutolinkSyntax()
          ],
        ),
        onLinkTap: (url, _, __, ___) {
          if (url == null) {
            return;
          } else if (url.startsWith('eu.jhass.insporation://tags/')) {
            final tag = Uri.decodeFull(url.split(r'/').last);
            Navigator.pushNamed(context, '/stream/tag', arguments: tag);
          } else if (url.startsWith('eu.jhass.insporation://people/')) {
            Navigator.pushNamed(context, '/profile', arguments: url.split('/').last);
          } else if (url.startsWith("/people?q=")) {
            Navigator.pushNamed(context, '/profile', arguments: url.split("q=").last);
          } else if (url.startsWith('eu.jhass.insporation://posts/')) {
            Navigator.pushNamed(context, '/post', arguments: url.split('/').last);
          } else if (url.startsWith("/posts/")) {
            final guid = url.split('/').last;
            if (guid.length >= 16) {
              Navigator.pushNamed(context, '/post', arguments: guid);
            }
          } else if (url.startsWith("//")) { // scheme independent link hack, assume https
            launch("https:$url");
          } else {
            launch(url);
          }
        },
        customRender: {
          'img': (_, __, attributes, node) =>_renderImage(context, attributes, node)
        }
      );
    } catch (e) {
      final theme = Theme.of(context), debugInfo = this.debugInfo;
      return Container(
        color: theme.colorScheme.error,
        alignment: Alignment.center,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l(context).failedToRenderMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onError)),
          ),
          if (debugInfo != null) Row(children: [
            IconButton(
              icon: Icon(Icons.copy),
              color: theme.colorScheme.onError,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: debugInfo));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l(context).detailsOnErrorCopied)));
              }
            ),
            SelectableText(debugInfo, style: TextStyle(
              color: theme.colorScheme.onError,
              fontFamily: 'monospace',
              fontFamilyFallback: ['Courier']
            ))
          ])
        ],)
      );
    }
  }

  Widget? _renderImage(BuildContext context, Map<String, String> attributes, dom.Element? node) {
    final src = attributes['src'];
    if (src == null) {
      return null;
    }

    return GestureDetector(
      onTap: () {
        // Don't trigger photobox for linked images
        if (node?.parent?.localName != 'a') {
          Photobox.show(context, src);
        }
      },
      child: RemoteImage(src)
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
      barrierColor: colors.barrier,
      barrierDismissible: true,
      maintainState: true,
      fullscreenDialog: false,
    )
  );

  Photobox(this.imageUrl, {Key? key}) : super(key: key);

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureZoomBox(
      maxScale: 3,
      doubleTapScale: 2,
      onPressed: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: RemoteImage(imageUrl)
      )
    );
  }
}

class NsfwShield extends StatefulWidget {
  NsfwShield({Key? key, required this.author, required this.nsfwPost}) : super(key: key);

  final Person author;
  final bool nsfwPost;

  @override
  State<StatefulWidget> createState() => _NsfwShieldState();
}

class ShowNsfwPosts extends ValueNotifier<bool> {
  ShowNsfwPosts({bool initial = false}) : super(initial);
}

class _NsfwShieldState extends State<NsfwShield> with StateLocalizationHelpers {
  bool _shieldVisible = true;

  @override
  Widget build(BuildContext context) {
    final showNsfw = context.tryWatch<ShowNsfwPosts?>();

    return Visibility(
        visible: widget.nsfwPost == true && _shieldVisible && (showNsfw != null && showNsfw.value == false),
        child: Container(
          alignment: Alignment.center,
          color: Colors.black.withOpacity(0.95),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                l.nsfwShieldTitle(widget.author.nameOrId),
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
                        child: TextButton(
                          child: Text(
                            l.showAllNsfwPostsButtonLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.link)
                          ),
                          onPressed: () => showNsfw?.value = true
                        ),
                      ),
                      SizedBox(height: 32, child: VerticalDivider(color: Colors.white)),
                      Flexible(
                        child: TextButton(
                          child: Text(
                            l.showThisNsfwPostButtonLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.link)
                          ),
                          onPressed: () => setState(() => _shieldVisible = false),
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
