import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:insporation/src/localizations.dart';

import 'client.dart';
import 'widgets.dart';
import 'colors.dart' as colors;

enum PageType {
  stream,
  publisher,
  notifications,
  conversations,
  search,
  contacts,
  edit_profile,
  sign_in,
  profile,
  post
}

class NavigationBar extends StatelessWidget with LocalizationHelpers {
  NavigationBar({Key key, @required this.currentPage}) : super(key: key);

  final PageType currentPage;

  @override
  Widget build(BuildContext context) {
    final mainItems = _mainItems(l(context)),
      moreItems = _moreItems(l(context)),
      currentIndex = mainItems.indexWhere((item) => item.page == currentPage),
      items = mainItems.map(_buildMainItem).toList();
    items.add(BottomNavigationBarItem(title: Text(""), icon: Icon(Icons.more_horiz)));

    final theme = Theme.of(context);

    return BottomNavigationBar(
      unselectedItemColor: colors.unselectedNavigationItem(theme),
      selectedItemColor: theme.colorScheme.secondary,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          return;
        }
        if (index < mainItems.length) {
          Navigator.of(context).pushReplacementNamed(mainItems[index].route);
        } else {
          final RenderBox bar = context.findRenderObject();
          final RenderBox overlay = Overlay.of(context).context.findRenderObject();
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              bar.localToGlobal(bar.size.topRight(Offset.zero) - Offset(0, bar.size.height + moreItems.length * 36), ancestor: overlay),
              bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );
          showMenu(
            context: context,
            position: position,
            items: moreItems.map((item) => PopupMenuItem(child: Text(item.title), value: item) ).toList(),
          ).then((selected) {
            if (selected != null) {
              Navigator.of(context).pushNamed(selected.route);
            }
          });
        }
      },
      items: items
    );
  }

  BottomNavigationBarItem _buildMainItem(_BarItem item) {
    var icon;
    switch (item.page) {
      case PageType.notifications:
        icon = UnreadItemsIndicatorIcon<UnreadNotificationsCount>(item.icon);
        break;
      case PageType.conversations:
        icon = UnreadItemsIndicatorIcon<UnreadConversationsCount>(item.icon);
        break;
      default:
        icon = Icon(item.icon);
    }

    return BottomNavigationBarItem(
      icon: icon,
      title: Text(item.title)
    );
  }

  List<_BarItem> _mainItems(InsporationLocalizations l) => <_BarItem>[
    _BarItem(PageType.stream, Icons.view_stream, l.navigationItemTitleStream, "/stream/main"),
    _BarItem(PageType.conversations, Icons.mail, l.navigationItemTitleConversations, "/conversations"),
    _BarItem(PageType.search, Icons.search, l.navigationItemTitleSearch, "/search"),
    _BarItem(PageType.notifications, Icons.notifications, l.navigationItemTitleNotifications, "/notifications")
  ];

  List<_BarItem> _moreItems(InsporationLocalizations l) => <_BarItem>[
    _BarItem(PageType.contacts, null, l.navigationItemTitleContacts, "/contacts"),
    _BarItem(PageType.edit_profile, null, l.navigationItemTitleEditProfile, "/edit_profile"),
    _BarItem(PageType.sign_in, null, l.navigationItemTitleSwitchUser, "/switch_user")
  ];
}

class _BarItem {
  final PageType page;
  final IconData icon;
  final String title;
  final String route;

  _BarItem(this.page, this.icon, this.title, this.route);
}

class UnreadNotificationsCount extends ItemCountNotifier<Notification> {
  @override
  Future<Page<Notification>> fetchFirstPage(Client client) async =>
    client.fetchNotifications(onlyUnread: true);
}

class UnreadConversationsCount extends ItemCountNotifier<Conversation> {
  @override
  Future<Page<Conversation>> fetchFirstPage(Client client) async =>
    client.fetchConversations(onlyUnread: true);
}

class BadgeUpdater {
  int _notificationsCount = 0;
  int _conversationsCount = 0;

  BadgeUpdater() {
    _updateBadge();
  }

  void listenToNotifications(UnreadNotificationsCount count) {
    count.addListener(() {
      _notificationsCount = count.count;
      _updateBadge();
    });
  }

  void listenToConversations(UnreadConversationsCount count) {
    count.addListener(() {
      _conversationsCount = count.count;
      _updateBadge();
    });
  }

  void _updateBadge() {
    FlutterAppBadger.updateBadgeCount(_notificationsCount + _conversationsCount);
  }
}
