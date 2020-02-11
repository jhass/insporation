import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';


class ErrorSnackBar extends SnackBar {
  ErrorSnackBar(String message) : super(
    content: Text(message, style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.red
  );
}

class AvatarStack extends StatelessWidget {
  AvatarStack({Key key, this.people}) : super(key: key);

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final people = this.people.where((person) => person.avatar != null).toList(),
      displayCount = min(3, people.length);

    return SizedBox.fromSize(
      size: Size.square(54),
      child: displayCount > 0 ? Stack(
        children: List.generate(min(3, people.length), (index) =>
          Positioned(
            top: 4.0 * (displayCount - index - 1),
            left: 4.0 * (displayCount - index - 1),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: Colors.white,
                child: CachedNetworkImage(
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  imageUrl: people[displayCount - index -1].avatar
                ),
              )
            )
          )
        ),
      ) : Center(child: Icon(Icons.person, size: 46))
    );
  }
}

class UnreadItemsIndicatorIcon<T extends ItemCountNotifier> extends StatefulWidget {
  UnreadItemsIndicatorIcon(this.icon, {Key key}) : super(key: key);

  final IconData icon;

  @override
  State<StatefulWidget> createState() => _UnreadItemsIndicatorIconState<T>();
}

class _UnreadItemsIndicatorIconState<T extends ItemCountNotifier> extends State<UnreadItemsIndicatorIcon> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(widget.icon),
        Positioned(
          right: 0,
          child: Consumer<T>(
            builder: (context, unreadCount, child) => Visibility(visible: unreadCount.count > 0, child: child),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle
              ),
              width: 10,
              height: 10
            )
          )
        )
      ]
    );
  }
}

abstract class ItemCountNotifier<T> extends ChangeNotifier {
  Timer _timer;
  bool _evenMore = false;
  int _count = 0;

  int get count => _count;

  // We only poll the first page of unread notifications, this indicates whether there's more pages.
  bool get evenMore => _evenMore;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void update(Client client) {
    if (_timer != null) {
      _timer.cancel();
    }

    _fetch(client);
    _timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) => _fetch(client));
  }

  _fetch(Client client) async {
    if (client.hasSession) {
      try {
        final page = await fetchFirstPage(client);
        final newCount = page.content.length;
        final newEvenMore = page.nextPage != null;

        if (newCount != _count || newEvenMore != _evenMore) {
          _count = newCount;
          _evenMore = newEvenMore;
          notifyListeners();
        }
      } catch (e, s) {
        debugPrintStack(label: "Failed to fetch item count in $runtimeType: $e", stackTrace: s);
      }
    }
  }

  Future<Page<T>> fetchFirstPage(Client client);

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    super.dispose();
  }
}


class TextIcon extends StatelessWidget {
  TextIcon({Key key, @required this.character}) : super(key: key) {
    assert(character != null);
    assert(character.length == 1);
  }

  final String character;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context),
      fontSize = theme.size -2;
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Text(
        character,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: theme.color
        )
      )
    );
  }
}