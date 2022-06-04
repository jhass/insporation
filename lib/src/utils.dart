import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'widgets.dart';

extension TryProvide on BuildContext {
  T? tryRead<T>() => tryProvide<T>(listen: false);

  T? tryWatch<T>() => tryProvide<T>(listen: true);

  T? tryProvide<T>({bool listen = false}) {
    try {
      return Provider.of<T>(this, listen: listen);
    } on ProviderNotFoundException {
      return null;
    }
  }
}

bool containSameElements(Iterable? a, Iterable? b) {
  if (a == null) {
    return b == null;
  } else if (b == null) {
    return false;
  }

  if (a.length != b.length) {
    return false;
  }

  return a.toSet().containsAll(b);
}

String? presence(String? value) => value == null || value.isEmpty || value.trim().isEmpty ?  null : value;

void tryShowErrorSnackBar(BuildContext context, String? message, exception, stack) {
  final state = ScaffoldMessenger.maybeOf(context);
  if (message != null && state != null) {
    showErrorSnackBar(state, message, exception, stack);
  } else {
    _debugPrintError(message ?? "Error", exception, stack);
  }
}

void showErrorSnackBar(ScaffoldMessengerState scaffold, String message, exception, stack) {
  final exceptionMessage = _debugPrintError(message, exception, stack);
  if (scaffold.mounted) {
    scaffold.showSnackBar(errorSnackBar(scaffold.context, "$message: $exceptionMessage"));
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

String formatErrorTrace(Exception exception, StackTrace stackTrace) {
  stackTrace = FlutterError.demangleStackTrace(stackTrace);
  Iterable<String> lines = stackTrace.toString().trimRight().split('\n');
  return "$exception\n${FlutterError.defaultStackFilter(lines).join('\n')}";
}

void openExternalUrl(BuildContext context, String url) {
  try {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } on FormatException catch (exception, stack) {
    tryShowErrorSnackBar(context, AppLocalizations.of(context)?.failedToOpenInvalidUrl, exception, stack);
  } on PlatformException catch (exception, stack) {
    tryShowErrorSnackBar(context, AppLocalizations.of(context)?.failedToOpenUrl, exception, stack);
  }
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
