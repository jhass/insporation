import 'package:flutter/material.dart' hide Notification, Page, NavigationBar;
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/utils.dart';
import 'src/widgets.dart';
import 'src/colors.dart' as colors;

class NotificationStream extends ItemStream<Notification> {
  @override
  Future<Page<Notification>> loadPage({required Client client, String? page}) =>
    client.fetchNotifications(page: page);
}

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ItemStreamState<Notification, NotificationsPage> {
  @override
  Widget buildBody(BuildContext context) {
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
  _NotificationListItem(this.notification, {Key? key}) : super(key: key);

  final Notification notification;

  @override
  State<StatefulWidget> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<_NotificationListItem> with StateLocalizationHelpers {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.notification.guid),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: widget.notification.read ? theme.colorScheme.secondary : Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.done),
      ),
      confirmDismiss: _toggleRead,
      child: InkWell(
        onTap: _canGoToTarget ? _goToTarget : null,
        child: Container(
          decoration:  BoxDecoration(
            color: widget.notification.read ? theme.backgroundColor : colors.unreadItemBackground(theme),
            border: Border(
              left: widget.notification.read ? BorderSide.none : BorderSide(color: theme.colorScheme.secondary, width: 2),
              bottom: BorderSide(color: widget.notification.read ? theme.dividerColor : colors.unreadItemBottomBorder(theme))
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: AvatarStack(people: widget.notification.eventCreators),
            title: Text(_title),
          ),
        ),
      ),
    );
  }

  String get _title {
    final actorCount = widget.notification.eventCreators.length;

    switch (widget.notification.type) {
      case NotificationType.alsoCommented:
        return l.notificationAlsoCommented(actorCount, _actors, _target);
      case NotificationType.commentOnPost:
        return l.notificationCommented(actorCount, _actors, _target);
      case NotificationType.contactsBirthday:
        return l.notificationBirthday(actorCount, _actors);
      case NotificationType.liked:
        return l.notificationLiked(actorCount, _actors, _target);
      case NotificationType.mentioned:
        return l.notificationMentionedInPost(actorCount, _actors, _target);
      case NotificationType.mentionedInComment:
        return widget.notification.targetGuid != null ?
          l.notificationMentionedInComment(actorCount, _actors) :
          l.notificationMentionedInCommentOnDeletedPost(actorCount, _actors);
      case NotificationType.reshared:
        return l.notificationReshared(actorCount, _actors, _target);
      case NotificationType.startedSharing:
        return l.notificationStartedSharing(actorCount, _actors);
    }
  }

  String get _actors {
    final names = widget.notification.eventCreators.map((actor) => actor.name ?? actor.diasporaId).toList();
    if (names.length == 1) {
      return names[0];
    } else if (names.length == 2) {
      return l.notificationActorsForTwoPeople(names[0], names[1]);
    } else if (names.length == 3) {
      return l.notificationActorsForThreePeople(names[0], names[1], names[2]);
    } else {
      return l.notificationActorsForMoreThanThreePeople(names[0], names[1], names.length - 2);
    }
  }

  String get _target => widget.notification.targetGuid == null ? l.notificationTargetDeletedPost : l.notificationTargetPost;

  bool get _canGoToTarget {
    switch (widget.notification.type) {
      case NotificationType.startedSharing:
      case NotificationType.contactsBirthday:
        return true;
      default:
        return widget.notification.targetGuid != null;
    }
  }

  Future<bool> _toggleRead(_) async {
    await _setRead(!widget.notification.read);

    return false;
  }

  Future<void> _setRead(bool newStatus) async {
    if (widget.notification.read == newStatus) {
      return;
    }

    final client = context.read<Client>(),
      unreadCount = context.read<UnreadNotificationsCount>();

    setState(() => widget.notification.read = newStatus);
    if (newStatus) {
      unreadCount.decrement();
    } else {
      unreadCount.increment();
    }

    try {
      await client.setNotificationRead(widget.notification, isRead: newStatus);
    } catch (e, s)  {
      tryShowErrorSnackBar(context, newStatus ? l.failedToMarkNotificationAsRead : l.failedToMarkNotificationAsUnread, e, s);

      if (mounted) {
        setState(() => widget.notification.read = !newStatus);
      }

      if (newStatus) {
        unreadCount.increment();
      } else {
        unreadCount.decrement();
      }
    }
  }

  void _goToTarget() async {
    _setRead(true);

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
  }
}
