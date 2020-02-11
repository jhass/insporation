import 'package:flutter/material.dart';

import 'src/composer.dart';

class PublisherPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _PublisherPageState();
}

class _PublisherPageState extends State<PublisherPage> {
  final _initialFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_initialFocus);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write new post")),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SimpleComposer( // TODO stub
          focusNode: _initialFocus,
          submitButtonContent: Text("Submit post"),
          onSubmit: (value) => Future.delayed(Duration(seconds: 3), () => false),
        )
      )
    );
  }
}
