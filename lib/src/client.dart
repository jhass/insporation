import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Client {
  static const _appauth = const MethodChannel("insporation/appauth");
  static const _scopes = "openid profile public:read private:read contacts:read interactions";
  static final _linkHeaderPattern = RegExp(r'<([^>]+)>;\s*rel="([^"]+)"');

  final http.Client _client = http.Client();
  _Session _currentSession;
  _Host _currentHost;

  bool hasSession() => _currentSession?.diasporaId != null;

  String getCurrentUser() => _currentSession?.diasporaId;

  bool isAuthorized() => _currentSession.authorized;

  Future<void> switchToUser(String diasporaId) async {
    final parts = diasporaId.split("@"),
        user = parts[0], hostname = parts[1];

    _currentHost = await _loadHost(hostname);

    if (!_currentHost.registered) {
      await _registerClient(_currentHost);
    }

    _currentSession = await _loadSession(diasporaId);

    if (!_currentSession.authorized) {
      _currentSession.authState = await _authorize(_currentHost.authState, user);
      _currentSession.authorized = true;
    }

    await _persistCurrentSession();
  }

  Future<Page<Post>> fetchMainStream({String page}) =>
    _fetchPosts(_call("GET", "streams/main", page: page));

  Future<Page<Post>> fetchActivityStream({String page}) =>
    _fetchPosts(_call("GET", "streams/activity", page: page));

  Future<Page<Post>> fetchTagStream(String tag, {String page}) =>
    _fetchPosts(_call("GET", "search/posts", query: {'tag': tag}, page: page));

  Future<Page<Comment>> fetchComments(Post post, {String page}) async {
    final response = await _call("GET", "posts/${post.guid}/comments", page: page),
      comments = await compute(_parseCommentsJson, response.body);
    return _makePage(comments, response);
  }

  Future<void> likePost(Post post) async {
    try {
      await _call("POST", "posts/${post.guid}/likes");
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already liked, ignore
    }
  }

  Future<void> unlikePost(Post post) async {
    try {
      await _call("DELETE", "posts/${post.guid}/likes");
    } on ClientException catch (e) {
      if (e.code != 410) {
        throw e;
      }

      // already disliked, ignore
    }
  }

  Future<Page<Post>> _fetchPosts(Future<http.Response> request) async {
    final response = await request,
      posts = await compute(_parsePostsJson, {"body": response.body, "currentUser": getCurrentUser()});
    return _makePage(posts, response);
  }

  Future<http.Response> _call(String method, String endpoint, {Map<String, String> query = const {}, body, page}) async {
    final token = await _getAccessToken(),
      uri = _computeUri(endpoint, query: query, page: page),
      request = http.Request(method, uri);
    request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";

    if (body != null) {
      request.body = body;
    }

    final response = await _client.send(request).then(http.Response.fromStream);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw ClientException.fromResponse(response);
    }
  }

  Uri _computeUri(String endpoint, {Map<String, String> query, page}) {
    if (page != null) {
      return Uri.parse(page);
    } else {
      final newSegments = _currentHost.baseUri.pathSegments + endpoint.split(r'/');
      return _currentHost.baseUri.replace(pathSegments: const ['api', 'v1'] + newSegments, queryParameters: query);
    }
  }

  Future<_Host> _loadHost(String host) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final hostPref = "${host}_info";
    if (sharedPreferences.containsKey(hostPref)) {
      return _Host.fromJson(sharedPreferences.getString(hostPref));
    } else {
      return _Host.forUri(Uri.parse("https://$host"));
    }
  }

  Future<void> _persistHost(_Host host) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("${host.baseUri.host}_info", host.toJson());
  }

  Future<_Session> _loadSession(String diasporaId) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final sessionPref = "${diasporaId}_session";
    if (sharedPreferences.containsKey(sessionPref)) {
      return _Session.fromJson(sharedPreferences.getString(sessionPref));
    } else {
      return _Session.forUser(diasporaId);
    }
  }

  _persistCurrentSession() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    if (_currentSession.diasporaId != null) {
      sharedPreferences.setString("${_currentSession.diasporaId}_session", _currentSession.toJson());
    }
  }

  Future<void> _registerClient(_Host host) async {
    try {
      host.authState = await _appauth.invokeMethod("registerClient", <String, dynamic>{
        "url": host.baseUri.toString()
      });
      host.registered = true;
      await _persistHost(host);
    } on PlatformException catch (e) {
      throw "Failed to register client: ${e.message}";
    }
  }

  static Future<String> _authorize(String authState, String username) async {
    try {
      return await _appauth.invokeMethod("authorize", <String, dynamic>{
        "authState": authState,
        "username": username,
        "scopes": _scopes
      });
    } on PlatformException catch (e) {
      throw "Failed to authorize client: ${e.message}";
    }
  }

  Future<String> _getAccessToken() async {
    try {
      final Map<dynamic, dynamic> result = await _appauth.invokeMethod("getAccessToken", <String, dynamic>{
        "authState": _currentSession.authState
      });
      _currentSession.authState = result["authState"];

      if (result["accessToken"] != null) {
        return result["accessToken"];
      } else {
        throw "Failed to fetch access token: Got no token!";
      }
    } on PlatformException catch (e) {
      throw "Failed fetch access token: ${e.message}";
    }
  }

  Page<T> _makePage<T>(List<T> content, http.Response response) {
    if (response.headers["link"] == null) {
      return Page(content: content);
    }

    final links = Map.fromIterable(_linkHeaderPattern.allMatches(response.headers["link"]),
      key: (match) => match[2], value: (match) => match[1]);

    return Page(
      content: content,
      firstPage: links["first"],
      previousPage: links["previous"],
      nextPage: links["next"],
      lastPage: links["last"]
    );
  }

  static List<Post> _parsePostsJson(Map<String, String> arguments) {
    final json = arguments["body"];
    final currentUser = arguments["currentUser"];
    final List<Map<String, dynamic>> posts = jsonDecode(json).cast<Map<String, dynamic>>();
    return Post.fromList(posts, currentUser: currentUser);
  }

  static List<Comment> _parseCommentsJson(String json) {
    final List<Map<String, dynamic>> comments = jsonDecode(json).cast<Map<String, dynamic>>();
    return Comment.fromList(comments);
  }
}

class Page<T> {
  final List<T> content;
  final String firstPage;
  final String previousPage;
  final String nextPage;
  final String lastPage;

  Page({this.content, this.firstPage,  this.previousPage, this.nextPage, this.lastPage});
}

class ClientException implements Exception {
  final int code;
  final String message;
  final String requestPath;
  final String requestMethod;

  ClientException({@required this.code, @required this.message,
    @required this.requestPath, @required this.requestMethod});

  factory ClientException.fromResponse(http.Response response) {
    var message = response.reasonPhrase;
    if (response.contentLength > 0 && response.headers[HttpHeaders.contentTypeHeader].startsWith("application/json")) {
      message = jsonDecode(response.body)["body"];
    }
    return ClientException(
      code: response.statusCode,
      message: message,
      requestPath: response.request.url.path,
      requestMethod: response.request.method.toLowerCase()
    );
  }

  @override
  String toString() =>
    "Failed to $requestMethod $requestPath: $code - $message";
}

class _Host {
  final Uri baseUri;
  String authState;
  var registered = false;

  _Host({this.baseUri, this.authState, this.registered});

  _Host.forUri(this.baseUri);

  factory _Host.fromJson(String json) {
    final object = jsonDecode(json);
    return _Host(
        baseUri:  Uri.parse(object["baseUrl"]),
        authState: object["authState"],
        registered: object["registered"]
    );
  }

  String toJson() =>
     jsonEncode({
      "baseUrl": baseUri.toString(),
      "authState": authState,
      "registered": registered
    });
}

class _Session {
  final String diasporaId;
  String scopes;
  String authState;
  var _authorized = false;

  _Session({@required this.diasporaId, @required this.scopes, @required this.authState,
    @required authorized}) : _authorized = authorized;

  _Session.forUser(this.diasporaId);

  factory _Session.fromJson(String json) {
    final object = jsonDecode(json);
    return _Session(
        diasporaId: object["diasporaId"],
        scopes: object["scopes"],
        authState: object["authState"],
        authorized: object["authorized"]
    );
  }

  bool get authorized => _authorized && _normalizeScopes(Client._scopes) == _normalizeScopes(scopes);

  set authorized(authorized) {
    _authorized = authorized;
    if (_authorized) {
      scopes = Client._scopes;
    }
  }

  String toJson() =>
    jsonEncode({
      "diasporaId": diasporaId,
      "scopes": scopes,
      "authState": authState,
      "authorized": authorized});

  static String _normalizeScopes(String scopes) {
    if (scopes == null) {
      return null;
    }

    final splitted = scopes.split(" ");
    splitted.sort();
    return splitted.join(" ");
  }
}

class Person {
  final String diasporaId;
  final String name;
  final String avatar;

  Person({this.diasporaId, this.name, this.avatar});

  factory Person.from(Map<String, dynamic> object) {
    return Person(
        diasporaId: object["diaspora_id"],
        name: object["name"],
        avatar: object["avatar"]
    );
  }

  static List<Person> fromList(List<Map<String, dynamic>> objects) =>
    objects.map((object) => Person.from(object)).toList();
}

class Post {
  final String guid;
  final String body;
  final Person author;
  final bool public;
  final Post root;
  final List<Photo> photos;
  final Map<String, Person> mentionedPeople;
  final PostInteractions interactions;
  final DateTime createdAt;
  final bool ownPost;

  Post({this.guid, this.body, this.author, this.public, this.root, this.photos,
    this.mentionedPeople, this.interactions, this.createdAt, this.ownPost});

  factory Post.from(Map<String, dynamic> object, {String currentUser}) {
    final author = Person.from(object["author"]),
      root = object["root"] != null ? Post.from(object["root"]) : null;
    return Post(
      guid: object["guid"],
      body: object["body"],
      author: author,
      public: object["public"],
      root: root,
      photos: object["photos"] != null ? Photo.fromList(object["photos"].cast<Map<String, dynamic>>()) : null,
      mentionedPeople: object["mentioned_people"] != null ? Map.fromIterable(
        Person.fromList(object["mentioned_people"].cast<Map<String, dynamic>>()),
        key: (person) => person.diasporaId
      ) : null,
      interactions: PostInteractions.from(object["interaction_counters"], object["own_interaction_state"]),
      createdAt: DateTime.parse(object["created_at"]),
      ownPost: author.diasporaId == currentUser || (root != null && root.author.diasporaId == currentUser)
    );
  }

  static List<Post> fromList(List<Map<String, dynamic>> objects, {String currentUser}) =>
    objects.map((object) => Post.from(object, currentUser: currentUser)).toList();


  bool canReshare() => public && !ownPost && !interactions.reshared;
}

class PostInteractions {
  int comments;
  int reshares;
  int likes;
  bool liked;
  bool reshared;
  bool subscribed;

  PostInteractions({this.comments, this.reshares, this.likes, this.liked, this.reshared, this.subscribed});

  factory PostInteractions.from(Map<String, dynamic> counters, Map<String, dynamic> ownState) =>
    PostInteractions(
      comments: counters["comments"],
      reshares: counters["reshares"],
      likes: counters["likes"],
      liked: ownState["liked"],
      reshared: ownState["reshared"],
      subscribed: ownState["subscribed"]
    );
}

class Photo {
  final int width;
  final int height;
  final PhotoSizes sizes;

  Photo({this.width, this.height, this.sizes});

  factory Photo.from(Map<String, dynamic> object) =>
    Photo(
      width: object["dimensions"]["width"],
      height: object["dimensions"]["height"],
      sizes: PhotoSizes.from(object["sizes"])
    );

  static List<Photo> fromList(List<Map<String, dynamic>> objects) =>
    objects.map((object) => Photo.from(object)).toList();
}

class PhotoSizes {
  final String raw;
  final String large;
  final String medium;
  final String small;

  PhotoSizes({this.raw, this.large, this.medium, this.small});

  factory PhotoSizes.from(Map<String, dynamic> object) =>
    PhotoSizes(
      raw: object["raw"],
      large: object["large"],
      medium: object["medium"],
      small: object["small"]
    );
}

class Comment {
  final String body;
  final Person author;
  final DateTime createdAt;

  Comment({this.body, this.author, this.createdAt});

  factory Comment.from(Map<String, dynamic> object) =>
    Comment(
      body: object["body"],
      author: Person.from(object["author"]),
      createdAt: DateTime.parse(object["created_at"])
    );

  static fromList(List<Map<String, dynamic>> objects) =>
    objects.map((object) => Comment.from(object)).toList();
}
