import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'localizations.dart';
import 'search.dart';
import 'widgets.dart';


class Composer extends StatefulWidget {
  Composer({
    Key? key,
    this.controller,
    this.focusNode,
    this.mentionablePeople = const SearchablePeople.all(),
    this.enabled = true
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final SearchablePeople mentionablePeople;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> with StateLocalizationHelpers {
  TextEditingController? _controller;
  TextEditingController? get _effectiveController => widget.controller ?? _controller;

  List<Person> _mentionSuggestions = [];
  int? _mentionAtIndex;
  bool _searchingMentions = false;
  Timer? _mentionSearchDebounce;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
    _effectiveController?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(Composer oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.controller?.removeListener(_onControllerChanged);
    _controller?.removeListener(_onControllerChanged);

    if (widget.controller == null && oldWidget.controller != null) {
      _controller = TextEditingController.fromValue(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller = null;
    }

    _effectiveController?.addListener(_onControllerChanged);

    if (!widget.enabled && oldWidget.enabled) {
      _clearMentionSuggestions();
    }
  }

  @override
  void dispose() {
    _effectiveController?.removeListener(_onControllerChanged);
    _mentionSearchDebounce?.cancel();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!widget.enabled) {
      _clearMentionSuggestions();
      return;
    }

    final controller = _effectiveController;
    if (controller == null) return;

    final cursor = controller.selection.baseOffset;
    if (cursor < 0) {
      _clearMentionSuggestions();
      return;
    }

    final textBeforeCursor = controller.text.substring(0, cursor);
    // Match @ preceded by start-of-text or whitespace, followed by non-space non-@ non-{ characters
    final atMatch = RegExp(r'@([^\s@{]*)$').firstMatch(textBeforeCursor);

    if (atMatch == null) {
      _clearMentionSuggestions();
      return;
    }

    // Ensure @ is at the start of text or preceded by whitespace
    final atIndex = atMatch.start;
    if (atIndex > 0 && !RegExp(r'\s').hasMatch(textBeforeCursor[atIndex - 1])) {
      _clearMentionSuggestions();
      return;
    }

    final query = atMatch.group(1)!;

    _mentionSearchDebounce?.cancel();
    _mentionSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchMentions(query, atIndex);
    });
  }

  void _clearMentionSuggestions() {
    _mentionSearchDebounce?.cancel();
    if (_mentionSuggestions.isNotEmpty || _mentionAtIndex != null || _searchingMentions) {
      setState(() {
        _mentionSuggestions = [];
        _mentionAtIndex = null;
        _searchingMentions = false;
      });
    }
  }

  Future<void> _searchMentions(String query, int atIndex) async {
    final people = widget.mentionablePeople;

    // Skip if we can't find any people
    if (people.list?.isEmpty == true) return;

    if (people.list != null) {
      // Synchronous search through local list
      final q = query.toLowerCase();
      final results = people.list!.where((person) =>
        person.nameOrId.toLowerCase().contains(q) ||
        person.diasporaId.toLowerCase().contains(q)
      ).take(5).toList();

      if (mounted) {
        setState(() {
          _mentionAtIndex = atIndex;
          _mentionSuggestions = results;
          _searchingMentions = false;
        });
      }
      return;
    }

    // Remote search: require at least one character
    if (query.isEmpty) return;

    if (!mounted) return;
    setState(() {
      _mentionAtIndex = atIndex;
      _searchingMentions = true;
    });

    List<Person> results;
    try {
      final client = context.read<Client>();
      final page = await client.searchPeopleByName(query, filters: people.filters);
      results = page.content.take(5).toList();
    } catch (_) {
      results = [];
    }

    if (mounted && _mentionAtIndex == atIndex) {
      setState(() {
        _mentionSuggestions = results;
        _searchingMentions = false;
      });
    }
  }

  void _selectMentionSuggestion(Person person) {
    final controller = _effectiveController;
    if (controller == null) return;

    final atIndex = _mentionAtIndex;
    if (atIndex == null) return;

    final cursor = controller.selection.baseOffset;
    if (cursor < 0) return;

    final mention = "@{${person.diasporaId}}";
    final newText = controller.text.replaceRange(atIndex, cursor, mention);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: atIndex + mention.length),
    );

    setState(() {
      _mentionSuggestions = [];
      _mentionAtIndex = null;
    });
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
      ),
      if (_searchingMentions || _mentionSuggestions.isNotEmpty)
        _buildMentionSuggestions(),
    ],
  );

  Widget _buildMentionSuggestions() {
    return Card(
      margin: const EdgeInsets.only(top: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_searchingMentions)
            const LinearProgressIndicator(),
          ..._mentionSuggestions.map((person) => ListTile(
            dense: true,
            leading: Avatar(person: person, size: 32),
            title: Text(person.nameOrId),
            subtitle: Text(person.diasporaId),
            onTap: () => _selectMentionSuggestion(person),
          )),
        ],
      ),
    );
  }

  _insertInlineWrap(String delimiter) {
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final selection = controller.selection,
      text = controller.text;
    if (selection.start < 0) {
      final newText = "$text$delimiter$delimiter";
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - delimiter.length)
      );
    } else if (selection.isCollapsed) {
      final insertion = "$delimiter$delimiter",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + delimiter.length)
      );
    } else {
      final replacement = "$delimiter${selection.textInside(text)}$delimiter",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      controller.value = controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.end + delimiter.length * 2)
      );
    }
  }

  _insertHeadline() async {
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final selection = controller.selection;
    final int? level = await showDialog(context: context, builder: (context) => SimpleDialog(
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
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final text = controller.text;
    selection = selection ?? controller.selection;

    if (selection == null || selection.start < 0) {
      final newText = "$text${_newlinesForBlockAfter(text)}$prefix";
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else if (!selection.isCollapsed) {
      final selectedText = selection.textInside(text),
        prefixedLines = selectedText.split("\n").map((line) => "$prefix$line"  ).join("\n"),
        replacement = "${_newlinesForBlockAfter(selection.textBefore(text))}$prefixedLines\n",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + replacement.length - selectedText.length)
      );
    } else {
      final insertion = "${_newlinesForBlockAfter(selection.textBefore(text))}$prefix",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + insertion.length)
      );
    }
  }

  _insertBlockWrap(String delimiter) {
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final text = controller.text,
      selection = controller.selection;
    if (selection.start < 0) {
      final newText = "$text${_newlinesForBlockAfter(text)}$delimiter\n$delimiter\n";
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else if (!selection.isCollapsed) {
      final selectedText = selection.textInside(text),
        replacement = "${_newlinesForBlockAfter(selection.textBefore(text))}$delimiter\n$selectedText\n$delimiter${_newlinesForBlockBefore(selection.textAfter(text))}",
        newText = text.replaceRange(selection.start, selection.end, replacement);
      controller.value = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.end + replacement.length - selectedText.length)
      );
    } else {
      final postfix = "$delimiter${_newlinesForBlockBefore(selection.textAfter(text))}${_newlinesForBlockBefore(selection.textAfter(text))}",
        insertion = "${_newlinesForBlockAfter(selection.textBefore(text))}$delimiter\n$postfix",
        newText = text.replaceRange(selection.start, selection.end, insertion);
      controller.value = controller.value.copyWith(
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
    _insertLinkable(l.insertLinkPrompt, (response) => response.description?.isNotEmpty == true ?
      "[${response.description}](${response.url})": "<${response.url}>");
  }

  _insertImage() async {
    _insertLinkable(l.insertImageURLPrompt, (response) => "![${response.description ?? ""}](${response.url})");
  }

  _insertLinkable(String title, String Function(_LinkData response) formatter) async {
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final selection = controller.selection,
      initialValue = !selection.isCollapsed ? selection.textInside(controller.text) : null;
    final _LinkData? response = await showDialog(context: context, builder: (context) => _LinkInputDialog(
      title: title,
      initialValue: initialValue
    ));

    if (response ==  null) {
      return; // user canceled dialog
    }

    final insertion = formatter(response), text = controller.text;

    if (selection.start < 0) {
      final newText = "$text$insertion";
      controller.value  = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else {
      controller.value = controller.value.copyWith(
        text:  text.replaceRange(selection.start, selection.end, insertion),
        selection: TextSelection.collapsed(offset: selection.start + insertion.length)
      );
    }
  }

  _insertHashtag() async {
    final controller = _effectiveController;
    if (controller == null) {
      return;
    }

    final selection = controller.selection,
      initialValue = !selection.isCollapsed ? selection.textInside(controller.text) : null;
    final String? response = await showDialog(context: context, builder: (context) => TagSearchDialog(initialValue: initialValue));

    if (response == null) {
      return; // user canceled dialog
    }

    final tag = "#$response", text = controller.text;

    if (selection.start < 0) {
      final newText = "$text$tag";
      controller.value  = controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length)
      );
    } else {
      controller.value = controller.value.copyWith(
        text:  text.replaceRange(selection.start, selection.end, tag),
        selection: TextSelection.collapsed(offset: selection.start + tag.length)
      );
    }
  }
}

class _LinkInputDialog extends StatefulWidget {
  _LinkInputDialog({Key? key, required this.title, this.initialValue}) : super(key: key);

  final String title;
  final String? initialValue;

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

    final initialValue = widget.initialValue;

    if (initialValue != null && initialValue.isNotEmpty) {
      if (initialValue.startsWith("http://") || initialValue.startsWith("https://"))  {
        _url.text = initialValue;
        _valid = true;
      } else {
        _description.text = initialValue;
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
      TextButton(
        child: Text(ml.cancelButtonLabel),
        onPressed: () => Navigator.pop(context),
      ),
      TextButton(
        child: Text(l.insertButtonLabel),
        onPressed: _valid ? () => Navigator.pop(context, _LinkData(_description.text, _url.text)) : null,
      )
    ],
  );
}

class _LinkData {
  final String? description;
  final String url;

  _LinkData(this.description, this.url);
}

class SimpleComposer extends StatefulWidget {
  SimpleComposer({
    Key? key,
    this.onSubmit,
    this.controller,
    this.enabled = true,
    this.submittable = true,
    this.submitButtonContent,
    this.focusNode,
    this.mentionablePeople = const SearchablePeople.all()
  }) : super(key: key);

  final Future<bool> Function(String value)? onSubmit;
  final TextEditingController? controller;
  final bool enabled;
  final bool submittable;
  final Widget? submitButtonContent;
  final FocusNode? focusNode;
  final SearchablePeople mentionablePeople;

  @override
  State<StatefulWidget> createState() => _SimpleComposerState();
}

class _SimpleComposerState extends State<SimpleComposer> with StateLocalizationHelpers {
  late TextEditingController? _controller;
  TextEditingController? get _effectiveController => widget.controller ?? _controller;
  bool _submitting = false;
  bool _submittable = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
    }
   _effectiveController?.addListener(_onChange);
  }

  @override
  void didUpdateWidget(SimpleComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != null) {
      oldWidget.controller!.removeListener(_onChange);
    }

    if (widget.controller == null && oldWidget.controller != null) {
      _controller = TextEditingController.fromValue(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      _controller = null;
    }

    _effectiveController?.addListener(_onChange);
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
            visible: widget.onSubmit != null && !_submitting,
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
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
    _effectiveController?.removeListener(_onChange);
    super.dispose();
  }

  _onChange() {
    final newValue = _effectiveController!.text.trim().isNotEmpty;
    if (newValue != _submittable) {
      setState(() => _submittable = newValue);
    }
  }

  _submit() async {
    final onSubmit = widget.onSubmit;

    if (onSubmit != null) {
      setState(() => _submitting = true);
      final success = await onSubmit(_effectiveController!.text);
      if (success && mounted) {
        _effectiveController!.text = "";
      }

      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
