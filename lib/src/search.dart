import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';

import 'client.dart';
import 'item_stream.dart';
import 'widgets.dart';

enum SearchType { people, peopleByTag, tags }
enum ContactsSearchType { all, receiving, sharing, mutual }

class SearchablePeople {
  final List<Person> list;
  final ContactsSearchType contactsSearchType;
  final List<Aspect> inAspects;

  const SearchablePeople.all() : list = null, contactsSearchType = null, inAspects = null;
  SearchablePeople.list(this.list) : contactsSearchType = null, inAspects = null;
  const SearchablePeople.contacts() : contactsSearchType = ContactsSearchType.all, list = null, inAspects = null;
  const SearchablePeople.receivingContacts() : contactsSearchType = ContactsSearchType.receiving,  list = null, inAspects = null;
  const SearchablePeople.sharingContacts() : contactsSearchType = ContactsSearchType.sharing,  list = null, inAspects = null;
  const SearchablePeople.mutualContacts() : contactsSearchType = ContactsSearchType.mutual, list = null, inAspects = null;
  SearchablePeople.inAspects(this.inAspects) : contactsSearchType = ContactsSearchType.all, list = null;
  const SearchablePeople.none() : list = const [], contactsSearchType = null, inAspects = null;

  List<String> get filters {
    assert(list == null, "Can't do a filtered search through a given list of people");
    final filters = <String>[];

    if (contactsSearchType != null) {
      if (contactsSearchType == ContactsSearchType.all && inAspects == null) {
        filters.add("contacts");
      }

      if (contactsSearchType == ContactsSearchType.receiving || contactsSearchType == ContactsSearchType.mutual) {
        filters.add("contacts:receiving");
      }

      if (contactsSearchType == ContactsSearchType.sharing || contactsSearchType == ContactsSearchType.mutual) {
        filters.add("contacts:sharing");
      }
    }

    if (inAspects != null) {
      filters.add("aspect:${inAspects.map((aspect) => aspect.id).join(",")}");
    }

    return filters.isNotEmpty ? filters : null;
  }
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

    if (people.list != null) {
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

    if (_type == SearchType.tags && _query == '#') {
      return Page.empty();
    }

    bool _matchPerson(Person person) =>
      person.nameOrId.contains(_query) || person.diasporaId.contains(RegExp(RegExp.escape(_query), caseSensitive: false));

    switch (_type) {
      case SearchType.people:
        if (people.list != null) {
          return Page(content: people.list.where(_matchPerson).map((person) => SearchResult.forPerson(person)).toList());
        }

        final result = await client.searchPeopleByName(query, filters: people.filters, page: page);
        return result.map((person) => SearchResult.forPerson(person));
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


abstract class _SearchDialogState<T extends StatefulWidget> extends ItemStreamState<SearchResult, T> {
  _SearchDialogState() : super(enableUpButton: false);

  final _controller = TextEditingController();
  bool _loading = false;

  @protected
  TextEditingController get controller => _controller;

  String get hint => l.searchDialogHint;

  String get initialValue => null;

  @override
  void initState() {
    super.initState();
    controller.text = initialValue ?? "";
  }

  @override
  Widget buildBody(BuildContext context) => SimpleDialog(
    title: TextField(
      controller: _controller,
      decoration: InputDecoration(hintText: hint),
      onChanged: (value) async {
        final stream = (items as SearchResultStream);
        stream.query = value;
        setState(() => _loading = true);
        await stream.load(context.read<Client>());
        if (mounted) {
          setState(() => _loading = false);
        }
      },
    ),
    children: <Widget>[
      Visibility(visible: _loading, child: Center(child: CircularProgressIndicator())),
      ConstrainedBox(
        constraints: BoxConstraints(minWidth: double.maxFinite, maxWidth: double.maxFinite, maxHeight: 400),
        child: buildStream(context)),
    ],
  );

  @override
  Widget buildItem(BuildContext context, SearchResult item) {
    if (item.person != null) {
      return ListTile(
        leading: Avatar(person: item.person, size: 36),
        title: Text(item.person.nameOrId),
        onTap: () => Navigator.pop(context, item.person)
      );
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
  @override
  String get hint => l.tagSearchDialogHint;

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
  @override
  String get hint => l.peopleSearchDialogHint;

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
