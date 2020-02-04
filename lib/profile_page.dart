import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'src/client.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key key, @required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(person.name ?? person.diasporaId)),
      body: Center(child: Text("TODO"))
    );
  }
}