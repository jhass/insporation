import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'src/client.dart';
import 'src/item_stream.dart';

class ContactsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ContactsPageState();
}

class _AspectsStream extends ItemStream<Aspect> {
  @override
  Future<Page<Aspect>> loadPage({Client client, String page}) async {
    final aspects = await client.currentUserAspects;
    return Page(content: aspects);
  }
}

class _ContactsPageState extends ItemStreamState<Aspect, ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts")),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Aspect> createStream() => _AspectsStream();

  @override
  Widget buildItem(BuildContext context, Aspect item) => Container(
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
    child: ListTile(
      title: Text(item.name),
      onTap: () {
        Navigator.push(context, PageRouteBuilder(
          pageBuilder: (context, _, __) => _AspectContactsPage(item),
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: animation
              .drive(Tween(begin: Offset(1, 0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.ease))),
            child: child
          )
        ));
      },
    )
  );
}

class _AspectContactsPage extends StatefulWidget {
  _AspectContactsPage(this.aspect, {Key key}) : super(key: key);

  final Aspect aspect;

  @override
  State<StatefulWidget> createState() => _AspectContactsPageState();
}

class _AspectContactsStream extends ItemStream<Person> {
  _AspectContactsStream(this.aspect);

  final Aspect aspect;

  @override
  Future<Page<Person>> loadPage({Client client, String page}) =>
    client.fetchAspectContacts(aspect, page: page);

}

class _AspectContactsPageState extends ItemStreamState<Person, _AspectContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.aspect.name)),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Person> createStream() => _AspectContactsStream(widget.aspect);

  @override
  Widget buildItem(BuildContext context, Person person) {
    final placeholder = Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(Icons.person));
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]))),
      child: ListTile(
        leading: person.avatar == null ?
        placeholder : ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            imageUrl: person.avatar,
            placeholder: (context, _) => placeholder,
          )
        ),
        title: Text(person.nameOrId),
        onTap: () => Navigator.pushNamed(context, '/profile', arguments: person),
      ),
    );
  }
}