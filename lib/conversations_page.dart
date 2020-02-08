import 'package:flutter/material.dart';

import 'src/navigation.dart';

class ConversationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.conversations),
      body: Center(child: Text("TODO"))
    );
  }
}