import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:insporation/src/localizations.dart';
import 'package:provider/provider.dart';

import 'client.dart';
import 'colors.dart' as colors;

class ErrorMessage extends StatelessWidget with LocalizationHelpers {
  const ErrorMessage(this.message, {Key? key, this.trace, this.onRetry}) : super(key: key);

  final String? message;
  final String? trace;
  final void Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Visibility(
      visible: message != null,
      child: Card(
        color: theme.colorScheme.error,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (trace == null) Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.warning, color: theme.colorScheme.onError),
                  ),
                  Expanded(
                    child: Text(
                      message ?? "",
                      style: TextStyle(color: theme.colorScheme.onError))
                    ),
                  if (trace != null) IconButton(
                    onPressed: () => _showTrace(context),
                    icon: Icon(Icons.help, color: theme.colorScheme.onError),
                    tooltip: l(context).detailsOnErrorLabel,
                  )
                ],
              ),
              if (onRetry != null) TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: theme.colorScheme.onError),
                label: Text(l(context).retryLabel, style: TextStyle(color: theme.colorScheme.onError))
              )
            ],
          ),
        ),
      ),
    );
  }

  _showTrace(context) async {
    final bool? copied = await showDialog(context: context, builder: (dialogContext) => AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(l(dialogContext).detailsOnErrorDescription),
            Divider(),
            SelectableText(trace!, style: TextStyle(fontFamily: 'monospace', fontFamilyFallback: ['Courier'])),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(ml(dialogContext).copyButtonLabel),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: trace!));
            Navigator.pop(dialogContext, true);
          },
        ),
        TextButton(
          child: Text(ml(dialogContext).okButtonLabel),
          onPressed: () => Navigator.pop(dialogContext, false),
        )
      ],
    ));

    if (copied == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l(context).detailsOnErrorCopied)));
    }
  }
}

SnackBar errorSnackBar(BuildContext context, String message) {
  final theme = Theme.of(context);
  return SnackBar(
    content: Text(message, style: TextStyle(color: theme.colorScheme.onError)),
    backgroundColor: theme.colorScheme.error
  );
}

class Avatar extends StatelessWidget {
  Avatar({Key? key, Person? person, String? url, this.size = 24}) : this.url = url ?? person?.avatar, super(key: key);

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: url != null ? ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: RemoteImage(
          url!,
          fallback: Icon(Icons.person),
          fit: BoxFit.cover,
        )
      ) : Icon(Icons.person),
    );
  }
}

class AvatarStack extends StatelessWidget {
  AvatarStack({Key? key, required this.people}) : super(key: key);

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
                color: Theme.of(context).colorScheme.surface,
                child: RemoteImage(
                  people[displayCount - index -1].avatar!,
                  width: 46,
                  height: 46,
                  fallback: SizedBox.shrink(),
                  fit: BoxFit.cover
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
  UnreadItemsIndicatorIcon(this.icon, {Key? key}) : super(key: key);

  final IconData icon;

  @override
  State<StatefulWidget> createState() => _UnreadItemsIndicatorIconState<T>();
}

class _UnreadItemsIndicatorIconState<T extends ItemCountNotifier> extends State<UnreadItemsIndicatorIcon> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Icon(widget.icon),
      Positioned(
          right: 0,
          child: Consumer<T>(
              builder: (context, unreadCount, child) => Visibility(
                  visible: unreadCount.count > 0,
                  child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: colors.unreadIndicator,
                          borderRadius: BorderRadius.circular(6)),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        unreadCount.indicatorText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      )))))
    ]);
  }
}

abstract class ItemCountNotifier<T> extends ChangeNotifier {
  // Limit of items to fetch for the first page
  int pageSize = 9;

  Timer? _timer;
  bool _evenMore = false;
  int _count = 0;
  Client? _lastClient;

  int get count => _count;

  String get indicatorText => evenMore ? "$count+" : _count.toString();

  // We only poll the first page of unread notifications, this indicates whether there's more pages.
  bool get evenMore => _evenMore;

  void increment() {
    if (evenMore) {
      return; // already maxed out
    } else if (_count >= pageSize) {
      // more than one page now
      _evenMore = true;
      notifyListeners();
    } else {
      _count++;
      notifyListeners();
    }
  }

  void decrement() {
    if (evenMore) {
      // We can't know how many items there are after decrementing because we didn't know
      // the exact number in the first place, trigger a refresh instead
      // Since the decrement may happen before an actual update call we delay it slightly.
      Timer(Duration(seconds: 3), () => _fetch(_lastClient));
      _fetch(_lastClient);
    } else {
      _count--;
      notifyListeners();
    }
  }

  void update(Client client) {
    _timer?.cancel();

    _fetch(client);
    _timer = Timer.periodic(Duration(minutes: 1, seconds: 30), (timer) => _fetch(client));
    _lastClient = client;
  }

  _fetch(Client? client) async {
    if (client != null && client.hasSession) {
      try {
        final page = await fetchFirstPage(client);
        final newCount = page.content.length;
        // TODO: The backend always returns a next page link in some cases even when that page is empty.
        // We're working around this for now but it should be fixed in the backend (see also the todo in ItemStream)
        final newEvenMore = newCount >= pageSize && page.nextPage != null;

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
    _timer?.cancel();
    _timer = null;

    super.dispose();
  }
}

class TextIcon extends StatelessWidget {
  TextIcon({Key? key, required this.character}) : super(key: key) {
    assert(character.length == 1);
  }

  final String character;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context),
      fontSize = theme.size != null ? theme.size! - 2 : null;
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

class RemoteImage extends CachedNetworkImage {
  RemoteImage(String url, {double? width, double? height, BoxFit? fit, Widget? fallback}) : super(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    fadeInDuration: Duration(milliseconds: 250),
    placeholder: (_, __) => fallback ?? Center(child: CircularProgressIndicator()),
    errorWidget: (context, __, ___) => fallback ?? Center(child: Icon(Icons.image_not_supported, color: Theme.of(context).colorScheme.error.withOpacity(0.7))));
}

class MeasureSizeRenderObject extends RenderProxyBox {
  MeasureSizeRenderObject(this.onChange);
  void Function(Size size) onChange;

  Size? _prevSize;

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size;
    if (newSize != null && _prevSize != newSize) {
      _prevSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
    }
  }
}

class MeasurableWidget extends SingleChildRenderObjectWidget {
  final void Function(Size size) onChange;

  const MeasurableWidget({Key? key, required this.onChange, required Widget child}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => MeasureSizeRenderObject(onChange);
}

class ExpandChildMaxHeight extends StatefulWidget {
  final Widget child;
  final double maxHeight;
  final double minExpansion;

  ExpandChildMaxHeight({required this.child, this.maxHeight = 400, this.minExpansion = 200});

  @override
  State<StatefulWidget> createState() {
    return _ExpandChildMaxHeightState();
  }
}

class _ExpandChildMaxHeightState extends State<ExpandChildMaxHeight> {
  double? childHeight;

  @override
  Widget build(BuildContext context) {
    final childHeight = this.childHeight;
    if (childHeight == null) {
      return Offstage(
        child: MeasurableWidget(
          onChange: (size) {
            if (this.childHeight == null) setState(() => this.childHeight = size.height);
          },
          child: widget.child
        )
      );
    } else if (childHeight > widget.maxHeight && childHeight - widget.maxHeight >= widget.minExpansion) {
      return ExpandChild(child: widget.child, collapsedVisibilityFactor: widget.maxHeight / childHeight);
    } else {
      return widget.child;
    }
  }
}