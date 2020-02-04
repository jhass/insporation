import 'package:flutter/material.dart';

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

class NavigationBar extends StatelessWidget {
  static List<_BarItem> _mainItems = <_BarItem>[
    _BarItem(PageType.stream, Icons.view_stream, "Stream", "/stream/main"),
    _BarItem(PageType.conversations, Icons.mail, "Conversations", "/conversations"),
    _BarItem(PageType.search, Icons.search, "Search", "/search"),
    _BarItem(PageType.notifications, Icons.notifications, "Notifications", "/notifications")
  ];

  static List<_BarItem> _moreItems = <_BarItem>[
    _BarItem(PageType.contacts, null, "Contacts", "/contacts"),
    _BarItem(PageType.edit_profile, null, "Edit profile", "/edit_profile"),
    _BarItem(PageType.sign_in, null, "Switch user", "/switch_user")
  ];

  NavigationBar({Key key, @required this.currentPage}) : super(key: key);

  final PageType currentPage;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _mainItems.indexWhere((item) => item.page == currentPage);
    final items = _mainItems.map((item) => BottomNavigationBarItem(icon: Icon(item.icon), title: Text(item.title))).toList();
    items.add(BottomNavigationBarItem(title: Text(""), icon: Icon(Icons.more_horiz)));

    return BottomNavigationBar(
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.blueAccent,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) {
          return;
        }
        if (index < _mainItems.length) {
          Navigator.of(context).pushReplacementNamed(_mainItems[index].route);
        } else {
          final RenderBox bar = context.findRenderObject();
          final RenderBox overlay = Overlay.of(context).context.findRenderObject();
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              bar.localToGlobal(bar.size.topRight(Offset.zero) - Offset(0, bar.size.height + _moreItems.length * 36), ancestor: overlay),
              bar.localToGlobal(bar.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );
          showMenu(
            context: context,
            position: position,
            items: _moreItems.map((item) => PopupMenuItem(child: Text(item.title), value: item) ).toList(),
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
}

class _BarItem {
  final PageType page;
  final IconData icon;
  final String title;
  final String route;

  _BarItem(this.page, this.icon, this.title, this.route);
}
