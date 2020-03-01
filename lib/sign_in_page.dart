import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'src/client.dart';
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

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _diasporaIdController = TextEditingController();
  final _initialFocus = FocusNode();
  var _loading = true;
  String _lastError;

  @override
  void initState() {
    super.initState();

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
        child: Container(
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/icons/icon_round.png"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("insporation*", style: TextStyle(fontSize: 24),),
                ),
                Visibility(
                  visible: !_loading,
                  replacement: CircularProgressIndicator(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: _diasporaIdController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.person),
                            hintText: "username@diaspora.pod",
                            labelText: "diaspora* ID"
                          ),
                          focusNode: _initialFocus, // autofocus: true is broken and raises on start
                          autocorrect: false,
                          enableSuggestions: false,
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: <TextInputFormatter> [ // textCapitalization is ignored for email type, so we have to do it ourselves
                            TextInputFormatter.withFunction((oldValue, newValue) =>
                              newValue.copyWith(text: newValue.text.toLowerCase())
                            )
                          ],
                          onEditingComplete: _submit,
                          validator: (String value) {
                            return !RegExp(r"^[\w.]+@[\w+.]+$").hasMatch(value) ? "Enter a full diaspora* ID" : null;
                          },
                        ),
                        RaisedButton(
                          child: Text("Sign in"),
                          onPressed: _submit,
                        )
                      ]
                    ),
                  ),
                ),
                ErrorMessage(_lastError)
              ]
            )
          )
        ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _diasporaIdController.dispose();
  }

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
        Navigator.pushReplacementNamed(context, '/stream/main');
      } else {
        setState(() => _loading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_initialFocus);
        });
      }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_initialFocus);
    });
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      // Workaround failing assertion when hiding TextField with focus
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }

      setState(() {
        _loading = true;
        _lastError = null;
      });

      final client = Provider.of<Client>(context, listen: false);
      try {
        await client.switchToUser(_diasporaIdController.text);
        await _ensureAuthorization();
        Navigator.pushReplacementNamed(context, '/stream/main');
      } catch (e) {
        setState(() {
          _lastError = e.toString();
          _loading = false;
        });
      }
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
}
