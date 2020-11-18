import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/search.dart';
import 'src/widgets.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ItemStreamState<SearchResult, SearchPage> with StateLocalizationHelpers {
  final _search = TextEditingController();

  @override
  Widget buildBody(BuildContext context) {
    final SearchResultStream items = this.items;
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.search),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoSegmentedControl(
                selectedColor: theme.brightness == Brightness.light ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                unselectedColor: theme.colorScheme.surface,
                children: {
                  SearchType.people: Text(l.searchTypePeople),
                  SearchType.peopleByTag: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text(l.searchTypePeopleByTag)
                  ),
                  SearchType.tags: Text(l.searchTypeTags)
                },
                groupValue: items.type,
                onValueChanged: (type) => setState(() {
                  items.type = type;
                  items.load(context.read<Client>());
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: _hintText(items.type),
                  border: OutlineInputBorder(),
                  filled: true
                ),
                onChanged: (query) {
                  items.query = query;
                  items.load(context.read<Client>());
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
  ItemStream<SearchResult> createStream() => SearchResultStream();

  @override
  Widget buildItem(BuildContext context, SearchResult item) => InkWell(
    onTap: () => _launchItem(item),
    child: Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: ListTile(
        leading: _buildLeading(item),
        title: Text(_formatTitle(item))
      )
    ),
  );

  String _hintText(SearchType type) {
    switch (type) {
      case SearchType.people:
        return l.searchPeopleHint;
      case SearchType.peopleByTag:
        return l.searchPeopleByTagHint;
      case SearchType.tags:
        return l.searchTagsHint;
    }

    return null; // case is exhaustive, never reached
  }

  Widget _buildLeading(SearchResult item) {
    if (item.person != null) {
      return Avatar(person: item.person, size: 36);
    } else {
      return null;
    }
  }

  String _formatTitle(SearchResult item) => item.tag != null ? "#${item.tag}" : item.person.nameOrId;

  void _launchItem(SearchResult item) {
    if (item.person != null) {
      Navigator.pushNamed(context, "/profile", arguments: item.person);
    } else if (item.tag != null) {
      Navigator.pushNamed(context, "/stream/tag", arguments: item.tag);
    }
  }
}
