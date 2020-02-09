import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'error_message.dart';

abstract class ItemStream<T> extends ChangeNotifier {

  bool loading = false;
  Page<T> _lastPage;
  List<T> _items;

  int get length => _items?.length ?? 0;

  T operator [](int index) => _items[index];

  void insert(int position, T item) {
    if (_items == null && position == 0) {
      _items = [item];
    } else if (_items != null) {
      _items.insert(position, item);
    } else {
      throw ArgumentError("position outside range");
    }

    notifyListeners();
  }

  int remove(T item) {
    assert(_items != null, "Tried to remove item from empty stream!");
    if (_items == null) {
      return 0;
    }

    final index = _items.indexOf(item);

    assert(index >= 0, "Item to remove not found in stream");
    if (index < 0) {
      return 0;
    }

    _items.removeAt(index);
    notifyListeners();
    return index;
  }

  void replace({T toRemove, T replacement}) {
    assert(_items != null, "Stream not created yet");
    if (_items == null) {
      _items = [replacement];
      notifyListeners();
      return;
    }

    final index = _items.indexOf(toRemove);
    assert(index >= 0, "Item to remove not in stream!");
    if (index >= 0) {
      _items[index] = replacement;
    } else {
      _items.insert(0, replacement);
    }
    notifyListeners();
  }

  bool contains(T item) {
    return _items != null && _items.contains(item);
  }

  Future<void> load(Client client, {bool reset = false}) {
    if (loading) {
      return Future.value();
    } else if (reset) {
      _lastPage = null;
      _items = null;
    } else if (_lastPage != null && _lastPage.nextPage == null) {
      return Future.value();
    }

    return _load(client, page: _lastPage?.nextPage);
  }

  Future<void> _load(Client client, {page}) async {
    loading = true;

    try {
      Page<T> newPage = await loadPage(client: client, page: page);
      _lastPage = newPage;
      if (_items == null || page == null) {
        _items = newPage.content;
      } else {
        _items.addAll(newPage.content);
      }
      notifyListeners();
    } finally {
      loading = false;
    }
  }

  Future<Page<T>> loadPage({Client client, String page});
}

abstract class ItemStreamState<T, W extends StatefulWidget> extends State<W> {
  ItemStreamState({this.enableUpButton = true});

  final enableUpButton;
  final _refreshIndicator = GlobalKey<RefreshIndicatorState>();
  ItemStream<T> _items;
  String _lastError;
  ScrollController _listScrollController = ScrollController();
  var _upButtonVisibility = false;

  ItemStream<T> createStream();

  Widget buildHeader(BuildContext context, String lastError) => ErrorMessage(lastError);

  Widget buildItem(BuildContext context, T item);

  void onReset() {}

  @override
  void initState() {
    super.initState();
    _items = createStream();

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        _refreshIndicator.currentState.show());
    _listScrollController.addListener(() {
      final newVisibility = _listScrollController.offset >= 800;
      if (newVisibility != _upButtonVisibility) {
        setState(() => _upButtonVisibility = newVisibility);
      }

      if (_listScrollController.offset >= _listScrollController.position.maxScrollExtent - 200)  {
        _loadItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) => buildStream(context);

  Widget buildStream(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicator,
      onRefresh: () => _loadItems(reset: true),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: ChangeNotifierProvider.value(
          value: _items,
          child: Consumer<ItemStream<T>>(
            builder: (context, items, _) => Visibility(
              visible: items.length > 0,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: items.length > 0 ? items.length + 2 : 0,
                    controller: _listScrollController,
                    itemBuilder: (context, position) =>
                      position == 0 ? buildHeader(context, _lastError):
                        position > items.length ?
                          Visibility(
                            visible: items.loading,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          ) :
                          buildItem(context, items[position -1])
                  ),
                  Positioned(
                    right: 8,
                    top: 48,
                    child: AnimatedSwitcher(
                      transitionBuilder: (child, animation) => FadeTransition(child: child, opacity: animation),
                      duration: Duration(milliseconds: 300),
                      child: !_upButtonVisibility || !enableUpButton ? SizedBox.shrink() : ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          color: Colors.black38,
                          child: IconButton(
                            color: Colors.white,
                            padding: const EdgeInsets.all(0),
                            iconSize: 48,
                            icon: Icon(Icons.keyboard_arrow_up),
                            onPressed: () =>
                              _listScrollController.animateTo(1, duration: Duration(seconds: 1), curve: Curves.easeOut),
                          ),
                        ),
                      ),
                    ),
                  )
                ]
              ),
              replacement: _StreamFallback(
                header: buildHeader(context, _lastError),
                loading: _items.loading
              )
            ),
          ),
        )
      )
    );
  }

  @override
  @mustCallSuper
  dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  _loadItems({bool reset = false}) async {
    try {
      final client = Provider.of<Client>(context, listen: false);
      Future<void> progress;
      setState(() {
        _lastError = null;
        progress = _items.load(client, reset: reset);
      });
      if (reset) {
        onReset();
      }
      await progress;
      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      debugPrintStack(label: e.toString(), stackTrace:  s);
      if (mounted) {
        setState(() {
          _lastError = e.toString();
        });
      }
    }
  }
}

class _StreamFallback extends StatelessWidget {
  _StreamFallback({Key key, this.header, this.loading = false}) : super(key: key);

  final Widget header;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, viewportConstraints) =>
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                header,
                Visibility(
                  visible: !loading,
                  replacement: SizedBox( // We need to take up some space so the refresh indicator renders
                    width: viewportConstraints.maxWidth,
                    height: viewportConstraints.maxHeight
                  ),
                  child: Center(
                    child: Text("Darn, nothing to display!"),
                  ),
                ),
              ],
            ),
          ),
        )
      )
    );
  }
}