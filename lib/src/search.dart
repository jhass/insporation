import 'client.dart';
import 'item_stream.dart';

enum SearchType { people, peopleByTag, tags }

class SearchablePeople {
  final bool all;
  final List<Person> list;

  const SearchablePeople.all() : all = true, list = null;
  SearchablePeople.list(this.list) : all = false;
  const SearchablePeople.none() : all = false, list = const [];
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

    switch (_type) {
      case SearchType.people:
        if (people.all) {
          final result = await client.searchPeopleByName(query, page: page);
          return result.map((person) => SearchResult.forPerson(person));
        } // else

        return Page(content: people.list.where((person) =>
            person.nameOrId.contains(_query) || person.diasporaId.contains(RegExp(RegExp.escape(_query), caseSensitive: false))
          ).map((person) => SearchResult.forPerson(person)).toList()
        );
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