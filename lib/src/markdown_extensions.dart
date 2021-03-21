import 'dart:convert';

import 'package:markdown/markdown.dart';

import 'client.dart';
import 'posix_bracket_expressions.dart' as pbe;

class SubscriptSyntax extends TagSyntax {
  SubscriptSyntax() : super(r'~(?!~)');

  @override
  Node close(InlineParser parser, Delimiter opener, Delimiter closer,
      {required List<Node> Function() getChildren}) {
    return Element('sub', getChildren());
  }
}

class SuperscriptSyntax extends TagSyntax {
  SuperscriptSyntax() : super(r'\^', startCharacter: 0x5e);


  @override
  Node close(InlineParser parser, Delimiter opener, Delimiter closer,
      {required List<Node> Function() getChildren}) {
    return Element('sup', getChildren());
  }
}

class TagLinkSyntax extends InlineSyntax  {
  TagLinkSyntax() : super(r'(?<=^|\s)#([' + pbe.word +  r'\u055b\u055c\u055e\u058a_\-]+|<3)');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final tag = match[0]!, name = match[1], url =  'eu.jhass.insporation://tags/$name';
    final anchor = Element.text('a', parser.document.encodeHtml ? HtmlEscape(HtmlEscapeMode.element).convert(tag) : tag);
    anchor.attributes['href'] = Uri.encodeFull(url);
    parser.addNode(anchor);

    return true;
  }
}

typedef MentionNameLookup = Person? Function(String diasporaId, String? inlineName);

class MentionLinkSyntax extends InlineSyntax {
  final MentionNameLookup lookup;

  MentionLinkSyntax(this.lookup) : super(r'@\{(?:([^}]+?); )?([^\} ]+)\}');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final diasporaId = match[2]!.trim(), inlineName = _presence(match[1]?.trim());
    final person = lookup(diasporaId, inlineName);
    if (person != null) {
      final url = 'eu.jhass.insporation://people/${person.guid}',
        anchor = Element.text('a', parser.document.encodeHtml ? HtmlEscape(HtmlEscapeMode.element).convert(person.nameOrId) : person.nameOrId);
      anchor.attributes['href'] = Uri.encodeFull(url);
      parser.addNode(anchor);
    } else {
      parser.addNode(Element.text('span', inlineName ?? diasporaId));
    }

    return true;
  }
}

String? _presence(String? string) {
  if (string == null || string.trim().isEmpty) {
    return null;
  } else {
    return string;
  }
}

class DiasporaAutolinkSyntax extends InlineSyntax {
  DiasporaAutolinkSyntax() : super(r'diaspora://([\w.]+@[\w.]+)/post/(\w+)\b');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final diasporaId = match[1], postGuid = match[2],
      anchor = Element.text('a', "$diasporaId/$postGuid");

    anchor.attributes["href"] = "eu.jhass.insporation://posts/$postGuid";
    parser.addNode(anchor);

    return true;
  }
}
