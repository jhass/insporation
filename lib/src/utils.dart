import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

T tryProvide<T>(BuildContext context, {bool listen = false}) {
  try {
    return Provider.of(context, listen: listen);
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

String presence(String value) => value == null || value.isEmpty || value.trim().isEmpty ?  null : value;

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

class CancelableFuture<T> {
  final Future<T> _future;
  bool _canceled = false;

  CancelableFuture(Future<T> future) : _future = future;

  CancelableFuture<U> then<U>(FutureOr<U> Function(T) onValue) =>
    CancelableFuture(get().then(onValue));

  Future<T> get() async {
    T result = await _future;

    if  (_canceled) {
      throw FutureCanceledError();
    }

    return result;
  }

  void cancel() => _canceled = true;
}

class FutureCanceledError implements Exception {}
