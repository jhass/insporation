import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_conversation_page.dart';
import 'publisher_page.dart';
import 'src/aspects.dart';
import 'src/client.dart';
import 'src/error_message.dart';
import 'src/item_stream.dart';
import 'src/messages.dart';
import 'src/posts.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.person, this.personId, this.diasporaId}) {
    if (person != null && personId != null) {
      assert(person.guid == personId, "Conflicting person and person ID given!");
    }
    assert(person != null || personId != null || diasporaId != null,
      "No person, person ID or diaspora ID given!");
  }

  factory ProfilePage.forPerson({Key key, @required Person person}) =>
    ProfilePage(key: key, person: person, personId: person.guid);

  factory ProfilePage.forId({Key key, @required String personId}) =>
    ProfilePage(key: key, personId: personId);

  factory ProfilePage.forDiasporaId({Key key, @required String diasporaId}) =>
    ProfilePage(key: key, diasporaId: diasporaId);

  final String personId;
  final String diasporaId;
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
      var personId = widget.personId;

      if (personId == null) {
        final result = await client.searchPeopleByName(widget.diasporaId);
        personId = result?.content?.first?.guid;

        if (personId == null) {
          throw "Couldn't find ${widget.diasporaId}";
        }
      }

      final profile = await client.fetchProfile(personId);
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch(e, s) {
      debugPrintStack(label: e.toString(), stackTrace: s);

      if (mounted) {
        setState(() => _lastError = e.toString());
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
  State<StatefulWidget> createState() => _UserPostStreamViewState(profile);
}

class _ProfileNotifier extends ValueNotifier<Profile> {
  _ProfileNotifier(Profile value) : super(value);

  void updated() => notifyListeners();
}

class _UserPostStreamViewState extends ItemStreamState<Post, _UserPostStreamView>
  with PostStreamState<_UserPostStreamView> {
  _UserPostStreamViewState(Profile initialProfile) : _profile = _ProfileNotifier(initialProfile);

  final _ProfileNotifier _profile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profile.value = widget.profile;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _profile,
      child: super.build(context)
    );
  }

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

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
            child: Consumer<_ProfileNotifier>(
                builder: (context, profile, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _infoCardContent(context, profile.value),
                ),
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

  List<Widget> _infoCardContent(BuildContext context, Profile profile) {
    final content = <Widget>[], headRow = <Widget>[];

    if (profile.avatar?.medium != null) {
      headRow.add(ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          imageUrl: profile.avatar.medium,
          placeholder: (context, url) => Center(child: Icon(Icons.person)),
        ) ,
      ));
    }

    if (profile.ownProfile) {
      headRow.add(Expanded(
        child: Container(
          alignment: Alignment.centerRight,
          child: OutlineButton(
            child: Text("Edit profile"),
            onPressed: () => Navigator.pushNamed(context, "/edit_profile"),
          )
        )
      ));
    } else {
      headRow.add(Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: TextIcon(character: "@"),
                    tooltip: "Mention user",
                    onPressed: () => Navigator.pushNamed(context, "/publisher", arguments: PublisherOptions(
                      prefill: "@{${profile.person.diasporaId}} ",
                      target: PublishTarget.aspects(profile.aspects)
                    )),
                  ),
                  IconButton(
                    icon: Icon(Icons.mail),
                    tooltip: "Message",
                    onPressed: profile.canMessage ? () =>
                      Navigator.pushNamed(context, "/conversations/new", arguments: NewConversationOptions(
                        recipients: [profile.person]
                      )) : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.block, color: profile.blocked? Colors.red : Colors.black),
                    tooltip: profile.blocked ? "Unblock" : "Block",
                    onPressed: () {
                      profile.blocked = !profile.blocked;
                      // TODO for real, backend route missing
                      Provider.of<_ProfileNotifier>(context, listen: false).updated(); // trigger update
                    },
                  )
                ]
              ),
              _AspectMembershipView(profile: profile)
            ],
          ),
        ),
      ));
    }

    content.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: headRow,
      ),
    ));

    if (profile.tags.isNotEmpty) {
      content.add(Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: profile.tags.map((tag) => Chip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(
              "#$tag",
              style: TextStyle(fontSize: 10)
            )
          )).toList(),
        ),
      ));
    }

    if (profile.bio != null) {
      content.add(Divider());
      content.add(Message(body: profile.bio));
    }

    final infos = <Widget>[
      // display diaspora ID only if not in appbar already
      _buildInfo(Icons.person, profile.person.name != null ? profile.person.diasporaId : null),
      _buildInfo(Icons.perm_identity, profile.gender),
      _buildInfo(Icons.location_on, profile.location),
      _buildInfo(Icons.cake, profile.formattedBirthday)
    ].where((info) => info != null).toList();

    if (infos.isNotEmpty) {
      content.add(Divider());
      content.add(Wrap(children: infos));
    }

    return content;
  }

  Widget _buildInfo(IconData icon, String value) =>
    value == null || value.isEmpty ? null : Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon),
        Flexible(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Message(body: value)
        ))
      ]
    );
}

class _AspectMembershipView extends StatefulWidget {
  _AspectMembershipView({Key key, @required this.profile}) : super(key: key);

  final Profile profile;

  @override
  State<StatefulWidget> createState() => _AspectMembershipViewState();
}

class _AspectMembershipViewState extends State<_AspectMembershipView> {
  @override
  Widget build(BuildContext context) {
    if (widget.profile.blocked) {
      return SizedBox.shrink();
    }

    return Tooltip(
      message: _shareStatus,
      child: OutlineButton(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(color: widget.profile.receiving ? Colors.green : Colors.grey),
                shape: BoxShape.circle,
                color: widget.profile.sharing && widget.profile.receiving ? Colors.green :
                  widget.profile.sharing ? Colors.grey : Colors.transparent
              ),
            ),
            Text(_label),
          ],
        ),
        onPressed: _updateAspects
      ),
    );
  }

  String get _label {
    final aspects = widget.profile.aspects;

    if (aspects.length == 0) {
      return "Add contact";
    } else if (aspects.length == 1) {
      return aspects.first.name;
    } else {
      return "In ${aspects.length} aspects";
    }
  }

  String get _shareStatus {
    final profile = widget.profile;
    if (profile.blocked) {
      return "You blocked them";
    } else if (profile.receiving && profile.sharing) {
      return "You are sharing with each other";
    } else if (profile.receiving) {
      return "They are sharing with you.";
    } else if (profile.sharing) {
      return "You are sharing with them.";
    } else {
      return "You are not sharing with each other.";
    }
  }

  void _updateAspects() async {
    final client = Provider.of<Client>(context, listen: false),
      profile = Provider.of<_ProfileNotifier>(context, listen: false),
      oldAspects = List.of(profile.value.aspects);

    List<Aspect> newAspects = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AspectSelectionList.buildDialog(
        context: context,
        currentSelection: oldAspects,
        title: "Select aspects for ${profile.value.person.nameOrId}"
      )
    );

    if (newAspects == null) {
      return; // canceled
    }

    if (containSameElements(newAspects, oldAspects)) {
      return;
    }

    final startedSharing = oldAspects.isEmpty && newAspects.isNotEmpty,
      stoppedSharing = oldAspects.isNotEmpty && newAspects.isEmpty;

    profile.value.sharing = newAspects.isNotEmpty;
    profile.value.aspects.clear();
    profile.value.aspects.addAll(newAspects);
    profile.updated();

    try {
      await client.updateAspectMemberships(profile.value.person, oldAspects, newAspects);

      if (mounted) {
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: startedSharing ? Colors.green : stoppedSharing ? Colors.redAccent : null,
          content: Text(
            startedSharing ? "Started sharing with ${profile.value.person.nameOrId}." :
              stoppedSharing ? "Stopped sharing with ${profile.value.person.nameOrId}." :
                "Aspects updated.",
            style: TextStyle(color: Colors.white)
          )
        ));
      }
    } catch (e, s) {
      tryShowErrorSnackBar(this, "Failed to update aspects", e, s);

      profile.value.sharing = oldAspects.isNotEmpty;
      profile.value.aspects.clear();
      profile.value.aspects.addAll(oldAspects);
      profile.updated();
    }
  }
}