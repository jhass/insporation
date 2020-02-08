import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'src/client.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.person, @required this.diasporaId}) {
    if (person != null && diasporaId != null && person.diasporaId != diasporaId) {
      throw "Conflicting person and diaspora id given!";
    } else if (person == null && diasporaId == null) {
      throw "No person or diaspora id given!";
    }
  }

  factory ProfilePage.forPerson({Key key, @required Person person}) =>
    ProfilePage(key: key, person: person, diasporaId: person.diasporaId);

  factory ProfilePage.forId({Key key, @required String diasporaId}) =>
    ProfilePage(key: key, diasporaId: diasporaId);

  final String diasporaId;
  final Person person;

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = widget.person == null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.person != null ? widget.person.name : null ?? widget.diasporaId)),
      body: Center(child: Text("TODO"))
    );
  }
}