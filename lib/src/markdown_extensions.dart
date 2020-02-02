import 'dart:convert';

import 'package:markdown/markdown.dart';

import 'posix_bracket_expressions.dart' as pbe;


class SubscriptSyntax extends TagSyntax {
  SubscriptSyntax() : super(r'~(?!~)');

  @override
  bool onMatchEnd(InlineParser parser, Match match, TagState state) {
    parser.addNode(Element('sub', state.children));
    return true;
  }
}

class SuperscriptSyntax extends TagSyntax {
  SuperscriptSyntax() : super(r'\^', startCharacter: 0x5e);

  @override
  bool onMatchEnd(InlineParser parser, Match match, TagState state) {
    parser.addNode(Element('sup', state.children));
    return true;
  }
}


class TagLinkSyntax extends InlineSyntax  {
  TagLinkSyntax() : super(r'(?<=^|\s)#([' + pbe.word +  r'\u055b\u055c\u055e\u058a_\-]+|<3)\b');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final tag = match[0], name = match[1], url =  'eu.jhass.insporation://tags/$name';
    final anchor = Element.text('a', parser.document.encodeHtml ? HtmlEscape(HtmlEscapeMode.element).convert(tag) : tag);
    anchor.attributes['href'] = Uri.encodeFull(url);
    parser.addNode(anchor);

    return true;
  }
}

typedef MentionNameLookup = String Function(String diasporaId, String inlineName);

class MentionLinkSyntax extends InlineSyntax {
  final MentionNameLookup lookup;

  MentionLinkSyntax(this.lookup) : super(r'@\{(?:([^}]+?); )?([^\} ]+)\}');

  @override
  bool onMatch(InlineParser parser, Match match) {
    final diasporaId = match[2].trim(), inlineName = _presence(match[1]?.trim()),
        url = 'eu.jhass.insporation://people/$diasporaId';
    final name = lookup(diasporaId, inlineName);
    if (name != null) {
      final anchor = Element.text('a', parser.document.encodeHtml ? HtmlEscape(HtmlEscapeMode.element).convert(name) : name);
      anchor.attributes['href'] = Uri.encodeFull(url);
      parser.addNode(anchor);
    } else {
      parser.addNode(Element.text('span', inlineName ?? diasporaId));
    }

    return true;
  }
}

String _presence(String string) {
  if (string == null || string.trim().isEmpty) {
    return null;
  } else {
    return string;
  }
}
