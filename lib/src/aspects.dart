import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';

class AspectSelectionList extends StatefulWidget {
  AspectSelectionList({Key key, @required this.selectedAspects}) : super(key: key);

  final List<Aspect> selectedAspects;

  @override
  State<StatefulWidget> createState() => _AspectSelectionListState();

  static Widget buildDialog({@required BuildContext context, @required List<Aspect> currentSelection, String title}) {
    final newAspects = List.of(currentSelection ?? <Aspect>[]);
    return AlertDialog(
      content: AspectSelectionList(selectedAspects: newAspects),
      title: Text(title ?? "Select aspects"),
      actions: <Widget>[
        FlatButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        FlatButton(onPressed: () => Navigator.pop(context, newAspects), child: Text("Save"))
      ],
    );
  }
}

class _AspectSelectionListState extends State<AspectSelectionList> {
  List<Aspect> _userAspects;

  @override
  void initState() {
    super.initState();
    final client = Provider.of<Client>(context, listen: false);
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

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.66),
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        itemCount: _userAspects.length + 1,
        itemBuilder: (context, position) => Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]))
          ),
          child: position == 0 ?
            FlatButton(
              child: Text(allSelected ? "Deselect all" : "Select all"),
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
