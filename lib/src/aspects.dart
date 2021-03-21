import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'client.dart';
import 'localizations.dart';

class AspectSelectionList extends StatefulWidget {
  AspectSelectionList({Key? key, required this.selectedAspects}) : super(key: key);

  final List<Aspect> selectedAspects;

  @override
  State<StatefulWidget> createState() => _AspectSelectionListState();

  static Widget buildDialog({required BuildContext context, required List<Aspect>? currentSelection, String? title}) {
    final newAspects = List.of(currentSelection ?? <Aspect>[]),
      ml = MaterialLocalizations.of(context),
      l = AppLocalizations.of(context)!;
    return AlertDialog(
      content: AspectSelectionList(selectedAspects: newAspects),
      title: Text(title ?? l.aspectsPrompt),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(context), child: Text(ml.cancelButtonLabel)),
        TextButton(onPressed: () => Navigator.pop(context, newAspects), child: Text(l.saveButtonLabel))
      ],
    );
  }
}

class _AspectSelectionListState extends State<AspectSelectionList> with StateLocalizationHelpers {
  List<Aspect>? _userAspects;

  @override
  void initState() {
    super.initState();
    final client = context.read<Client>();
    client.currentUserAspects.then((aspects) => setState(() => _userAspects = aspects));
  }

  @override
  Widget build(BuildContext context) {
    final userAspects = _userAspects;

    if (userAspects == null) {
      return Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        child: CircularProgressIndicator()
      );
    }

    final allSelected = widget.selectedAspects.length == userAspects.length;

    return Container(
      width: double.maxFinite,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: userAspects.length + 1,
        itemBuilder: (context, position) => Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
          ),
          child: position == 0 ?
            TextButton(
              child: Text(allSelected ? l.deselectAllButtonLabel : l.selectAllButtonLabel),
              onPressed: () => setState(() {
                widget.selectedAspects.clear();
                if (!allSelected) {
                  widget.selectedAspects.addAll(userAspects);
                }
              })
            )
            : CheckboxListTile(
                title: Text(userAspects[position - 1].name),
                value: widget.selectedAspects.contains(userAspects[position - 1]),
                onChanged: (selected) {
                  setState(() {
                  if (selected == null) {
                    return;
                  } else if (selected) {
                    widget.selectedAspects.add(userAspects[position - 1]);
                  } else {
                     widget.selectedAspects.remove(userAspects[position - 1]);
                  }
                });
            },
          ),
        )
      ),
    );
  }
}
