import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Timeago extends StatefulWidget {
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
  void initState() {
    super.initState();

    setState(() {
      _currentText = timeago.format(widget.dateTime);
    });

    _timer = Timer.periodic(Duration(minutes: 1), (_) => setState(() =>
      _currentText = timeago.format(widget.dateTime)));
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
