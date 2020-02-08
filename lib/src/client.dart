import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

typedef AuthorizationSuccess = void Function();
typedef AuthorizationFailed = void Function(String);
typedef AuthorizingUser = Future<String> Function();

class Client {
  static const _appauth = const MethodChannel("insporation/appauth");
  static const _scopes = "openid profile public:read private:read contacts:read public:modify private:modify interactions";
  static final _linkHeaderPattern = RegExp(r'<([^>]+)>;\s*rel="([^"]+)"');

  final http.Client _client = http.Client();
  _Session _currentSession;
  _Host _currentHost;
  Profile _currentUser;

  void listenToAuthorizationResponse({
    @required AuthorizingUser authorizingUser,
    AuthorizationSuccess success,
    AuthorizationFailed failed}) {
    _appauth.setMethodCallHandler((call) async {
      switch (call.method) {
        case "fetchAuthState":
          final id = await authorizingUser(),
            session = id != null ? await _loadSession(id) : null;
          return session?.authState ?? _currentSession?.authState ?? _currentHost?.authState;
        case "authorizationSuccess":
          final id = await authorizingUser();
          _currentSession = id != null ? await _loadSession(id) : _currentSession;
          _currentSession.authState = call.arguments;
          _currentSession.authorized = true;
          await _persistCurrentSession();

          if (success != null) {
            success();
          }
          break;
        case "authorizationFailed":
          if (failed != null) {
            failed(call.arguments);
          }
          break;
      }

      return null;
    });
  }

  void stopListeningToAuthorizationResponse() {
    _appauth.setMethodCallHandler(null);
  }

  bool get hasSession => _currentSession?.diasporaId != null;

  String get currentUserId => _currentSession?.diasporaId;

  bool get authorized => _currentSession.authorized;

  Future<Profile> get currentUser async {
    if (_currentUser != null && _currentUser.person.diasporaId == currentUserId) {
      return _currentUser;
    }

    final response = await _call("GET", "user");
    return Profile.from(jsonDecode(response.body));
  }

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

  Future<Post> resharePost(Post post) async {
    try {
      final response = await _call("POST", "posts/${post.guid}/reshares");
      return Post.from(jsonDecode(response.body));
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already reshared, ignore
    }

    return null;
  }

  Future<void> vote(Post post, PollAnswer answer) async {
    try {
      await _call("POST", "posts/${post.guid}/vote", body: {"poll_answer": answer.id});
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already voted here, ignore
    }
  }

  Future<void> subscribeToPost(Post post) async {
    try {
      await _call("POST", "posts/${post.guid}/subscribe");
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already subscribed, ignore
    }
  }

  Future<void> unsubscribeFromPost(Post post) async {
    try {
      await _call("POST", "posts/${post.guid}/mute");
    } on ClientException catch (e) {
      if (e.code != 410) {
        throw e;
      }

      // not subscribed already, ignore
    }
  }

  Future<void> reportPost(Post post, String reason) async {
    try {
      await _call("POST", "posts/${post.guid}/report", body: {"reason": reason});
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already reported, ignore
    }
  }

  Future<void> deletePost(Post post) async {
    try {
      await _call("DELETE", "posts/${post.guid}");
    } on ClientException catch (e) {
      if (e.code != 404) {
        throw e;
      }

      // already deleted, ignore
    }
  }

  Future<void> hidePost(Post post) async {
    try {
      await _call("POST", "posts/${post.guid}/hide", body: {"hide": true});
    } on ClientException catch (e) {
      if (e.code != 409) {
        throw e;
      }

      // already hidden, ignore
    }
  }

  Future<Page<Post>> _fetchPosts(Future<http.Response> request) async {
    final response = await request,
      posts = await compute(_parsePostsJson, {"body": response.body, "currentUser": currentUserId});
    return _makePage(posts, response);
  }

  Future<http.Response> _call(String method, String endpoint, {Map<String, String> query = const {}, body, page}) async {
    final token = await _getAccessToken(),
      uri = _computeUri(endpoint, query: query, page: page),
      request = http.Request(method, uri);
    request.headers[HttpHeaders.authorizationHeader] = "Bearer $token";

    if (body != null) {
      request.headers[HttpHeaders.contentTypeHeader] = "application/json; charset=utf-8";
      request.body = jsonEncode(body);
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
      if (e.code == "concurrent_request") {
        // probably returning after dieing in the background, ignore
        return authState;
      } else {
        throw "Failed to authorize client: ${e.message}";
      }
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
      // our session is probably not worth anything anymore, destroy it
      _currentSession.authorized = false;
      throw "Failed to fetch access token: ${e.message}";
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
      message = jsonDecode(response.body)["message"];
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

  bool get authorized => _authorized && authState != null && _normalizeScopes(Client._scopes) == _normalizeScopes(scopes);

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

  Person({@required this.diasporaId, @required this.name, @required this.avatar});

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

class Profile {
  final Person person;
  final PhotoSizes avatar;
  final List<String> tags;

  Profile({@required this.person, @required this.avatar, @required this.tags});

  factory Profile.from(Map<String, dynamic> object) {
    final PhotoSizes avatar = PhotoSizes.from(object["avatar"] ?? {});
    return Profile(
      person: Person(
        diasporaId: object["diaspora_id"],
        name: object["name"],
        avatar: avatar.medium
      ),
      avatar: avatar,
      tags: object["tags"].cast<String>().toList()
    );
  }
}

enum PostType { status, reshare }

class Post {
  static const _typeMap = {"StatusMessage": PostType.status, "Reshare": PostType.reshare};

  final String guid;
  final PostType type;
  final String body;
  final Person author;
  final bool public;
  final bool nsfw;
  final Post root;
  final List<Photo> photos;
  final Poll poll;
  final Map<String, Person> mentionedPeople;
  final PostInteractions interactions;
  final OEmbed oEmbed;
  final OpenGraphObject openGraphObject;
  final DateTime createdAt;
  final bool ownPost;
  final bool mock;

  Post({@required this.guid, @required this.type, @required this.body, @required this.author,
    @required this.public, @required this.nsfw, @required this.root, @required this.photos,
    @required this.poll, @required this.mentionedPeople, @required this.interactions, @required this.oEmbed,
    @required this.openGraphObject, @required this.createdAt, @required this.ownPost, this.mock});

  factory Post.from(Map<String, dynamic> object, {String currentUser}) {
    final author = Person.from(object["author"]),
      root = object["root"] != null ? Post.from(object["root"]) : null;
    return Post(
      guid: object["guid"],
      type: _typeMap[object["post_type"]],
      body: object["body"],
      author: author,
      public: object["public"],
      nsfw: object["nsfw"],
      root: root,
      photos: object["photos"] != null ? Photo.fromList(object["photos"].cast<Map<String, dynamic>>()) : null,
      poll: object["poll"] != null ? Poll.from(object["poll"]) : null,
      mentionedPeople: object["mentioned_people"] != null ? Map.fromIterable(
        Person.fromList(object["mentioned_people"].cast<Map<String, dynamic>>()),
        key: (person) => person.diasporaId
      ) : null,
      interactions: PostInteractions.from(object["interaction_counters"], object["own_interaction_state"]),
      openGraphObject: object["open_graph_object"] != null ? OpenGraphObject.from(object["open_graph_object"]) : null,
      oEmbed: object["oembed"] != null ? OEmbed.from(object["oembed"]) : null,
      createdAt: DateTime.parse(object["created_at"]),
      ownPost: author.diasporaId == currentUser || (root != null && root.author.diasporaId == currentUser),
      mock: false
    );
  }

  static List<Post> fromList(List<Map<String, dynamic>> objects, {String currentUser}) =>
    objects.map((object) => Post.from(object, currentUser: currentUser)).toList();

  bool get reshareOfDeleted => type == PostType.reshare && root == null;

  bool get canReshare => !mock && public && !ownPost && !interactions.reshared;

  bool get canLike => !mock;

  bool get canComment => !mock;

  Post mockReshare(Person author) =>
    Post(
      guid: null,
      type: PostType.reshare,
      body: body,
      author: author,
      public: public,
      nsfw: nsfw,
      root: this,
      photos: photos,
      poll: poll,
      mentionedPeople: mentionedPeople,
      interactions: PostInteractions(subscribed: true),
      oEmbed: oEmbed,
      openGraphObject: openGraphObject,
      createdAt: DateTime.now(),
      ownPost: true,
      mock: true
    );
}

class PostInteractions {
  int comments;
  int reshares;
  int likes;
  bool liked;
  bool reshared;
  bool subscribed;
  bool reported;

  PostInteractions({this.comments = 0, this.reshares = 0, this.likes = 0,
    this.liked = false, this.reshared = false, this.subscribed = false, this.reported = false});

  factory PostInteractions.from(Map<String, dynamic> counters, Map<String, dynamic> ownState) =>
    PostInteractions(
      comments: counters["comments"],
      reshares: counters["reshares"],
      likes: counters["likes"],
      liked: ownState["liked"],
      reshared: ownState["reshared"],
      subscribed: ownState["subscribed"],
      reported: false // TODO ownState["reported"]
    );
}

abstract class OEmbed {
  final String provider;
  final String author;
  final String url;

  OEmbed({@required this.provider, @required this.author, @required this.url});

  factory OEmbed.from(Map<String, dynamic> object) {
    final provider = object["provider_name"];
    if (provider == "YouTube") {
      return YoutubeOEmbed.from(object);
    } else if (provider == "Twitter") {
      return TwitterOEmbed.from(object);
    } else {
      return null;
    }
  }
}

abstract class ThumbnailOEmbed extends OEmbed {
  final String thumbnail;
  final String title;

  ThumbnailOEmbed({@required String provider, @required String author,
    @required String url, @required this.thumbnail, @required this.title}) : super(provider: provider, author: author, url: url);
}

abstract class HtmlTextOEmbed extends OEmbed {
  final String html;

  HtmlTextOEmbed({@required String provider, @required String author,
    @required String url, @required this.html}) : super(provider: provider, author: author, url: url);
}

class YoutubeOEmbed extends ThumbnailOEmbed {
  static RegExp _embedUrlPattern = RegExp(r'https://www.youtube.com/embed/([a-zA-Z0-9]+)');
  static String _urlTemplate = "https://www.youtube.com/watch?v=ID";

  YoutubeOEmbed({@required String provider, @required String author, @required String title,
    @required String thumbnail, @required String url}) : super(provider: provider, author: author,
    title: title, thumbnail: thumbnail, url: url);

  factory YoutubeOEmbed.from(Map<String, dynamic> object) {
    final id = _embedUrlPattern.allMatches(object["html"]).first.group(1);
    return YoutubeOEmbed(
      provider: object["provider_name"],
      author: object["author_name"],
      title: object["title"],
      thumbnail: object["thumbnail_url"],
      url: _urlTemplate.replaceFirst("ID", id)
    );
  }
}

class TwitterOEmbed extends HtmlTextOEmbed {
  static RegExp _scriptTagPattern = RegExp(r'<script [^>]+></script>');

  TwitterOEmbed({@required String provider, @required String author, @required String html,
    @required String url}) : super(provider: provider, author: author,
    html: html, url: url);

  factory TwitterOEmbed.from(Map<String, dynamic> object) {
    String html = object["html"];
    html = html.replaceAll(_scriptTagPattern, '');

    return TwitterOEmbed(
      provider: object["provider_name"],
      author: object["author_name"],
      html: html,
      url: object["url"]
    );
  }
}

class OpenGraphObject {
  final String url;
  final String title;
  final String image;
  final String description;

  OpenGraphObject({@required this.url, @required this.title, @required this.image, this.description});

  factory OpenGraphObject.from(Map<String, dynamic> object) =>
    OpenGraphObject(
      url: object["url"],
      title: object["title"],
      image: object["image"],
      description: object["description"]
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

class Poll {
  final String question;
  bool alreadyParticipated;
  int participationCount;
  List<PollAnswer> answers;

  Poll({@required this.question, @required this.alreadyParticipated, @required this.participationCount,
    @required this.answers});

  factory Poll.from(Map<String, dynamic> object) =>
    Poll(
      question: object["question"],
      alreadyParticipated: object["already_participated"],
      participationCount: object["participation_count"],
      answers: PollAnswer.fromList(object["poll_answers"].cast<Map<String, dynamic>>())
    );
}

class PollAnswer {
  final int id;
  final String answer;
  bool own;
  int voteCount;

  PollAnswer({@required this.id, @required this.answer, @required this.own, @required this.voteCount});

  factory PollAnswer.from(Map<String, dynamic> object) =>
    PollAnswer(
      id: object["id"],
      answer: object["answer"],
      own: object["own_answer"],
      voteCount: object["vote_count"]
    );

  static List<PollAnswer> fromList(List<Map<String, dynamic>> objects) =>
    objects.map((object) => PollAnswer.from(object)).toList();
}

class Comment {
  final String body;
  final Person author;
  final Map<String, Person> mentionedPeople;
  final DateTime createdAt;

  Comment({@required this.body, @required this.author, @required this.mentionedPeople, @required this.createdAt});

  factory Comment.from(Map<String, dynamic> object) =>
    Comment(
      body: object["body"],
      author: Person.from(object["author"]),
      mentionedPeople: object["mentioned_people"] != null ? Map.fromIterable(
        Person.fromList(object["mentioned_people"].cast<Map<String, dynamic>>()),
        key: (person) => person.diasporaId
      ) : null,
      createdAt: DateTime.parse(object["created_at"])
    );

  static List<Comment> fromList(List<Map<String, dynamic>> objects) =>
    objects.map((object) => Comment.from(object)).toList();
}
