import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/client.dart';
import 'src/error_message.dart';
import 'src/item_stream.dart';
import 'src/navigation.dart';
import 'src/posts.dart';

class StreamPage extends StatefulWidget {
  StreamPage({Key key, this.type, this.tag}) : super(key: key);

  final StreamType type;
  final String tag;

  @override
  _StreamPageState createState() => _StreamPageState();

  String get title {
    switch (type) {
    case StreamType.main:
      return "Stream";
    case StreamType.activity:
      return "Activity";
    case StreamType.tag:
      return "#$tag";
    }

    return "Stream";
  }
}

class _StreamPageState extends ItemStreamState<Post, StreamPage> with PostStreamState<StreamPage> {
  @override
  ItemStream<Post> createStream() => PostStream(type: widget.type, tag: widget.tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: widget.type != StreamType.tag ? NavigationBar(currentPage: PageType.stream) : null,
      appBar: widget.type == StreamType.tag ? AppBar(
        title: Text(widget.title),
      ) : null,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, "/publisher")
      ),
      body: buildStream(context)
    );
  }

  @override
  Widget buildHeader(BuildContext context, String lastError) =>
    _StreamTypeSelector(currentType: widget.type, error: lastError);
}

class _StreamTypeSelector extends StatelessWidget {
  _StreamTypeSelector({Key key, @required this.currentType, this.error}) : super(key: key);

  final StreamType currentType;
  final String error;

  @override
  Widget build(BuildContext context) {
    if (currentType == StreamType.tag) {
      return ErrorMessage(error);
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ErrorMessage(error),
          ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentType,
              icon: Icon(Icons.arrow_downward),
              iconSize: 32,
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.black
              ),
              underline: SizedBox.shrink(),
              onChanged: (newValue) {
                if (newValue != currentType) {
                  Navigator.pushReplacementNamed(context, '/stream/${describeEnum(newValue)}');
                }
              },
              items: <DropdownMenuItem>[
                DropdownMenuItem(
                    child: Text("Stream"),
                    value: StreamType.main
                ),
                DropdownMenuItem(
                    child: Text("Activity"),
                    value: StreamType.activity
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}