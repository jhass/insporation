import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'src/app_auth.dart';
import 'src/client.dart';
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/persistence.dart';
import 'src/utils.dart';
import 'src/widgets.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.resumeLastSession = true, this.error}) : super(key: key);

  final title = 'insporation*';
  final bool resumeLastSession;
  final String error;

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> with StateLocalizationHelpers {
  final _formKey = GlobalKey<FormState>();
  final _diasporaIdController = TextEditingController();
  final _initialFocus = FocusNode();
  var _loading = true;
  String _lastError;
  Future<List<Session>> _sessions;

  @override
  void initState() {
    super.initState();

    _sessions = _recentSessions;

    if (widget.error != null) {
      _showInitialError();
    } else if (widget.resumeLastSession) {
      _resumeLastSession();
    } else {
      _promptNewSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
          child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: 300),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("assets/icons/icon_round.png"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "insporation*",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Visibility(
            visible: !_loading,
            replacement: CircularProgressIndicator(),
            child: Form(
              key: _formKey,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                TextFormField(
                  controller: _diasporaIdController,
                  decoration:
                      InputDecoration(icon: Icon(Icons.person), hintText: l.signInHint, labelText: l.signInLabel),
                  focusNode:
                      _initialFocus, // autofocus: true is broken and raises on start, also we want more manual control
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: <TextInputFormatter>[
                    // textCapitalization is ignored for email type, so we have to do it ourselves
                    TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(text: newValue.text.toLowerCase()))
                  ],
                  onEditingComplete: _submit,
                  validator: (String value) {
                    return !RegExp(r"^[\w._-]+@[\w+._-]+$").hasMatch(value) ? l.invalidDiasporaId : null;
                  },
                ),
                RaisedButton(
                  child: Text(l.signInAction),
                  onPressed: _submit,
                ),
                FutureBuilder(
                  future: _sessions,
                  builder: (context, AsyncSnapshot<List<Session>> state) => ListView.separated(
                      itemBuilder: (context, position) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                          onTap: () => _switchToUser(state.data[position].userId),
                          leading: Icon(Icons.person),
                          trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _destroySession(state.data[position].userId);
                              }),
                          title: Text(state.data[position].userId)),
                      separatorBuilder: (context, position) => Divider(),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.hasData ? state.data.length : 0),
                )
              ]),
            ),
          ),
          ErrorMessage(_lastError)
        ]),
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _diasporaIdController.dispose();
  }

  Future<List<Session>> get _recentSessions => Provider.of<Client>(context, listen: false).allSessions.then((sessions) {
        sessions = sessions.where((session) => session.state != null).toList();
        sessions.sort((a, b) => a.lastActiveAt == 0
            ? 1
            : b.lastActiveAt == 0
                ? -1
                : b.lastActiveAt.compareTo(a.lastActiveAt));
        return sessions = sessions.take(5).toList();
      });

  _showInitialError() async {
    final client = Provider.of<Client>(context, listen: false);
    await client.restoreSession();
    _diasporaIdController.text = client.currentUserId;
    setState(() {
      _lastError = widget.error;
      _loading = false;
    });
  }

  _resumeLastSession() async {
    final client = Provider.of<Client>(context, listen: false),
      persistentState = Provider.of<PersistentState>(context, listen: false);
    await persistentState.restore();

    setState(() {
      _loading = true;
      _lastError = null;
    });

    if (persistentState.wasAuthorizing) {
      // We might have died in the background and now the authorization result is racing with the initial route.
      // The initial route wants to resume the previous session, the authorization result may way to show the main stream
      // or an error message, in any case it would replace the initial route. Give it a chance to win the race by waiting
      // before launching another authorization
      await Future.delayed(Duration(seconds: 1));

      // Whether we've won the race or lost it, we don't need to let the user wait the next time
      persistentState.wasAuthorizing = false;

      // In case we lost the race, we should no longer be mounted and abort our efforts to resume the session
      if (!mounted) {
        return;
      }

      // But if we are, we should be pushed over the route triggered by the authorization response, in that case we can just pop ourselves
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }
    }

    try {
      await client.restoreSession();
      _diasporaIdController.text = client.currentUserId;

      if (client.currentUserId != null) {
        await _ensureAuthorization();
      }

      if (client.hasSession) {
        _onSession(client);
      } else {
        setState(() => _loading = false);
        _maybeFocusInput();
      }
    } on TimeoutException {
      setState(() {
        _loading = false;
        _lastError = l.errorSignInTimeout;
      });
    } catch (e, s) {
      debugPrintStack(label: "Failed to resume session: $e", stackTrace: s);
      setState(() {
        _loading = false;
        _lastError = e.toString();
      });
    }
  }

  _promptNewSession() {
    Provider.of<Client>(context, listen: false).forgetSession();
    setState(() => _loading = false);
    _maybeFocusInput();
  }

  _maybeFocusInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sessions = await _sessions;
      if (sessions.isEmpty) {
        FocusScope.of(context).requestFocus(_initialFocus);
      }
    });
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      // Workaround failing assertion when hiding TextField with focus
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      await _switchToUser(_diasporaIdController.text);
    }
  }

  _switchToUser(String userId) async {
    setState(() {
      _loading = true;
      _lastError = null;
    });

    final client = Provider.of<Client>(context, listen: false);
    try {
      await client.switchToUser(userId);
      await _ensureAuthorization();

      _onSession(client);
    } on TimeoutException {
      setState(() {
        _lastError = l.errorSignInTimeout;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _lastError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _ensureAuthorization() async {
    final client = Provider.of<Client>(context, listen: false),
      persistentState = Provider.of<PersistentState>(context, listen: false);
    try {
      persistentState.wasAuthorizing = true;
      await client.ensureAuthorization();
    } finally {
      persistentState.wasAuthorizing = false;
    }
  }

  _destroySession(String userId) async {
    await showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(title: Text(l.deleteSessionPrompt(userId)), actions: <Widget>[
              FlatButton(
                child: Text(ml.cancelButtonLabel),
                onPressed: () => Navigator.pop(dialogContext),
              ),
              FlatButton(
                child: Text(ml.okButtonLabel),
                onPressed: () async {
                  await Provider.of<Client>(context, listen: false).destroySession(userId);

                  if (mounted) {
                    setState(() { _sessions = _recentSessions; });
                    Navigator.pop(dialogContext);
                  }
                },
              )
            ]));
  }

  _onSession(Client client) {
    // refresh unread counts now that we have a session
    tryProvide<UnreadNotificationsCount>(context)?.update(client);
    tryProvide<UnreadConversationsCount>(context)?.update(client);

    // Move to stream
    Navigator.pushReplacementNamed(context, '/stream');
  }
}
