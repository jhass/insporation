import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

T tryProvide<T>(BuildContext context) {
  try {
    return Provider.of(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}
bool containSameElements(Iterable a, Iterable b) {
  if ((a == null && b != null) || (a != null && b == null)) {
    return false;
  }

  if (a == null && b == null) {
    return true;
  }

  if (a.length != b.length) {
    return false;
  }

  return a.toSet().containsAll(b);
}

void tryShowErrorSnackBar(State widget, String message, exception, stack) {
  if (widget.mounted) {
    showErrorSnackBar(Scaffold.of(widget.context), message, exception, stack);
  } else {
    _debugPrintError(message, exception, stack);
  }
}

void showErrorSnackBar(ScaffoldState scaffold, String message, exception, stack) {
  final exceptionMessage = _debugPrintError(message, exception, stack);
  if (scaffold.mounted) {
    scaffold.showSnackBar(errorSnackbar(scaffold.context, "$message: $exceptionMessage"));
  }
}

String _debugPrintError(String message, exception, stack) {
  var exceptionMessage = exception.toString();
  try {
    exceptionMessage  = exception.message;
  } on NoSuchMethodError {}

  debugPrintStack(label: "$message: $exceptionMessage", stackTrace: stack);

  return exceptionMessage;
}
