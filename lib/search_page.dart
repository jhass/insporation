import 'package:flutter/material.dart';

import 'src/navigation.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.search),
      body: Center(child: Text("TODO"))
    );
  }
}