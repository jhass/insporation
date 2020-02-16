import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'item_stream.dart';

enum SearchType { people, peopleByTag, tags }

class SearchablePeople {
  final bool all;
  final List<Person> list;
  final bool contactsOnly;
  final List<Aspect> inAspects;

  const SearchablePeople.all() : all = true, list = null, contactsOnly = false, inAspects = null;
  SearchablePeople.list(this.list) : all = false, contactsOnly = false, inAspects = null;
  const SearchablePeople.contactsOnly() : all = false, list = null, contactsOnly = true, inAspects = null;
  SearchablePeople.inAspects(this.inAspects) : all = false, list = null, contactsOnly = true;
  const SearchablePeople.none() : all = false, list = const [], contactsOnly = false, inAspects = null;
}

class SearchResult {
  final Person person;
  final String tag;

  SearchResult(this.person, this.tag);

  factory SearchResult.forPerson(Person person) => SearchResult(person, null);
  factory SearchResult.forTag(String tag) => SearchResult(null, tag);
}

class SearchResultStream extends ItemStream<SearchResult> {
  SearchResultStream({
    SearchType type = SearchType.people,
    String query,
    this.people = const SearchablePeople.all(),
    this.includeQueryAsTag = false
  }): _type = type, _query = query {
    if (type == SearchType.people) {
      assert(people != null, "Must give people to search through!");
    }

    if (!people.all) {
      assert(type == SearchType.people, "Can search through list of people only by name or ID!");
    }
  }

  var _type = SearchType.people;
  String _query;
  final SearchablePeople people;
  final bool includeQueryAsTag;

  SearchType get type => _type;

  set type(SearchType type) {
    _type = type;
    reset();
  }

  String get query => _query;

  set query(String query) {
    _query = query?.trim();
    reset();
  }

  @override
  Future<Page<SearchResult>> loadPage({Client client, String page}) async {
    if (_query == null || _query.isEmpty)  {
      return Page.empty();
    }

    bool _matchPerson(Person person) =>
      person.nameOrId.contains(_query) || person.diasporaId.contains(RegExp(RegExp.escape(_query), caseSensitive: false));

    Stream<Person> _streamContacts(List<Aspect> aspects) async* {
      // TODO let's have a proper API endpoint for this
      final state = aspects.map((aspect) => _AllAspectsContactsStreamState(aspect)).toList();
      int current = 0;
      do {
        Page<Person> lastPage = state[current].lastPage;
        if (lastPage == null || lastPage.nextPage != null) {
          final response = await client.fetchAspectContacts(state[current].aspect, page: lastPage?.nextPage);
          state[current].lastPage = response;
          yield* Stream.fromIterable(response.content);
        } else {
          state.removeAt(current);
        }

        current++;

        if (current >= aspects.length) {
          current = 0;
        }
      } while (state.length > 0);
    }

    switch (_type) {
      case SearchType.people:
        if (people.all) {
          final result = await client.searchPeopleByName(query, page: page);
          return result.map((person) => SearchResult.forPerson(person));
        } else if (people.contactsOnly) {
          final aspects = people.inAspects ?? await client.currentUserAspects;
          return Page(content: await _streamContacts(aspects).where(_matchPerson).take(5).map((person) => SearchResult.forPerson(person)).toList());
        } // else if people.list != null

        return Page(content: people.list.where(_matchPerson).map((person) => SearchResult.forPerson(person)).toList());
      case SearchType.peopleByTag:
        final result = await client.searchPeopleByTag(query, page: page);
        return result.map((person) => SearchResult.forPerson(person));
      case SearchType.tags:
        final query = _query.startsWith('#') ? _query.substring(1) : _query,
          result = await client.searchTags(query, page: page);

        if (page == null && // first page
            includeQueryAsTag &&
            result.content.firstWhere((tag) => tag.toLowerCase() == _query.toLowerCase(), orElse: () => null) == null) {
          result.content.insert(0, query);
        }

        return result.map((tag) => SearchResult.forTag(tag));
    }

    return null; // case is exhaustive, never happens
  }
}

class _AllAspectsContactsStreamState {
  final Aspect aspect;
  Page<Person> lastPage;

  _AllAspectsContactsStreamState(this.aspect);
}


abstract class _SearchDialogState<T extends StatefulWidget> extends ItemStreamState<SearchResult, T> {
  _SearchDialogState({this.hint = "Search"}) : super(enableUpButton: false);

  final String hint;

  final _controller = TextEditingController();

  @protected
  TextEditingController get controller => _controller;

  String get initialValue => null;

  @override
  void initState() {
    super.initState();
    controller.text = initialValue ?? "";
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
    title: TextField(
      controller: _controller,
      decoration: InputDecoration(hintText: hint),
      onChanged: (value) {
        final stream = (items as SearchResultStream);
        stream.query = value;
        stream.load(Provider.of<Client>(context, listen: false));
      },
    ),
    children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints.loose(Size(double.infinity, 400)),
          child: buildStream(context)
        ),
    ],
  );

  @override
  Widget buildItem(BuildContext context, SearchResult item) {
    if (item.person != null) {
      final placeholder = Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(Icons.person));
      Widget avatar;
      if (item.person.avatar != null)  {
        avatar = ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
            width: 36,
            height: 36,
            imageUrl: item.person.avatar,
            placeholder: (context, url) => placeholder,
          )
        );
      } else {
        avatar = placeholder;
      }

      return ListTile(leading: avatar, title: Text(item.person.nameOrId), onTap: () => Navigator.pop(context, item.person));
    } else {
      return ListTile(title: Text("#${item.tag}"), onTap: () => Navigator.pop(context, item.tag));
    }
  }
}

class TagSearchDialog extends StatefulWidget {
  TagSearchDialog({Key key, this.initialValue}) : super(key: key);

  final String initialValue;

  @override
  State<StatefulWidget> createState() => _TagSearchDialogState();
}

class _TagSearchDialogState extends _SearchDialogState<TagSearchDialog> {
  _TagSearchDialogState() : super(hint: "Search for a tag");

  @override
  String get initialValue => widget.initialValue;

  @override
  ItemStream<SearchResult> createStream() => SearchResultStream(
    type: SearchType.tags,
    query: widget.initialValue,
    includeQueryAsTag: true
  );
}

class PeopleSearchDialog extends StatefulWidget {
  PeopleSearchDialog({Key key, this.initialValue, this.people = const SearchablePeople.all()}) : super(key: key);

  final String initialValue;
  final SearchablePeople people;

  @override
  State<StatefulWidget> createState() => _PeopleSearchDialogState();
}

class _PeopleSearchDialogState extends _SearchDialogState<PeopleSearchDialog> {
  _PeopleSearchDialogState() : super(hint: "Search for person");

  @override
  String get initialValue => widget.initialValue;

  @override
  ItemStream<SearchResult> createStream() {
    return SearchResultStream(
      type: SearchType.people,
      query: widget.initialValue,
      people: widget.people
    );
  }
}