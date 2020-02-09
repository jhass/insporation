import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

T tryProvide<T>(BuildContext context) {
  try {
    return Provider.of(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}
bool containSameElements(Iterable a, Iterable b) {
  if (a.length != b.length) {
    return false;
  }

  return a.toSet().containsAll(b);
}