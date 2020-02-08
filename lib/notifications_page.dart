import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/navigation.dart';
import 'src/notifications.dart';

class NotificationStream extends ItemStream<Notification> {
  @override
  Future<Page<Notification>> loadPage({Client client, String page}) =>
    client.fetchNotifications(page: page);
}

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ItemStreamState<Notification, NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.notifications),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Notification> createStream() => NotificationStream();

  @override
  Widget buildItem(BuildContext context, Notification item) => _NotificationListItem(item);
}

class _NotificationListItem extends StatefulWidget {
  _NotificationListItem(this.notification, {Key key}) : super(key: key);

  final Notification notification;

  @override
  State<StatefulWidget> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<_NotificationListItem> {
  @override
  Widget build(BuildContext context) {
    final actors = widget.notification.eventCreators.where((actor) => actor.avatar != null).toList(),
      displayActorsCount = min(3, actors.length);

    return InkWell(
      onTap: _canGoToTarget ? _goToTarget : null,
      child: Container(
        decoration:  BoxDecoration(
          color: widget.notification.read ? Colors.transparent : Colors.lightBlue[50],
          border: Border(
            left: widget.notification.read ? BorderSide.none : BorderSide(color: Colors.blueAccent, width: 2),
            bottom: BorderSide(color: widget.notification.read ? Colors.grey[200] : Colors.blueGrey[100])
          )
        ),
        padding: EdgeInsets.only(top: 8),
        child: ListTile(
          leading: SizedBox.fromSize(
            size: Size.square(54),
            child: displayActorsCount > 0 ? Stack(
              children: List.generate(min(3, actors.length), (index) =>
                Positioned(
                  top: 4.0 * (displayActorsCount - index - 1),
                  left: 4.0 * (displayActorsCount - index - 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      imageUrl: actors[displayActorsCount - index -1].avatar
                    )
                  )
                )
              ),
            ) : Center(child: Icon(Icons.person, size: 46))
          ),
          title: Text(_title),
        ),
      ),
    );
  }

  String get _title {
    switch (widget.notification.type) {
      case NotificationType.alsoCommented:
        return "$_actors also commented on a $_target.";
      case NotificationType.commentOnPost:
        return "$_actors commented on your $_target.";
      case NotificationType.contactsBirthday:
        return "$_actors has their birthday today.";
      case NotificationType.liked:
        return "$_actors liked your $_target.";
      case NotificationType.mentioned:
        return "$_actors mentioned you in a $_target.";
      case NotificationType.mentionedInComment:
        final suffix = widget.notification.targetGuid == null ? " of a deleted post." : "";
        return "$_actors mentioned you in a comment$suffix.";
      case NotificationType.reshared:
        return "$_actors reshared your $_target.";
      case NotificationType.startedSharing:
        return "$_actors started sharing with you.";
    }

    return "$_actors did something noteworthy!"; // case above is exhaustive, never happens
  }

  String get _actors {
    final names = widget.notification.eventCreators.map((actor) => actor.name ?? actor.diasporaId).toList();
    if (names.length == 1) {
      return names[0];
    } else if (names.length == 2) {
      return "${names[0]} and ${names[1]}";
    } else {
      final others = names.length == 3 ? names[2] : "${names.length - 2} others";
      return "${names.take(2).join(", ")} and $others";
    }
  }

  String get _target => widget.notification.targetGuid == null ? "deleted post" : "post";

  bool get _canGoToTarget {
    switch (widget.notification.type) {
      case NotificationType.startedSharing:
      case NotificationType.contactsBirthday:
        return true;
      default:
        return widget.notification.targetGuid != null;
    }
  }

  void _goToTarget() async {
    final client = Provider.of<Client>(context, listen: false),
      unreadCount = Provider.of<UnreadNotificationsCount>(context, listen: false),
      isUnread = !widget.notification.read;

    if (isUnread) {
      setState(() {
        widget.notification.read = true;
      });
      unreadCount.decrement();
    }

    switch (widget.notification.type) {
      case NotificationType.alsoCommented:
      case NotificationType.commentOnPost:
      case NotificationType.liked:
      case NotificationType.mentioned:
      case NotificationType.reshared:
      case NotificationType.mentionedInComment:
        Navigator.pushNamed(context, "/post", arguments: widget.notification.targetGuid);
        break;
      case NotificationType.contactsBirthday:
      case NotificationType.startedSharing:
        Navigator.pushNamed(context, "/profile", arguments: widget.notification.eventCreators.first);
        break;
    }

    if (isUnread) {
      try {
        await client.setNotificationRead(widget.notification);
      } catch(e, s) {
        debugPrintStack(label: e.message, stackTrace: s);

        if (mounted) {
          setState(() => widget.notification.read = false);
        }

        unreadCount.increment();
      }
    }
  }
}