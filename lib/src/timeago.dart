import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

final timeagoLocaleMessages = <String, timeago.LookupMessages>{
  Locale('ar').toLanguageTag(): timeago.ArMessages(),
  Locale('de').toLanguageTag(): timeago.DeMessages(),
  Locale('en').toLanguageTag(): timeago.EnMessages(),
  Locale('fr').toLanguageTag(): timeago.FrMessages(),
  Locale('it').toLanguageTag(): timeago.ItMessages(),
};

class Timeago extends StatefulWidget {
  static loadLocale(Locale locale) {
    timeago.setLocaleMessages(locale.toLanguageTag(), timeagoLocaleMessages[locale.toLanguageTag()]);
  }

  Timeago(this.dateTime, {this.textStyle});

  final DateTime dateTime;
  final TextStyle textStyle;

  @override
  _TimeagoState createState() {
    return _TimeagoState();
  }
}

class _TimeagoState extends State<Timeago> {
  String _currentText;
  Timer _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_timer != null) {
      _timer.cancel();
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    setState(() {
      _currentText = timeago.format(widget.dateTime, locale: locale);
    });

    _timer = Timer.periodic(Duration(minutes: 1), (_) => setState(() =>
      _currentText = timeago.format(widget.dateTime, locale: locale)));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentText, style: widget.textStyle);
  }
}
