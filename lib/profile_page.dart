import 'package:flutter/material.dart';

import 'src/client.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.person, @required this.personId}) {
    if (person != null && personId != null && person.guid != personId) {
      throw "Conflicting person and person id given!";
    } else if (person == null && personId == null) {
      throw "No person or person id given!";
    }
  }

  factory ProfilePage.forPerson({Key key, @required Person person}) =>
    ProfilePage(key: key, person: person, personId: person.guid);

  factory ProfilePage.forId({Key key, @required String personId}) =>
    ProfilePage(key: key, personId: personId);

  final String personId;
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
      appBar: AppBar(title: Text(widget.person != null ? widget.person.name : null ?? widget.personId)),
      body: Center(child: Text("Person ${widget.personId}"))
    );
  }
}