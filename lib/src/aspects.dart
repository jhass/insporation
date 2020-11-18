import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'localizations.dart';

class AspectSelectionList extends StatefulWidget {
  AspectSelectionList({Key key, @required this.selectedAspects}) : super(key: key);

  final List<Aspect> selectedAspects;

  @override
  State<StatefulWidget> createState() => _AspectSelectionListState();

  static Widget buildDialog({@required BuildContext context, @required List<Aspect> currentSelection, String title}) {
    final newAspects = List.of(currentSelection ?? <Aspect>[]),
      ml = MaterialLocalizations.of(context),
      l = InsporationLocalizations.of(context);
    return AlertDialog(
      content: AspectSelectionList(selectedAspects: newAspects),
      title: Text(title ?? l.aspectsPrompt),
      actions: <Widget>[
        FlatButton(onPressed: () => Navigator.pop(context), child: Text(ml.cancelButtonLabel)),
        FlatButton(onPressed: () => Navigator.pop(context, newAspects), child: Text(l.saveButtonLabel))
      ],
    );
  }
}

class _AspectSelectionListState extends State<AspectSelectionList> with StateLocalizationHelpers {
  List<Aspect> _userAspects;

  @override
  void initState() {
    super.initState();
    final client = context.read<Client>();
    client.currentUserAspects.then((aspects) => setState(() => _userAspects = aspects));
  }

  @override
  Widget build(BuildContext context) {
    if (_userAspects == null) {
      return Container(
        width: 100,
        height: 100,
        alignment: Alignment.center,
        child: CircularProgressIndicator()
      );
    }

    final allSelected = widget.selectedAspects.length == _userAspects.length;

    return Container(
      width: double.maxFinite,
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: _userAspects.length + 1,
        itemBuilder: (context, position) => Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
          ),
          child: position == 0 ?
            FlatButton(
              child: Text(allSelected ? l.deselectAllButtonLabel : l.selectAllButtonLabel),
              onPressed: () => setState(() {
                widget.selectedAspects.clear();
                if (!allSelected) {
                  widget.selectedAspects.addAll(_userAspects);
                }
              })
            )
            : CheckboxListTile(
              title: Text(_userAspects[position - 1].name),
              value: widget.selectedAspects.contains(_userAspects[position - 1]),
              onChanged: (selected) {
                setState(() {
                if (selected) {
                    widget.selectedAspects.add(_userAspects[position - 1]);
                } else {
                   widget.selectedAspects.remove(_userAspects[position - 1]);
                }
              });
            },
          ),
        )
      ),
    );
  }
}
