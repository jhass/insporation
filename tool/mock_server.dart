import 'dart:async';
import 'dart:convert';
import 'dart:io';

const demoUserId = 'demo@mock.local';
const defaultMockPort = 8787;

class DemoMockServer {
  DemoMockServer({this.host = '127.0.0.1', this.port = defaultMockPort}) : _data = _DemoData();

  final String host;
  final int port;
  final _DemoData _data;
  HttpServer? _server;

  Future<Uri> start() async {
    _server ??= await HttpServer.bind(host, port);
    _server!.listen(_handleRequest);
    return Uri.parse('http://$host:${_server!.port}');
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    if (server != null) {
      await server.close(force: true);
    }
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final path = request.uri.path;
      if (path == '/health') {
        _json(request.response, 200, {'status': 'ok'});
        return;
      }

      if (!path.startsWith('/api/v1/')) {
        _json(request.response, 404, {'message': 'Unknown path'});
        return;
      }

      final endpoint = path.substring('/api/v1/'.length);
      final method = request.method;

      if (endpoint == 'user' && method == 'GET') {
        _json(request.response, 200, _data.currentUserProfile());
        return;
      }

      if (endpoint == 'user' && method == 'PATCH') {
        final body = await _readJson(request);
        _json(request.response, 200, _data.updateCurrentUserProfile(body));
        return;
      }

      if (endpoint == 'aspects' && method == 'GET') {
        _json(request.response, 200, _data.aspects);
        return;
      }

      if (endpoint == 'aspects' && method == 'POST') {
        final body = await _readJson(request);
        _json(request.response, 200, _data.createAspect(body['name']?.toString() ?? 'Untitled'));
        return;
      }

      if (endpoint.startsWith('aspects/')) {
        if (await _handleAspects(request, endpoint, method)) {
          return;
        }
      }

      if (endpoint.startsWith('streams/')) {
        _json(request.response, 200, _data.streamFor(endpoint.substring('streams/'.length)));
        return;
      }

      if (endpoint == 'search/posts' && method == 'GET') {
        final tag = request.uri.queryParameters['tag'] ?? '';
        _json(request.response, 200, _data.searchPostsByTag(tag));
        return;
      }

      if (endpoint.startsWith('users/') && endpoint.endsWith('/posts') && method == 'GET') {
        final guid = endpoint.split('/')[1];
        _json(request.response, 200, _data.streamForUser(guid));
        return;
      }

      if (endpoint.startsWith('users/') && method == 'GET') {
        final guid = endpoint.split('/')[1];
        _json(request.response, 200, _data.profileByGuid(guid));
        return;
      }

      if (endpoint.startsWith('users/') && endpoint.endsWith('/block')) {
        final guid = endpoint.split('/')[1];
        final blocked = method == 'POST';
        _data.setBlocked(guid, blocked);
        _json(request.response, 200, {'status': blocked ? 'blocked' : 'unblocked'});
        return;
      }

      if (endpoint == 'posts' && method == 'POST') {
        final body = await _readJson(request);
        _json(request.response, 200, _data.createPost(body));
        return;
      }

      if (endpoint.startsWith('posts/')) {
        if (await _handlePosts(request, endpoint, method)) {
          return;
        }
      }

      if (endpoint == 'notifications' && method == 'GET') {
        final unreadOnly = request.uri.queryParameters['only_unread'] == 'true';
        _json(request.response, 200, _data.notifications(unreadOnly: unreadOnly));
        return;
      }

      if (endpoint.startsWith('notifications/') && method == 'PATCH') {
        final guid = endpoint.split('/')[1];
        final body = await _readJson(request);
        _data.setNotificationRead(guid, body['read'] == true);
        _json(request.response, 200, {'status': 'updated'});
        return;
      }

      if (endpoint == 'conversations' && method == 'GET') {
        final unreadOnly = request.uri.queryParameters['only_unread'] == 'true';
        _json(request.response, 200, _data.conversations(unreadOnly: unreadOnly));
        return;
      }

      if (endpoint == 'conversations' && method == 'POST') {
        final body = await _readJson(request);
        _json(request.response, 200, _data.createConversation(body));
        return;
      }

      if (endpoint.startsWith('conversations/')) {
        if (await _handleConversations(request, endpoint, method)) {
          return;
        }
      }

      if (endpoint == 'search/users' && method == 'GET') {
        _json(request.response, 200, _data.searchUsers(request.uri.queryParameters));
        return;
      }

      if (endpoint == 'search/tags' && method == 'GET') {
        _json(request.response, 200, _data.searchTags(request.uri.queryParameters['query'] ?? ''));
        return;
      }

      if (endpoint == 'tag_followings' && method == 'GET') {
        _json(request.response, 200, _data.followedTags);
        return;
      }

      if (endpoint == 'tag_followings' && method == 'POST') {
        final body = await _readJson(request);
        _data.followTag(body['name']?.toString() ?? '');
        _json(request.response, 200, {'status': 'followed'});
        return;
      }

      if (endpoint.startsWith('tag_followings/') && method == 'DELETE') {
        _data.unfollowTag(endpoint.substring('tag_followings/'.length));
        _json(request.response, 200, {'status': 'unfollowed'});
        return;
      }

      if (endpoint == 'photos' && method == 'POST') {
        _json(request.response, 200, _data.createUploadedPhoto());
        return;
      }

      _json(request.response, 404, {'message': 'Unhandled endpoint: $method $endpoint'});
    } catch (error, stack) {
      stderr.writeln('Mock server failure: $error\n$stack');
      _json(request.response, 500, {'message': 'Internal mock server error'});
    }
  }

  Future<bool> _handleAspects(HttpRequest request, String endpoint, String method) async {
    final parts = endpoint.split('/');
    if (parts.length < 2) {
      return false;
    }

    final aspectId = int.tryParse(parts[1]);
    if (aspectId == null) {
      return false;
    }

    if (parts.length == 2 && method == 'PATCH') {
      final body = await _readJson(request);
      _json(request.response, 200, _data.renameAspect(aspectId, body['name']?.toString() ?? 'Contacts'));
      return true;
    }

    if (parts.length == 2 && method == 'DELETE') {
      _data.deleteAspect(aspectId);
      _json(request.response, 200, {'status': 'deleted'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'contacts' && method == 'GET') {
      _json(request.response, 200, _data.contactsForAspect(aspectId));
      return true;
    }

    if (parts.length == 3 && parts[2] == 'contacts' && method == 'POST') {
      final body = await _readJson(request);
      _data.addContactToAspect(aspectId, body['person_guid']?.toString() ?? '');
      _json(request.response, 200, {'status': 'added'});
      return true;
    }

    if (parts.length == 4 && parts[2] == 'contacts' && method == 'DELETE') {
      _data.removeContactFromAspect(aspectId, parts[3]);
      _json(request.response, 200, {'status': 'removed'});
      return true;
    }

    return false;
  }

  Future<bool> _handlePosts(HttpRequest request, String endpoint, String method) async {
    final parts = endpoint.split('/');
    if (parts.length < 2) {
      return false;
    }

    final postGuid = parts[1];

    if (parts.length == 2 && method == 'GET') {
      _json(request.response, 200, _data.postByGuid(postGuid));
      return true;
    }

    if (parts.length == 2 && method == 'DELETE') {
      _data.deletePost(postGuid);
      _json(request.response, 200, {'status': 'deleted'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'comments' && method == 'GET') {
      _json(request.response, 200, _data.commentsForPost(postGuid));
      return true;
    }

    if (parts.length == 3 && parts[2] == 'comments' && method == 'POST') {
      final body = await _readJson(request);
      _json(request.response, 200, _data.createComment(postGuid, body['body']?.toString() ?? 'Nice post!'));
      return true;
    }

    if (parts.length == 4 && parts[2] == 'comments' && method == 'DELETE') {
      _data.deleteComment(postGuid, parts[3]);
      _json(request.response, 200, {'status': 'deleted'});
      return true;
    }

    if (parts.length == 5 && parts[2] == 'comments' && parts[4] == 'report' && method == 'POST') {
      _json(request.response, 200, {'status': 'reported'});
      return true;
    }

    if (parts.length == 5 && parts[2] == 'comments' && parts[4] == 'likes') {
      final liked = method == 'POST';
      _data.setCommentLike(postGuid, parts[3], liked);
      _json(request.response, 200, {'status': liked ? 'liked' : 'unliked'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'likes') {
      if (method == 'GET') {
        _json(request.response, 200, _data.likesForPost(postGuid));
      } else {
        _data.setPostLike(postGuid, method == 'POST');
        _json(request.response, 200, {'status': method == 'POST' ? 'liked' : 'unliked'});
      }
      return true;
    }

    if (parts.length == 3 && parts[2] == 'reshares') {
      if (method == 'GET') {
        _json(request.response, 200, _data.resharesForPost(postGuid));
      } else {
        _json(request.response, 200, _data.reshare(postGuid));
      }
      return true;
    }

    if (parts.length == 3 && parts[2] == 'vote' && method == 'POST') {
      final body = await _readJson(request);
      _data.vote(postGuid, body['poll_answer']);
      _json(request.response, 200, {'status': 'voted'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'subscribe' && method == 'POST') {
      _data.setSubscription(postGuid, true);
      _json(request.response, 200, {'status': 'subscribed'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'mute' && method == 'POST') {
      _data.setSubscription(postGuid, false);
      _json(request.response, 200, {'status': 'muted'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'report' && method == 'POST') {
      _data.setPostReported(postGuid, true);
      _json(request.response, 200, {'status': 'reported'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'hide' && method == 'POST') {
      _json(request.response, 200, {'status': 'hidden'});
      return true;
    }

    return false;
  }

  Future<bool> _handleConversations(HttpRequest request, String endpoint, String method) async {
    final parts = endpoint.split('/');
    if (parts.length < 2) {
      return false;
    }

    final guid = parts[1];

    if (parts.length == 2 && method == 'PATCH') {
      final body = await _readJson(request);
      _data.setConversationRead(guid, body['read'] == true);
      _json(request.response, 200, {'status': 'updated'});
      return true;
    }

    if (parts.length == 2 && method == 'DELETE') {
      _data.hideConversation(guid);
      _json(request.response, 200, {'status': 'deleted'});
      return true;
    }

    if (parts.length == 3 && parts[2] == 'messages' && method == 'GET') {
      _json(request.response, 200, _data.messagesForConversation(guid));
      return true;
    }

    if (parts.length == 3 && parts[2] == 'messages' && method == 'POST') {
      final body = await _readJson(request);
      _json(request.response, 200, _data.createMessage(guid, body['body']?.toString() ?? 'Thanks!'));
      return true;
    }

    return false;
  }

  Future<Map<String, dynamic>> _readJson(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  void _json(HttpResponse response, int statusCode, Object payload) {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(payload));
    response.close();
  }
}

class _DemoData {
  _DemoData() {
    _seed();
  }

  static const _demoAvatar = 'https://picsum.photos/id/1005/480/480';

  final List<Map<String, dynamic>> _people = [];
  final List<Map<String, dynamic>> _aspects = [];
  final Map<int, Set<String>> _aspectMemberships = <int, Set<String>>{};
  final List<Map<String, dynamic>> _posts = [];
  final Map<String, List<Map<String, dynamic>>> _comments = {};
  final List<Map<String, dynamic>> _notifications = [];
  final List<Map<String, dynamic>> _conversations = [];
  final Map<String, List<Map<String, dynamic>>> _messages = {};
  final List<String> _followedTags = ['travel', 'photography', 'coffee', 'weekend'];

  int _aspectId = 20;
  int _postId = 500;
  int _commentId = 800;
  int _conversationId = 30;
  int _messageId = 90;

  List<Map<String, dynamic>> get aspects => List<Map<String, dynamic>>.from(_aspects);
  List<String> get followedTags => List<String>.from(_followedTags);

  Map<String, dynamic> currentUserProfile() => profileByGuid('person-demo');

  Map<String, dynamic> updateCurrentUserProfile(Map<String, dynamic> body) {
    final person = _people.firstWhere((p) => p['guid'] == 'person-demo');
    person['name'] = body['name']?.toString().trim().isNotEmpty == true ? body['name'] : person['name'];

    return {
      ...currentUserProfile(),
      'bio': body['bio'] ?? currentUserProfile()['bio'],
      'gender': body['gender'] ?? currentUserProfile()['gender'],
      'location': body['location'] ?? currentUserProfile()['location'],
      'birthday': body['birthday'] ?? currentUserProfile()['birthday'],
      'nsfw': body['nsfw'] ?? false,
      'searchable': body['searchable'] ?? true,
      'show_profile_info': body['show_profile_info'] ?? true,
      'tags': (body['tags'] as List<dynamic>?)?.cast<String>() ?? currentUserProfile()['tags'],
    };
  }

  Map<String, dynamic> profileByGuid(String guid) {
    final person = _people.firstWhere((p) => p['guid'] == guid, orElse: () => _people.first);
    final aspectIds = _aspectMemberships.entries
        .where((entry) => entry.value.contains(guid))
        .map((entry) => entry.key)
        .toSet();

    return {
      'guid': person['guid'],
      'diaspora_id': person['diaspora_id'],
      'name': person['name'],
      'avatar': {
        'raw': person['avatar'],
        'large': person['avatar'],
        'medium': person['avatar'],
        'small': person['avatar'],
      },
      'bio': guid == 'person-demo'
          ? 'Traveler, mobile developer, and coffee enthusiast. Sharing notes from everyday life.'
          : 'Open source contributor who shares design notes and field photos.',
      'gender': guid == 'person-demo' ? 'non-binary' : 'female',
      'location': guid == 'person-demo' ? 'Berlin, Germany' : 'Lisbon, Portugal',
      'birthday': guid == 'person-demo' ? '1992-03-14' : '1989-09-21',
      'show_profile_info': true,
      'searchable': true,
      'nsfw': false,
      'blocked': false,
      'relationship': {
        'sharing': true,
        'receiving': true,
      },
      'tags': guid == 'person-demo'
          ? ['travel', 'community', 'coffee', 'weekend']
          : ['photography', 'mountains', 'ux'],
      'aspects': _aspects.where((aspect) => aspectIds.contains(aspect['id'])).toList(),
    };
  }

  List<Map<String, dynamic>> streamFor(String streamName) {
    switch (streamName) {
      case 'activity':
        return _posts.where((post) => (post['interaction_counters']['comments'] as int) > 0).toList();
      case 'mentions':
        return _posts.where((post) => (post['body'] as String).contains('@demo@mock.local')).toList();
      case 'tags':
        return _posts.where((post) => (post['body'] as String).contains('#morningwalk')).toList();
      case 'liked':
        return _posts.where((post) => post['own_interaction_state']['liked'] == true).toList();
      case 'commented':
        return _posts.where((post) => (post['interaction_counters']['comments'] as int) > 1).toList();
      case 'aspects':
      case 'main':
      default:
        return List<Map<String, dynamic>>.from(_posts);
    }
  }

  List<Map<String, dynamic>> searchPostsByTag(String tag) {
    final token = '#${tag.toLowerCase()}';
    return _posts.where((post) => (post['body'] as String).toLowerCase().contains(token)).toList();
  }

  List<Map<String, dynamic>> streamForUser(String guid) {
    return _posts.where((post) => post['author']['guid'] == guid).toList();
  }

  Map<String, dynamic> postByGuid(String guid) {
    return _posts.firstWhere((post) => post['guid'] == guid, orElse: () => _posts.first);
  }

  List<Map<String, dynamic>> commentsForPost(String postGuid) {
    return List<Map<String, dynamic>>.from(_comments[postGuid] ?? <Map<String, dynamic>>[]);
  }

  Map<String, dynamic> createPost(Map<String, dynamic> body) {
    final guid = 'post-${_postId++}';
    final poll = body['poll'] is Map<String, dynamic>
        ? {
            'question': body['poll']['question'] ?? 'Which caption works best?',
            'already_participated': false,
            'participation_count': 0,
        'poll_answers': ((body['poll']['poll_answers'] as List<dynamic>? ?? <dynamic>['Coffee and a walk', 'Stay in and read'])
                .asMap()
                .entries
                .map((entry) => {
                      'id': entry.key + 1,
                      'answer': entry.value.toString(),
                      'own_answer': false,
                      'vote_count': 0,
                    })
                .toList()),
          }
        : null;

    final post = {
      'guid': guid,
      'post_type': 'StatusMessage',
      'body': body['body']?.toString().trim().isNotEmpty == true
          ? body['body']
          : 'Caught the train just before the rain started. Little things like this make the day feel better. #dailylife',
      'author': _people.firstWhere((person) => person['guid'] == 'person-demo'),
      'public': body['public'] != false,
      'nsfw': false,
      'photos': <Map<String, dynamic>>[],
      'poll': poll,
      'mentioned_people': <Map<String, dynamic>>[],
      'interaction_counters': {
        'comments': 0,
        'reshares': 0,
        'likes': 0,
      },
      'own_interaction_state': {
        'liked': false,
        'reshared': false,
        'subscribed': true,
        'reported': false,
      },
      'open_graph_object': null,
      'location': body['location'] ?? {'address': 'Berlin, Germany', 'lat': 52.52, 'lng': 13.405},
      'oembed': null,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'root': null,
    };

    _posts.insert(0, post);
    _comments[guid] = <Map<String, dynamic>>[];
    return post;
  }

  void deletePost(String postGuid) {
    _posts.removeWhere((post) => post['guid'] == postGuid);
    _comments.remove(postGuid);
  }

  Map<String, dynamic> createComment(String postGuid, String body) {
    final comment = {
      'guid': 'comment-${_commentId++}',
      'body': body,
      'author': _people.firstWhere((person) => person['guid'] == 'person-demo'),
      'mentioned_people': <Map<String, dynamic>>[],
      'reported': false,
      'interactions': {
        'likes_count': 0,
        'liked': false,
      },
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    final comments = _comments.putIfAbsent(postGuid, () => <Map<String, dynamic>>[]);
    comments.add(comment);

    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    post['interaction_counters']['comments'] = comments.length;
    return comment;
  }

  void deleteComment(String postGuid, String commentGuid) {
    final comments = _comments[postGuid];
    if (comments == null) {
      return;
    }

    comments.removeWhere((comment) => comment['guid'] == commentGuid);
    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    post['interaction_counters']['comments'] = comments.length;
  }

  void setCommentLike(String postGuid, String commentGuid, bool liked) {
    final comments = _comments[postGuid];
    if (comments == null) {
      return;
    }

    final comment = comments.firstWhere((entry) => entry['guid'] == commentGuid, orElse: () => comments.first);
    final interactions = comment['interactions'] as Map<String, dynamic>;
    interactions['liked'] = liked;
    interactions['likes_count'] = liked ? 1 : 0;
  }

  List<Map<String, dynamic>> likesForPost(String postGuid) {
    return [
      {
        'guid': 'like-1',
        'author': _people.firstWhere((person) => person['guid'] == 'person-lina')
      },
      {
        'guid': 'like-2',
        'author': _people.firstWhere((person) => person['guid'] == 'person-joel')
      }
    ];
  }

  List<Map<String, dynamic>> resharesForPost(String postGuid) {
    return [
      {
        'guid': 'reshare-ref-1',
        'author': _people.firstWhere((person) => person['guid'] == 'person-maya')
      }
    ];
  }

  Map<String, dynamic> reshare(String postGuid) {
    final original = _posts.firstWhere((post) => post['guid'] == postGuid, orElse: () => _posts.first);
    final reshared = {
      ...original,
      'guid': 'post-${_postId++}',
      'post_type': 'Reshare',
      'body': original['body'],
      'author': _people.firstWhere((person) => person['guid'] == 'person-demo'),
      'root': original,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'own_interaction_state': {
        'liked': false,
        'reshared': true,
        'subscribed': true,
        'reported': false,
      }
    };

    _posts.insert(0, reshared);
    return reshared;
  }

  void vote(String postGuid, Object? answerId) {
    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    final poll = post['poll'];
    if (poll is! Map<String, dynamic>) {
      return;
    }

    poll['already_participated'] = true;
    poll['participation_count'] = (poll['participation_count'] as int) + 1;
    for (final entry in (poll['poll_answers'] as List<dynamic>)) {
      final answer = entry as Map<String, dynamic>;
      final own = answer['id'] == answerId;
      answer['own_answer'] = own;
      if (own) {
        answer['vote_count'] = (answer['vote_count'] as int) + 1;
      }
    }
  }

  void setSubscription(String postGuid, bool subscribed) {
    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    post['own_interaction_state']['subscribed'] = subscribed;
  }

  void setPostLike(String postGuid, bool liked) {
    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    final previous = post['own_interaction_state']['liked'] == true;
    post['own_interaction_state']['liked'] = liked;

    final likes = post['interaction_counters']['likes'] as int;
    if (liked && !previous) {
      post['interaction_counters']['likes'] = likes + 1;
    } else if (!liked && previous && likes > 0) {
      post['interaction_counters']['likes'] = likes - 1;
    }
  }

  void setPostReported(String postGuid, bool reported) {
    final post = _posts.firstWhere((entry) => entry['guid'] == postGuid, orElse: () => _posts.first);
    post['own_interaction_state']['reported'] = reported;
  }

  List<Map<String, dynamic>> notifications({required bool unreadOnly}) {
    if (!unreadOnly) {
      return List<Map<String, dynamic>>.from(_notifications);
    }

    return _notifications.where((item) => item['read'] != true).toList();
  }

  void setNotificationRead(String guid, bool read) {
    final notification = _notifications.firstWhere((item) => item['guid'] == guid, orElse: () => _notifications.first);
    notification['read'] = read;
  }

  List<Map<String, dynamic>> conversations({required bool unreadOnly}) {
    if (!unreadOnly) {
      return List<Map<String, dynamic>>.from(_conversations);
    }

    return _conversations.where((item) => item['read'] != true).toList();
  }

  Map<String, dynamic> createConversation(Map<String, dynamic> body) {
    final guid = 'conversation-${_conversationId++}';
    final recipients = (body['recipients'] as List<dynamic>? ?? <dynamic>[])
        .map((guid) => _people.firstWhere((person) => person['guid'] == guid, orElse: () => _people.first))
        .toList();

    final conversation = {
      'guid': guid,
      'subject': body['subject']?.toString().trim().isNotEmpty == true ? body['subject'] : 'Weekend plans',
      'read': false,
      'participants': <Map<String, dynamic>>[
        _people.firstWhere((person) => person['guid'] == 'person-demo'),
        ...recipients,
      ],
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    _conversations.insert(0, conversation);
    _messages[guid] = [
      {
        'guid': 'message-${_messageId++}',
        'body': body['body']?.toString() ?? 'Hey, are we still on for brunch on Sunday?',
        'author': _people.firstWhere((person) => person['guid'] == 'person-demo'),
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }
    ];

    return conversation;
  }

  void setConversationRead(String guid, bool read) {
    final conversation = _conversations.firstWhere((item) => item['guid'] == guid, orElse: () => _conversations.first);
    conversation['read'] = read;
  }

  void hideConversation(String guid) {
    _conversations.removeWhere((item) => item['guid'] == guid);
    _messages.remove(guid);
  }

  List<Map<String, dynamic>> messagesForConversation(String guid) {
    return List<Map<String, dynamic>>.from(_messages[guid] ?? <Map<String, dynamic>>[]);
  }

  Map<String, dynamic> createMessage(String guid, String body) {
    final message = {
      'guid': 'message-${_messageId++}',
      'body': body,
      'author': _people.firstWhere((person) => person['guid'] == 'person-demo'),
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    final thread = _messages.putIfAbsent(guid, () => <Map<String, dynamic>>[]);
    thread.add(message);
    return message;
  }

  List<Map<String, dynamic>> searchUsers(Map<String, String> query) {
    final byName = query['name_or_handle'];
    final byTag = query['tag'];

    if (byTag != null && byTag.isNotEmpty) {
      return _people.where((person) {
        final value = (person['name'] as String?)?.toLowerCase() ?? '';
        return value.contains(byTag.toLowerCase());
      }).toList();
    }

    if (byName != null && byName.isNotEmpty) {
      final token = byName.toLowerCase();
      return _people.where((person) {
        return (person['name'] as String).toLowerCase().contains(token) ||
            (person['diaspora_id'] as String).toLowerCase().contains(token);
      }).toList();
    }

    return List<Map<String, dynamic>>.from(_people);
  }

  List<String> searchTags(String query) {
    final tags = <String>{..._followedTags, 'appstoreshots', 'ux', 'design', 'photojournal'};
    if (query.trim().isEmpty) {
      return tags.toList();
    }

    return tags.where((tag) => tag.contains(query.toLowerCase())).toList();
  }

  void followTag(String tag) {
    if (tag.isEmpty) {
      return;
    }

    if (!_followedTags.contains(tag)) {
      _followedTags.add(tag);
    }
  }

  void unfollowTag(String tag) {
    _followedTags.remove(tag);
  }

  Map<String, dynamic> createUploadedPhoto() {
    return {
      'guid': 'photo-upload-${DateTime.now().millisecondsSinceEpoch}',
      'dimensions': {
        'width': 1600,
        'height': 1066,
      },
      'sizes': {
        'raw': 'https://picsum.photos/id/1024/2400/1600',
        'large': 'https://picsum.photos/id/1024/1600/1066',
        'medium': 'https://picsum.photos/id/1024/1200/800',
        'small': 'https://picsum.photos/id/1024/600/400',
      }
    };
  }

  Map<String, dynamic> createAspect(String name) {
    final aspect = {
      'id': _aspectId++,
      'name': name,
    };
    _aspects.add(aspect);
    _aspectMemberships[aspect['id'] as int] = <String>{};
    return aspect;
  }

  Map<String, dynamic> renameAspect(int aspectId, String name) {
    final aspect = _aspects.firstWhere((entry) => entry['id'] == aspectId, orElse: () => _aspects.first);
    aspect['name'] = name;
    return aspect;
  }

  void deleteAspect(int aspectId) {
    _aspects.removeWhere((aspect) => aspect['id'] == aspectId);
    _aspectMemberships.remove(aspectId);
  }

  void addContactToAspect(int aspectId, String personGuid) {
    final members = _aspectMemberships.putIfAbsent(aspectId, () => <String>{});
    members.add(personGuid);
  }

  void removeContactFromAspect(int aspectId, String personGuid) {
    _aspectMemberships[aspectId]?.remove(personGuid);
  }

  List<Map<String, dynamic>> contactsForAspect(int aspectId) {
    final members = _aspectMemberships[aspectId] ?? <String>{};
    return _people.where((person) => members.contains(person['guid'])).toList();
  }

  void setBlocked(String personGuid, bool blocked) {
    final notifications = _notifications.where((item) => item['target'] != null).toList();
    for (final item in notifications) {
      final target = item['target'] as Map<String, dynamic>?;
      if (target != null && target['author'] is Map<String, dynamic>) {
        final author = target['author'] as Map<String, dynamic>;
        if (author['guid'] == personGuid) {
          author['blocked'] = blocked;
        }
      }
    }
  }

  void _seed() {
    final now = DateTime.now().toUtc();

    _people.addAll([
      _person('person-demo', demoUserId, 'Alex Demo', _demoAvatar),
      _person('person-lina', 'lina@community.social', 'Lina West', 'https://picsum.photos/id/1011/480/480'),
      _person('person-joel', 'joel@trail.space', 'Joel Nunez', 'https://picsum.photos/id/1012/480/480'),
      _person('person-maya', 'maya@artpod.net', 'Maya Chen', 'https://picsum.photos/id/1027/480/480'),
      _person('person-samir', 'samir@makers.exchange', 'Samir Patel', 'https://picsum.photos/id/1074/480/480'),
    ]);

    _aspects.addAll([
      {'id': 1, 'name': 'Close friends'},
      {'id': 2, 'name': 'Design team'},
      {'id': 3, 'name': 'Travel buddies'},
    ]);

    _aspectMemberships[1] = {'person-lina', 'person-joel'};
    _aspectMemberships[2] = {'person-maya'};
    _aspectMemberships[3] = {'person-samir', 'person-joel'};

    final heroPost = {
      'guid': 'post-hero',
      'post_type': 'StatusMessage',
      'body': 'Sunrise over the ridge on an early walk. It was quiet enough to hear the birds. #travel #photography #morningwalk',
      'author': _people.firstWhere((p) => p['guid'] == 'person-lina'),
      'public': true,
      'nsfw': false,
      'photos': [
        _photo('photo-1', 'https://picsum.photos/id/1018/2400/1600'),
        _photo('photo-2', 'https://picsum.photos/id/1039/2400/1600'),
      ],
      'poll': null,
      'mentioned_people': [_people.firstWhere((p) => p['guid'] == 'person-demo')],
      'interaction_counters': {
        'comments': 2,
        'reshares': 1,
        'likes': 12,
      },
      'own_interaction_state': {
        'liked': true,
        'reshared': false,
        'subscribed': true,
        'reported': false,
      },
      'open_graph_object': {
        'url': 'https://example.org/story/sunrise-ridge',
        'title': 'Field Story: A Quiet Morning Walk',
        'image': 'https://picsum.photos/id/1056/1600/900',
        'description': 'A short field note about catching light, coffee, and a slow start to the day.'
      },
      'location': {
        'address': 'Aurlandsfjord, Norway',
        'lat': 60.905,
        'lng': 6.806,
      },
      'oembed': null,
      'created_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
      'root': null,
    };

    final pollPost = {
      'guid': 'post-poll',
      'post_type': 'StatusMessage',
      'body': 'What should I do on Sunday morning? #weekend',
      'author': _people.firstWhere((p) => p['guid'] == 'person-demo'),
      'public': false,
      'nsfw': false,
      'photos': <Map<String, dynamic>>[],
      'poll': {
        'question': 'Preferred weekend update?',
        'already_participated': false,
        'participation_count': 14,
        'poll_answers': [
          {'id': 1, 'answer': 'Coffee and a walk', 'own_answer': false, 'vote_count': 6},
          {'id': 2, 'answer': 'Stay in and read', 'own_answer': false, 'vote_count': 5},
          {'id': 3, 'answer': 'Call family', 'own_answer': false, 'vote_count': 3},
        ]
      },
      'mentioned_people': <Map<String, dynamic>>[],
      'interaction_counters': {
        'comments': 1,
        'reshares': 0,
        'likes': 4,
      },
      'own_interaction_state': {
        'liked': false,
        'reshared': false,
        'subscribed': true,
        'reported': false,
      },
      'open_graph_object': null,
      'location': null,
      'oembed': {
        'provider_name': 'YouTube',
        'author_name': 'Design Playground',
        'title': 'Storyboarding walkthrough',
        'thumbnail_url': 'https://picsum.photos/id/1040/1280/720',
        'html': '<iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe>'
      },
      'created_at': now.subtract(const Duration(hours: 8)).toIso8601String(),
      'root': null,
    };

    final resharePost = {
      'guid': 'post-reshare',
      'post_type': 'Reshare',
      'body': heroPost['body'],
      'author': _people.firstWhere((p) => p['guid'] == 'person-maya'),
      'public': true,
      'nsfw': false,
      'photos': heroPost['photos'],
      'poll': null,
      'mentioned_people': <Map<String, dynamic>>[],
      'interaction_counters': {
        'comments': 0,
        'reshares': 0,
        'likes': 2,
      },
      'own_interaction_state': {
        'liked': false,
        'reshared': true,
        'subscribed': true,
        'reported': false,
      },
      'open_graph_object': heroPost['open_graph_object'],
      'location': heroPost['location'],
      'oembed': null,
      'created_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
      'root': heroPost,
    };

    _posts.addAll([heroPost, pollPost, resharePost]);

    _comments['post-hero'] = [
      {
        'guid': 'comment-1',
        'body': 'This one feels the calmest.',
        'author': _people.firstWhere((p) => p['guid'] == 'person-demo'),
        'mentioned_people': <Map<String, dynamic>>[],
        'reported': false,
        'interactions': {
          'likes_count': 2,
          'liked': true,
        },
        'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'guid': 'comment-2',
        'body': 'Maybe crop a little off the left edge.',
        'author': _people.firstWhere((p) => p['guid'] == 'person-joel'),
        'mentioned_people': <Map<String, dynamic>>[],
        'reported': false,
        'interactions': {
          'likes_count': 1,
          'liked': false,
        },
        'created_at': now.subtract(const Duration(hours: 1, minutes: 20)).toIso8601String(),
      }
    ];

    _comments['post-poll'] = [
      {
        'guid': 'comment-3',
        'body': 'I’d pick the walk. That feels more like you.',
        'author': _people.firstWhere((p) => p['guid'] == 'person-samir'),
        'mentioned_people': <Map<String, dynamic>>[],
        'reported': false,
        'interactions': {
          'likes_count': 0,
          'liked': false,
        },
        'created_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
      }
    ];

    _notifications.addAll([
      {
        'guid': 'notif-1',
        'type': 'liked',
        'read': false,
        'target': {
          'guid': 'post-hero',
          'author': _people.firstWhere((p) => p['guid'] == 'person-lina')
        },
        'event_creators': [_people.firstWhere((p) => p['guid'] == 'person-joel')],
        'created_at': now.subtract(const Duration(minutes: 25)).toIso8601String(),
      },
      {
        'guid': 'notif-2',
        'type': 'comment_on_post',
        'read': false,
        'target': {
          'guid': 'post-poll',
          'author': _people.firstWhere((p) => p['guid'] == 'person-demo')
        },
        'event_creators': [_people.firstWhere((p) => p['guid'] == 'person-samir')],
        'created_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
      },
      {
        'guid': 'notif-3',
        'type': 'reshared',
        'read': true,
        'target': {
          'guid': 'post-hero',
          'author': _people.firstWhere((p) => p['guid'] == 'person-lina')
        },
        'event_creators': [_people.firstWhere((p) => p['guid'] == 'person-maya')],
        'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
      }
    ]);

    _conversations.addAll([
      {
        'guid': 'conversation-1',
        'subject': 'Weekend shortlist',
        'read': false,
        'participants': [
          _people.firstWhere((p) => p['guid'] == 'person-demo'),
          _people.firstWhere((p) => p['guid'] == 'person-lina'),
          _people.firstWhere((p) => p['guid'] == 'person-maya'),
        ],
        'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'guid': 'conversation-2',
        'subject': 'Release notes wording',
        'read': true,
        'participants': [
          _people.firstWhere((p) => p['guid'] == 'person-demo'),
          _people.firstWhere((p) => p['guid'] == 'person-joel'),
        ],
        'created_at': now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
      },
    ]);

    _messages['conversation-1'] = [
      {
        'guid': 'message-1',
        'body': 'I uploaded three hero candidates. Which one leads?',
        'author': _people.firstWhere((p) => p['guid'] == 'person-demo'),
        'created_at': now.subtract(const Duration(hours: 4, minutes: 30)).toIso8601String(),
      },
      {
        'guid': 'message-2',
        'body': 'The sunrise image is strongest. Keep the map pin visible.',
        'author': _people.firstWhere((p) => p['guid'] == 'person-lina'),
        'created_at': now.subtract(const Duration(hours: 4)).toIso8601String(),
      },
    ];

    _messages['conversation-2'] = [
      {
        'guid': 'message-3',
        'body': 'Can we mention family plans in the evening update?',
        'author': _people.firstWhere((p) => p['guid'] == 'person-joel'),
        'created_at': now.subtract(const Duration(days: 1, hours: 1)).toIso8601String(),
      }
    ];
  }

  Map<String, dynamic> _person(String guid, String diasporaId, String name, String avatar) {
    return {
      'guid': guid,
      'diaspora_id': diasporaId,
      'name': name,
      'avatar': avatar,
    };
  }

  Map<String, dynamic> _photo(String guid, String rawUrl) {
    return {
      'guid': guid,
      'dimensions': {
        'width': 2400,
        'height': 1600,
      },
      'sizes': {
        'raw': rawUrl,
        'large': rawUrl.replaceFirst('/2400/1600', '/1600/1066'),
        'medium': rawUrl.replaceFirst('/2400/1600', '/1200/800'),
        'small': rawUrl.replaceFirst('/2400/1600', '/600/400'),
      }
    };
  }
}

Future<void> main(List<String> args) async {
  var port = defaultMockPort;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? defaultMockPort;
    }
  }

  final server = DemoMockServer(port: port);
  final uri = await server.start();
  stdout.writeln('Demo mock server running at $uri');
  stdout.writeln('Health: $uri/health');
}
