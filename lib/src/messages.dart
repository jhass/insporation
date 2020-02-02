import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import 'client.dart';
import 'markdown_extensions.dart' as mde;

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

class NsfwShield extends StatefulWidget {
  NsfwShield({@required this.author, @required this.nsfwPost});

  final Person author;
  final bool nsfwPost;

  @override
  State<StatefulWidget> createState() => _NsfwShieldState();
}

class _NsfwShieldState extends State<NsfwShield> {
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _hide = widget.nsfwPost;
  }

  @override
  Widget build(BuildContext context) {
    final showNsfw = Provider.of<ValueNotifier<bool>>(context);
    return Visibility(
        visible: _hide && !showNsfw.value,
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