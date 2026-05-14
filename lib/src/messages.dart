import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
      return SelectionArea(child: Html(
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
        style: {
          // Override flutter_html defaults to avoid excessive spacing around markdown separators.
          "body": Style(margin: Margins.zero),
          "p": Style(margin: Margins.symmetric(vertical: 16, unit: Unit.px)),
          "hr": Style(
            margin: Margins.symmetric(vertical: 16, unit: Unit.px),
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        },
        onLinkTap: (url, _, __) {
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
            openExternalUrl(context, "https:$url");
          } else {
            openExternalUrl(context, url);
          }
        },
        extensions: [
          ImageExtension(
            builder: (extensionContext) => _renderImage(extensionContext)
          )
        ]
      ));
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

  Widget _renderImage(ExtensionContext context) {
    final src = context.attributes['src'];
    if (src == null) {
      return SizedBox();
    }

    return GestureDetector(
      onTap: () {
        // Don't trigger photobox for linked images
        if (context.element?.parent?.localName != 'a') {
          Photobox.show(context.buildContext!, src);
        }
      },
      child: RemoteImage(src)
    );
  }
}

class Photobox extends StatefulWidget {
  static show(BuildContext context, String url, {List<String>? urls, int initialIndex = 0}) => Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, _, __) => Photobox(
        imageUrls: urls ?? [url],
        initialIndex: initialIndex,
      ),
      opaque: false,
      transitionDuration: Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
      barrierColor: colors.barrier,
      barrierDismissible: true,
      maintainState: true,
      fullscreenDialog: false,
    )
  );

  Photobox({Key? key, required this.imageUrls, this.initialIndex = 0}) : super(key: key);

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<Photobox> createState() => _PhotoboxState();
}

class _PhotoboxState extends State<Photobox> {
  late int _current;
  late PageController _pageController;
  bool _showIndicator = true;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.imageUrls.length > 1;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.imageUrls.length,
            pageController: _pageController,
            onPageChanged: (index) => setState(() => _current = index),
            scaleStateChangedCallback: (scaleState) {
              final zoomed = scaleState != PhotoViewScaleState.initial &&
                  scaleState != PhotoViewScaleState.zoomedOut;
              if (mounted && _showIndicator == zoomed) {
                setState(() => _showIndicator = !zoomed);
              }
            },
            builder: (context, index) => PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(widget.imageUrls[index]),
              maxScale: PhotoViewComputedScale.covered * 3,
              minScale: PhotoViewComputedScale.contained,
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.transparent),
            scrollPhysics: const BouncingScrollPhysics(),
          ),
          if (hasMultiple)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showIndicator ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageUrls.length, (index) =>
                    Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _current
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    )
                  ),
                ),
              ),
            ),
        ],
      ),
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
          color: Colors.black.withValues(alpha: 0.95),
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
