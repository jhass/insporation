import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/src/client.dart';
import 'package:insporation/src/markdown_extensions.dart' as mde;
import 'package:markdown/markdown.dart' as md;

String renderMessageMarkdown(String body, {Map<String, Person>? mentionedPeople}) {
  return md.markdownToHtml(
    body,
    blockSyntaxes: [
      md.TableSyntax(),
      md.FencedCodeBlockSyntax(),
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
      mde.SingleNewlineBreakSyntax(),
      mde.DiasporaAutolinkSyntax(),
    ],
  );
}

void main() {
  test('single newline in paragraph renders as html break', () {
    final html = renderMessageMarkdown('hello\nworld');

    expect(html, contains('<br'));
  });

  test('fenced code block newlines are not converted to html breaks', () {
    final html = renderMessageMarkdown('```\nhello\nworld\n```');

    expect(html, contains('<pre><code>hello\nworld\n</code></pre>'));
    expect(html, isNot(contains('<code>hello<br')));
  });

  test('hard breaks via trailing spaces keep existing behavior', () {
    final html = renderMessageMarkdown('hello  \nworld');

    expect(html, contains('<p>hello<br />\nworld</p>'));
  });

  test('inline code does not get newline break conversion', () {
    final html = renderMessageMarkdown('`hello\nworld`');

    expect(html, contains('<p><code>hello world</code></p>'));
    expect(html, isNot(contains('<code>hello<br')));
  });
}