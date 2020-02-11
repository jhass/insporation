import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insporation/src/item_stream.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/navigation.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

enum _SearchType { people, peopleByTag, tags }

class _SearchResult {
  final Person person;
  final String tag;

  _SearchResult(this.person, this.tag);

  factory _SearchResult.forPerson(Person person) => _SearchResult(person, null);
  factory _SearchResult.forTag(String tag) => _SearchResult(null, tag);
}

class _SearchResultStream extends ItemStream<_SearchResult> {
  var _type = _SearchType.people;
  String _query;

  _SearchType get type => _type;

  set type(_SearchType type) {
    _type = type;
    reset();
  }

  String get query => _query;

  set query(String query) {
    _query = query;
    reset();
  }

  @override
  Future<Page<_SearchResult>> loadPage({Client client, String page}) async {
    if (_query == null || _query.isEmpty)  {
      return Page.empty();
    }

    switch (_type) {
      case _SearchType.people:
        final result = await client.searchPeopleByName(query, page: page);
        return result.map((person) => _SearchResult.forPerson(person));
      case _SearchType.peopleByTag:
        final result = await client.searchPeopleByTag(query, page: page);
        return result.map((person) => _SearchResult.forPerson(person));
      case _SearchType.tags:
        final query = _query.startsWith('#') ? _query.substring(1) : _query,
          result = await client.searchTags(query, page: page);
        return result.map((tag) => _SearchResult.forTag(tag));
    }

    return null; // case is exhaustive, never happens
  }

}

class _SearchPageState extends ItemStreamState<_SearchResult, SearchPage> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _SearchResultStream items = this.items;

    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.search),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoSegmentedControl(
                borderColor: Colors.grey,
                selectedColor: Colors.grey[800],
                pressedColor: Colors.grey[800],
                children: {
                  _SearchType.people: Text("People"),
                  _SearchType.peopleByTag: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text("People by tag")
                  ),
                  _SearchType.tags: Text("Tags")
                },
                groupValue: items.type,
                onValueChanged: (type) => setState(() {
                  items.type = type;
                  items.load(Provider.of<Client>(context, listen: false));
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: _hintText(items.type),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[800])),
                  filled: true
                ),
                onChanged: (query) {
                  items.query = query;
                  items.load(Provider.of<Client>(context, listen: false));
                },
              ),
            ),
            Expanded(child: buildStream(context)),
          ],
        ),
      )
    );
  }

  @override
  ItemStream<_SearchResult> createStream() => _SearchResultStream();

  @override
  Widget buildItem(BuildContext context, _SearchResult item) => InkWell(
    onTap: () => _launchItem(item),
    child: Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color:  Colors.grey[300]))),
      child: ListTile(
        leading: _buildLeading(item),
        title: Text(_formatTitle(item))
      )
    ),
  );

  String _hintText(_SearchType type) {
    switch (type) {
      case _SearchType.people:
        return "Start typing a name or diaspora* ID";
      case _SearchType.peopleByTag:
        return "Enter a tag";
      case _SearchType.tags:
        return "Start typing tag";
    }

    return null; // case is exhaustive, never reached
  }

  Widget _buildLeading(_SearchResult item) {
    if (item.person == null) {
      return null;
    } else {
      final placeholder = Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(Icons.person));
      if (item.person.avatar != null)  {
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            width: 36,
            height: 36,
            imageUrl: item.person.avatar,
            placeholder: (context, url) => placeholder,
          )
        );
      } else {
        return placeholder;
      }
    }
  }

  String _formatTitle(_SearchResult item) => item.tag != null ? "#${item.tag}" : item.person.nameOrId;

  void _launchItem(_SearchResult item) {
    if (item.person != null) {
      Navigator.pushNamed(context, "/profile", arguments: item.person);
    } else {
      Navigator.pushNamed(context, "/stream/tag", arguments: item.tag);
    }
  }
}
