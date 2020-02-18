import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/navigation.dart';
import 'src/search.dart';

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ItemStreamState<SearchResult, SearchPage> {
  final _search = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                  SearchType.people: Text("People"),
                  SearchType.peopleByTag: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text("People by tag")
                  ),
                  SearchType.tags: Text("Tags")
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
                  border: OutlineInputBorder(),
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
        return "Start typing a name or diaspora* ID";
      case SearchType.peopleByTag:
        return "Enter a tag";
      case SearchType.tags:
        return "Start typing tag";
    }

    return null; // case is exhaustive, never reached
  }

  Widget _buildLeading(SearchResult item) {
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

  String _formatTitle(SearchResult item) => item.tag != null ? "#${item.tag}" : item.person.nameOrId;

  void _launchItem(SearchResult item) {
    if (item.person != null) {
      Navigator.pushNamed(context, "/profile", arguments: item.person);
    } else {
      Navigator.pushNamed(context, "/stream/tag", arguments: item.tag);
    }
  }
}
