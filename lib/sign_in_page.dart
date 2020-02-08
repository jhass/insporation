import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/client.dart';
import 'src/error_message.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.resumeLastSession = true}) : super(key: key);

  final title = 'insporation*';
  final bool resumeLastSession;

  @override
  State<StatefulWidget> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  static const _last_diaspora_id_pref = "last_diaspora_id";

  final _formKey = GlobalKey<FormState>();
  final _diasporaIdController = TextEditingController();
  final _initialFocus = FocusNode();
  var _client;
  var _loading = true;
  String _lastError;

  @override
  void initState() {
    super.initState();

    _client = Provider.of<Client>(context, listen: false);
    _client.listenToAuthorizationResponse(
      authorizingUser: () => SharedPreferences.getInstance().then((preferences) => preferences.getString(_last_diaspora_id_pref)),
      success: () {
        setState(() {
          _loading = true;
        });

        Navigator.pushReplacementNamed(context, "/stream/main");
      },
      failed: (error) => setState(() {
        _lastError = error;
        _loading = false;
      })
    );

    if (widget.resumeLastSession) {
      _resumeLastSession();
    } else {
      setState(() => _loading = false);
      SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.remove(_last_diaspora_id_pref));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_initialFocus);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _client = Provider.of<Client>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
          alignment: Alignment.center,
          color: Colors.white,
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
    _client.stopListeningToAuthorizationResponse();
  }

  _resumeLastSession() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      final lastDiasporaId = sharedPreferences.getString(_last_diaspora_id_pref);
      _diasporaIdController.text = lastDiasporaId;
      return lastDiasporaId != null ? _client.switchToUser(lastDiasporaId) : null;
    }).then((_) {
      setState(() {
        _loading = false;
        if (_client.hasSession) {
          if (_client.authorized) {
            _loading = true;
            Navigator.pushReplacementNamed(context, '/stream/main');
          }
        }
      });
    }).catchError((e) => setState(() {
      _loading = false;
      _lastError = e.toString();
    }));
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
        var sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString(_last_diaspora_id_pref, _diasporaIdController.text);
        await client.switchToUser(_diasporaIdController.text);
        Navigator.pushReplacementNamed(context, '/stream/main');
      } catch (e) {
        setState(() {
          _lastError = e.toString();
          _loading = false;
        });
      }
    }
  }
}
