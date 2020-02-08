import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';

class UnreadNotificationsCount extends ChangeNotifier {
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
        final page = await client.fetchNotifications(onlyUnread: true);
        final newCount = page.content.length;
        final newEvenMore = page.nextPage != null;

        if (newCount != _count || newEvenMore != _evenMore) {
          _count = newCount;
          _evenMore = newEvenMore;
          notifyListeners();
        }
      } catch (e, s) {
        debugPrintStack(label: "Failed to fetch unread notification count: $e", stackTrace: s);
      }
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }

    super.dispose();
  }
}

class NotificationsItemIcon extends StatefulWidget {
  NotificationsItemIcon(this.icon, {Key key}) : super(key: key);

  final IconData icon;

  @override
  State<StatefulWidget> createState() => _NotificationsItemIconState();
}

class _NotificationsItemIconState extends State<NotificationsItemIcon> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(widget.icon),
        Positioned(
          right: 0,
          child: Consumer<UnreadNotificationsCount>(
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