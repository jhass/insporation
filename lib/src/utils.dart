import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

T tryProvide<T>(BuildContext context) {
  try {
    return Provider.of(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}