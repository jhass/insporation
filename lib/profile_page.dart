import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insporation/src/item_stream.dart';
import 'package:insporation/src/posts.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/error_message.dart';
import 'src/messages.dart';

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
  Profile _profile;
  String _lastError;

  @override
  void initState() {
    super.initState();

    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    // TODO render better loading screen based on widget.person if present
    return Scaffold(
      appBar: AppBar(title: _titleView),
      body: _loading ? Center(child: CircularProgressIndicator()) :
        _lastError != null ? ErrorMessage(_lastError) :
           _UserPostStreamView(profile: _profile)
    );
  }

  bool get _loading => _profile == null && _lastError == null;

  Widget get _titleView {
    final title = _title;
    return title != null ? Text(title) : null;
  }

  String get _title {
    final person = _profile?.person ?? widget.person;
    return person?.nameOrId;
  }

  _fetch() async {
    final client = Provider.of<Client>(context, listen: false);

    try {
      final profile = await client.fetchProfile(widget.personId);
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch(e, s) {
      debugPrintStack(label: e.message, stackTrace: s);

      if (mounted) {
        setState(() => _lastError = e.message);
      }
    }
  }
}

class _UserPostStream extends ItemStream<Post> {
  _UserPostStream(this.person);

  final Person person;

  @override
  Future<Page<Post>> loadPage({Client client, String page}) =>
    client.fetchUserStream(person, page: page);
}

class _UserPostStreamView extends StatefulWidget {
  _UserPostStreamView({Key key, this.profile}) : super(key: key);

  final Profile profile;

  @override
  State<StatefulWidget> createState() => _UserPostStreamViewState();
}

class _UserPostStreamViewState extends ItemStreamState<Post, _UserPostStreamView>
  with PostStreamState<_UserPostStreamView> {
  @override
  ItemStream<Post> createStream() => _UserPostStream(widget.profile.person);

  @override
  Widget buildHeader(BuildContext context, String lastError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        super.buildHeader(context, lastError),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text("Info", style: TextStyle(fontSize: 18))
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: <Widget>[
                      widget.profile.avatar?.medium != null ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          imageUrl: widget.profile.avatar.medium,
                          placeholder: (context, url) => Center(child: Icon(Icons.person)),
                        ) ,
                      ) : SizedBox.shrink(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: widget.profile.tags.map((tag) => Chip(
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                "#$tag",
                                style: TextStyle(fontSize: 10)
                              )
                            )).toList(),
                          ),
                        )
                      )
                    ],
                  ),
                ),
                widget.profile.bio == null ? SizedBox.shrink() : Message(body: widget.profile.bio),
                _buildField("Gender", widget.profile.gender),
                _buildField("Location", widget.profile.location),
                _buildField("Birthday", widget.profile.formattedBirthday)
              ],
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text("Posts", style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) =>
    value == null || value.isEmpty ? SizedBox.shrink() : Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text.rich(TextSpan(
        children: <TextSpan>[
          TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value)
        ]
      ))
    );
}