import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'client.dart';
import 'localizations.dart';
import 'search.dart';
import 'widgets.dart';


class Composer extends StatefulWidget {
  Composer({
    Key key,
    this.controller,
    this.focusNode,
    this.mentionablePeople = const SearchablePeople.all(),
    this.enabled = true
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final SearchablePeople mentionablePeople;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> with StateLocalizationHelpers {
  TextEditingController _controller;
  TextEditingController get _effectiveController => widget.controller ?? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
  }

  @override
  void didUpdateWidget(Composer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: PageScrollPhysics(),
              child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.format_italic),
              tooltip: l.formatItalic,
              onPressed: widget.enabled ? () => _insertInlineWrap("*") : null
            ),
            IconButton(
              icon: Icon(Icons.format_bold),
              tooltip: l.formatBold,
              onPressed: widget.enabled ? () => _insertInlineWrap("**") : null
            ),
            IconButton(
              icon: Icon(Icons.format_strikethrough),
              tooltip: l.formatStrikethrough,
              onPressed: widget.enabled ? () => _insertInlineWrap("~~") : null
            ),
            IconButton(
              icon: TextIcon(character: "H"),
              tooltip: l.insertHeading,
              onPressed: widget.enabled ? () => _insertHeadline() : null
            ),
            IconButton(
              icon: Icon(Icons.format_list_bulleted),
              tooltip: l.insertBulletedList,
              onPressed: widget.enabled ? () => _insertPrefixedBlock("* ") : null
            ),
            IconButton(
              icon: Icon(Icons.format_list_numbered),
              tooltip: l.insertNumberedList,
              onPressed: widget.enabled ? () => _insertPrefixedBlock("1. ") : null
            ),
            IconButton(
              icon: Icon(Icons.format_quote),
              tooltip: l.insertQuote,
              onPressed: widget.enabled ? () => _insertPrefixedBlock(">  ") : null
            ),
            IconButton(
              icon: Icon(Icons.code),
              tooltip: l.insertCode,
              onPressed: widget.enabled ? () => _insertInlineWrap("`") : null
            ),
            IconButton(
              icon: Stack(children: <Widget>[Icon(Icons.code),  Positioned(top: 4, left: 4, child: Icon(Icons.short_text, size:  16))]), // TODO proper icon
              tooltip: l.insertCodeBlock,
              onPressed: widget.enabled ? () =>  _insertBlockWrap("```") : null
            ),
            IconButton(
              icon: Icon(Icons.link),
              tooltip: l.insertLink,
              onPressed: widget.enabled ? () => _insertLink() : null
            ),
            IconButton(
              icon: Icon(Icons.image),
              tooltip: l.insertImageURL,
              onPressed: widget.enabled ? () => _insertImage() : null
            ),
            IconButton(
              icon: TextIcon(character: "#"),
              tooltip: l.insertHashtag,
              onPressed: widget.enabled ? () => _insertHashtag() : null
            ),
            IconButton(
              icon: TextIcon(character: "@"),
              tooltip: l.insertMention,
              onPressed: widget.enabled ? () => _insertMention() : null
            )
          ],
        ),
      ),
      Flexible(
        child: TextFormField(
          controller: _effectiveController,
          focusNode: widget.focusNode, // autofocus is broken and raises
          enabled: widget.enabled,
          decoration: InputDecoration(
            border: OutlineInputBorder()
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null
        ),
      )
    ],
  );

  _insertInlineWrap(String delimiter) {
    final selection = _effectiveController.selection,
      text = _effectiveController.text;
    if (selection == null || selection.start < 0) {
      final newText = "$text$delimiter$delimiter";
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - delimiter.length)
      );
    } else if (selection.isCollapsed) {
      final insertion = "$delimiter$delimiter",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + delimiter.length)
      );
    } else {
      final replacement = "$delimiter${selection.textInside(text)}$delimiter",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      _effectiveController.value = _effectiveController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.end + delimiter.length * 2)
      );
    }
  }

  _insertHeadline() async {
    final selection = _effectiveController.selection;
    final int level = await showDialog(context: context, child: SimpleDialog(
      children: <Widget>[
        _buildHeadlineOption(1),
        _buildHeadlineOption(2),
        _buildHeadlineOption(3),
        _buildHeadlineOption(4),
        _buildHeadlineOption(5),
        _buildHeadlineOption(6)
      ],
    ));

    if (level == null) {
      return; // user canceled dialog
    }

    _insertPrefixedBlock("${"#" * level} ", selection: selection);
  }

  _buildHeadlineOption(int level) => SimpleDialogOption(
    child: Text(
      "Headline $level",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 33.0 - 2 * level)
    ),
    onPressed: () => Navigator.pop(context, level),
  );



  _insertPrefixedBlock(String prefix, {selection}) {
    final text = _effectiveController.text;
    selection = selection ?? _effectiveController.selection;

    if (selection == null || selection.start < 0) {
      final newText = "$text${_newlinesForBlockAfter(text)}$prefix";
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else if (!selection.isCollapsed) {
      final selectedText = selection.textInside(text),
        prefixedLines = selectedText.split("\n").map((line) => "$prefix$line"  ).join("\n"),
        replacement = "${_newlinesForBlockAfter(selection.textBefore(text))}$prefixedLines\n",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + replacement.length - selectedText.length)
      );
    } else {
      final insertion = "${_newlinesForBlockAfter(selection.textBefore(text))}$prefix",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + insertion.length)
      );
    }
  }

  _insertBlockWrap(String delimiter) {
    final text = _effectiveController.text,
      selection = _effectiveController.selection;
    if (selection == null || selection.start < 0) {
      final newText = "$text${_newlinesForBlockAfter(text)}$delimiter\n$delimiter\n";
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else if (!selection.isCollapsed) {
      final selectedText = selection.textInside(text),
        replacement = "${_newlinesForBlockAfter(selection.textBefore(text))}$delimiter\n$selectedText\n$delimiter${_newlinesForBlockBefore(selection.textAfter(text))}",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + replacement.length - selectedText.length)
      );
    } else {
      final postfix = "$delimiter${_newlinesForBlockBefore(selection.textAfter(text))}${_newlinesForBlockBefore(selection.textAfter(text))}",
        insertion = "${_newlinesForBlockAfter(selection.textBefore(text))}$delimiter\n$postfix",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      _effectiveController.value = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end - postfix.length)
      );
    }
  }

  String _newlinesForBlockAfter(String text) {
    if (text.endsWith("\n\n") || text.trim().isEmpty) {
      return "";
    } else if (text.endsWith("\n")) {
      return "\n";
    } else {
      return "\n\n";
    }
  }

  String _newlinesForBlockBefore(String text) {
    if (text.startsWith("\n\n") || text.trim().isEmpty) {
      return "";
    } else if (text.startsWith("\n")) {
      return "\n";
    } else {
      return "\n\n";
    }
  }

  _insertLink() async {
    _insertLinkable(l.insertLinkPrompt, (response) => response.description != null && response.description.isNotEmpty ?
      "[${response.description}](${response.url})": "<${response.url}>");
  }

  _insertImage() async {
    _insertLinkable(l.insertImageURLPrompt, (response) => "![${response.description ?? ""}](${response.url})");
  }

  _insertLinkable(String title, String Function(_LinkData response) formatter) async {
    final selection = _effectiveController.selection,
      initialValue = selection != null && !selection.isCollapsed ? selection.textInside(_effectiveController.text) : null;
    final _LinkData response = await showDialog(context: context, child: _LinkInputDialog(
      title: title,
      initialValue: initialValue
    ));

    if (response ==  null) {
      return; // user canceled dialog
    }

    final insertion = formatter(response), text = _effectiveController.text;

    if (selection == null || selection.start < 0) {
      final newText = "$text$insertion";
      _effectiveController.value  = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else {
      _effectiveController.value = _effectiveController.value.copyWith(
        text:  text.replaceRange(selection.start, selection.end, insertion),
        selection: TextSelection.collapsed(offset: selection.start + insertion.length)
      );
    }
  }

  _insertHashtag() async {
    final selection = _effectiveController.selection,
      initialValue = selection != null && !selection.isCollapsed ? selection.textInside(_effectiveController.text) : null;
    final String response = await showDialog(context: context, child: TagSearchDialog(initialValue: initialValue));

    if (response == null) {
      return; // user canceled dialog
    }

    final tag = "#$response", text = _effectiveController.text;

    if (selection == null || selection.start < 0) {
      final newText = "$text$tag";
      _effectiveController.value  = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else {
      _effectiveController.value = _effectiveController.value.copyWith(
        text:  text.replaceRange(selection.start, selection.end, tag),
        selection: TextSelection.collapsed(offset: selection.start + tag.length)
      );
    }
  }

  _insertMention() async {
    final selection = _effectiveController.selection,
      initialValue = selection != null && !selection.isCollapsed ? selection.textInside(_effectiveController.text) : null;
    final Person response = await showDialog(context: context, child: PeopleSearchDialog(
      initialValue: initialValue,
      people: widget.mentionablePeople,
    ));

    if (response == null) {
      return; // user canceled dialog
    }

    final mention = "@{${response.diasporaId}}", text = _effectiveController.text;

    if (selection == null || selection.start < 0) {
      final newText = "$text$mention";
      _effectiveController.value  = _effectiveController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else {
      _effectiveController.value = _effectiveController.value.copyWith(
        text:  text.replaceRange(selection.start, selection.end, mention),
        selection: TextSelection.collapsed(offset: selection.start + mention.length)
      );
    }
  }
}

class _LinkInputDialog extends StatefulWidget {
  _LinkInputDialog({Key key, @required this.title, this.initialValue}) : super(key: key);

  final String title;
  final String initialValue;

  @override
  State<StatefulWidget> createState() => _LinkInputDialogState();
}

class _LinkInputDialogState extends State<_LinkInputDialog> with StateLocalizationHelpers {
  final TextEditingController _url = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool _valid = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue.isNotEmpty) {
      if (widget.initialValue.startsWith("http://") || widget.initialValue.startsWith("https://"))  {
        _url.text = widget.initialValue;
        _valid = true;
      } else {
        _description.text = widget.initialValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: _url,
          autofocus: true,
          decoration: InputDecoration(hintText: l.insertLinkURLHint),
          keyboardType: TextInputType.url,
          onChanged: (value) => setState(() =>  _valid = value.isNotEmpty),
        ),
        TextField(
          controller: _description,
          decoration: InputDecoration(hintText: l.insertLinkDescriptionHint),
        )
      ],
    ),
    actions: <Widget>[
      FlatButton(
        child: Text(ml.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
      FlatButton(
        child: Text(l.insertButtonLabel),
        onPressed: _valid ? () => Navigator.pop(context, _LinkData(_description.text, _url.text)) : null,
      )
    ],
  );
}

class _LinkData {
  final String description;
  final String url;

  _LinkData(this.description, this.url);
}

class SimpleComposer extends StatefulWidget {
  SimpleComposer({
    Key key,
    this.onSubmit,
    this.controller,
    this.enabled = true,
    this.submittable = true,
    this.submitButtonContent,
    this.focusNode,
    this.mentionablePeople = const SearchablePeople.all()
  }) : super(key: key);

  final Future<bool> Function(String value) onSubmit;
  final TextEditingController controller;
  final bool enabled;
  final bool submittable;
  final Widget submitButtonContent;
  final FocusNode focusNode;
  final SearchablePeople mentionablePeople;

  @override
  State<StatefulWidget> createState() => _SimpleComposerState();
}

class _SimpleComposerState extends State<SimpleComposer> with StateLocalizationHelpers {
  TextEditingController _controller;
  TextEditingController get _effectiveController => widget.controller ?? _controller;
  bool _submitting = false;
  bool _submittable = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
   _effectiveController.addListener(_onChange);
  }

  @override
  void didUpdateWidget(SimpleComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != null) {
      oldWidget.controller.removeListener(_onChange);
    }

    if (widget.controller == null && oldWidget.controller != null) {
      _controller = TextEditingController.fromValue(oldWidget.controller.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller = null;
    }

    _effectiveController.addListener(_onChange);
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Flexible(
            child: Composer(
              controller: _effectiveController,
              focusNode: widget.focusNode,
              mentionablePeople: widget.mentionablePeople,
              enabled: widget.enabled && !_submitting
            ),
          ),
          Visibility(
            visible: widget.onSubmit != null,
            child: Align(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                child: widget.submitButtonContent ?? Text(l.submitButtonLabel),
                onPressed: widget.submittable && _submittable ? _submit : null,
              ),
            ),
          )
        ],
      ),
      Center(
        child: Visibility(
          visible: _submitting,
          child: CircularProgressIndicator(),
        ),
      )
    ]
  );

  @override
  void dispose() {
    _effectiveController.removeListener(_onChange);
    super.dispose();
  }

  _onChange() {
    final newValue = _effectiveController.text.trim().isNotEmpty;
    if (newValue != _submittable) {
      setState(() => _submittable = newValue);
    }
  }

  _submit() async {
    if (widget.onSubmit != null) {
      setState(() => _submitting = true);
      final success = await widget.onSubmit(_effectiveController.text);
      if (success) {
        _effectiveController.text = "";
      }
      setState(() => _submitting = false);
    }
  }
}
