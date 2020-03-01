import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';
import 'package:quiver/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAuth {
  static const _scopes =
    "openid "
    "profile profile:read_private profile:modify "
    "public:read public:modify "
    "private:read private:modify "
    "contacts:read contacts:modify "
    "tags:read tags:modify "
    "interactions notifications conversations";
  final _channel = MethodChannel("insporation/appauth");
  final _events = EventChannel("insporation/appauth_authorization_events");
  final _store = _SessionStore();
  Stream<AuthorizationEvent> _newAuthorizations;
  Session _currentSession;

  AppAuth() {
    _channel.setMethodCallHandler(_dispatch);
    _listenToNewAuthorizations();
  }

  Future<void> switchToUser(String userId) async {
    if (_currentSession?.userId == userId) {
      debugPrint("Switch user ignored, already current user: $userId");
      return;
    }

    debugPrint("Switched to user $userId");
    _currentSession = await _store.fetchSession(userId);
    await _store.rememberAsCurrentSession(_currentSession);
    debugPrint("Stored $userId's session as current one");
  }

  Future<void> restoreSession() async {
    if (_currentSession != null) {
      debugPrint("Already got a session for $currentUserId, ignoring restore request");
      return;
    }

    _currentSession = await _store.fetchCurrentSession();
    debugPrint(_currentSession != null ? "Restored current session for $currentUserId" : "No session to restore found");
  }

  Future<void> forgetSession() async {
    _currentSession = null;
    await _store.forgetCurrentSession();
    debugPrint("Forgot current session, if any");
  }

  bool get hasSession => _currentSession?.state != null;

  String get currentUserId => _currentSession?.userId;

  Uri get currentBaseUri => currentUserId != null ? Uri(scheme: "https", host: _store.hostForUser(currentUserId)) : null;

  Stream<AuthorizationEvent> get newAuthorizations {
    if (_newAuthorizations == null) {
      _newAuthorizations = _events.receiveBroadcastStream()
        .map((event) => AuthorizationEvent.fromMap(event.cast<String, dynamic>()))
        .where((event) => event.error != null || event.session != _currentSession)
        .asBroadcastStream();
    }

    return _newAuthorizations;
  }

  Future<String> get accessToken async {
    assert(_currentSession != null, "Don't try to fetch an access token without setting a user first!");

    if (_normalizeScopes(_currentSession.scopes) != _normalizeScopes(_scopes)) {
      // If scopes changed, invalidate state so we trigger a new authorization
      _currentSession.state = null;
      debugPrint("Destroyed current authorization, scopes changed");
    }

    try {
      debugPrint("Fetching access token for $currentUserId");

      final tokens = await _channel.invokeMapMethod("getAccessToken", {"session": _currentSession.toMap()});
      assert(tokens["accessToken"] != null, "Platform implementation failed to return an access token");

      // Update currenwithCont session in case it was refreshed or authorized, so we hand off the right state to the next token request
      _currentSession = await _store.fetchSession(_currentSession.userId);
      assert(hasSession, "We should have some session state after we got an access token");

      return tokens["accessToken"];
    } on PlatformException catch (e) {
      if (e.message?.toLowerCase()?.contains("network") == true) {
        throw e.message; // probably bad network
      }

      // our session is probably not worth anything anymore, destroy it
      await destroySession("Failed to fetch access token: ${e.message}");
    }
  }

  Future<void> destroySession(String message) async {
    if (_currentSession?.state != null) {
      _currentSession.state = null;
      await _store.storeSession(_currentSession);
      throw InvalidSessionError(message);
    }
  }

  Future<dynamic> _dispatch(MethodCall call) {
    switch (call.method) {
      case "fetchRegistration":
        if (call.arguments is String) {
          final String userId = call.arguments;
          debugPrint("Providing registration for $userId");
          return _store.fetchRegistration(userId).then((registration) => registration.toMap());
        }
        break;
      case "storeRegistration":
        if (call.arguments is Map) {
          final registration = Registration.fromMap(call.arguments.cast<String, dynamic>());
          debugPrint("Storing registration for ${registration.host}, state present: ${registration.state != null}");
          return _store.storeRegistration(registration);
        }
        break;
      case "storeSession":
        if (call.arguments is Map) {
          final session = Session.fromMap(call.arguments.cast<String, dynamic>());
          debugPrint("Storing session for ${session.userId}, state present: ${session.state != null}");
          return _store.storeSession(session);
        }
        break;
    }

    debugPrint("Invalid platform call ${call.method}");
    throw MissingPluginException();
  }

  void _listenToNewAuthorizations() {
    newAuthorizations.where((event) => event.session != null).forEach((event) {
      _currentSession = event.session;
      debugPrint("Updated session to $currentUserId from authorization event");
    });
  }

  static String _normalizeScopes(String scopes) {
    if (scopes == null) {
      return null;
    }

    final splitted = scopes.split(" ");
    splitted.sort();
    return splitted.join(" ");
  }

}

class _SessionStore {
  static const _registrationPrefix = "registration_";
  static const _sessionPrefix = "session_";
  static const _currentSessionKey = "current_session";

  Future<Registration> fetchRegistration(String userId) async {
    final host = hostForUser(userId),
      key = "$_registrationPrefix$host",
      prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return Registration.fromMap(jsonDecode(prefs.getString(key)));
    } else {
      return Registration(host: host);
    }
  }

  Future<void> storeRegistration(Registration registration) async {
    final key = "$_registrationPrefix${registration.host}",
      prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(registration.toMap()));
  }

  Future<Session> fetchSession(String userId) async {
    final key = "$_sessionPrefix$userId",
      prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      return Session.fromMap(jsonDecode(prefs.getString(key)));
    } else {
      return Session(userId: userId, scopes: AppAuth._scopes);
    }
  }

  Future<void> storeSession(Session session) async {
    final key = "$_sessionPrefix${session.userId}",
      prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(session.toMap()));
  }

  Future<Session> fetchCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_currentSessionKey)) {
      return Session.fromMap(jsonDecode(prefs.getString(prefs.getString(_currentSessionKey))));
    } else {
      return null;
    }
  }

  Future<void> rememberAsCurrentSession(Session session) async {
    final prefs = await SharedPreferences.getInstance(),
      key = "$_sessionPrefix${session.userId}";
    await storeSession(session);
    await prefs.setString(_currentSessionKey, key);
  }

  Future<void> forgetCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_currentSessionKey);
  }

  String hostForUser(String userId) => userId.split('@').last;
}

class Registration {
  final String host;
  final String state;

  Registration({@required this.host, this.state});

  factory Registration.fromMap(Map<String, dynamic> data) => Registration(
    host: data["host"],
    state: data["state"]
  );

  Map<String, dynamic> toMap() => {
    "host": host,
    "state": state
  };
}

class Session {
  final String userId;
  final String scopes;
  String state;

  Session({@required this.userId, @required this.scopes, this.state});

  factory Session.fromMap(Map<String, dynamic> data) => Session(
    userId: data["userId"],
    scopes: data["scopes"],
    state: data["state"]
  );

  Map<String, dynamic> toMap() => {
    "userId": userId,
    "scopes": scopes,
    "state": state
  };

  bool operator ==(other) => other is Session && other.userId == userId && other.scopes == scopes && other.state == state;

  @override
  int get hashCode => hash3(userId, scopes, state);
}

class AuthorizationEvent {
  final Session session;
  final String error;

  AuthorizationEvent(this.session, this.error);

  factory AuthorizationEvent.fromMap(Map<String, dynamic> data) => AuthorizationEvent(
    data["session"] != null ? Session.fromMap(data["session"].cast<Map, dynamic>()) : null,
    data["error"]
  );
}

class InvalidSessionError implements Exception {
  InvalidSessionError(this.message);

  final String message;

  @override
  String toString() => "Invalid session: $message";
}