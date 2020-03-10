import 'dart:convert';

import 'package:quiver/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'client.dart';
import 'posts.dart';

class PersistentState {
  static const _key = "persistent_state";
  static const _draftsToKeep = 20;

  bool _restored = false;
  bool _wasAuthorizing = false;
  StreamOptions _lastStreamOptions;
  String _postDraft;
  Map<String, String> _commentDrafts = LruMap(maximumSize: _draftsToKeep);
  Map<String, String> _messageDrafts = LruMap(maximumSize: _draftsToKeep);

  bool get wasAuthorizing => _wasAuthorizing;
  set wasAuthorizing(bool value) {
    _wasAuthorizing = value;
    persist();
  }

  StreamOptions get lastStreamOptions => _lastStreamOptions;
  set lastStreamOptions(StreamOptions value) {
    _lastStreamOptions = value;
    persist();
  }

  String get postDraft => _postDraft;
  set postDraft(String value) {
    _postDraft = value;
    persist();
  }

  String getCommentDraft(Post post) => _commentDrafts[post.guid];

  void setCommentDraft(Post post, String draft) {
    _commentDrafts[post.guid] = draft;
    persist();
  }

  void clearCommentDraft(Post post) {
    if (_commentDrafts.remove(post.guid) != null) {
      persist();
    }
  }

  String getMessageDraft(Conversation conversation) => _messageDrafts[conversation.guid];

  void setMessageDraft(Conversation conversation, String draft) {
    _messageDrafts[conversation.guid] = draft;
    persist();
  }

  void clearMessageDraft(Conversation conversation) {
    if (_messageDrafts.remove(conversation.guid) != null) {
      persist();
    }
  }

  Future<void> restore() async {
    if (_restored) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_key)) {
      final values = jsonDecode(prefs.getString(_key));
      _wasAuthorizing = values["was_authorizing"] ?? false;
      _lastStreamOptions = values["last_stream_options"] != null ? StreamOptions.from(values["last_stream_options"]) : null;
      _postDraft = values["post_draft"];

      _commentDrafts.clear();
      if (values["comment_drafts"] != null) {
        _commentDrafts.addAll(values["comment_drafts"].cast<String, String>());
      }

      _messageDrafts.clear();
      if (values["message_drafts"] != null) {
        _messageDrafts.addAll(values["message_drafts"].cast<String, String>());
      }
    }

    _restored = true;
  }

  Future<void> persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      "was_authorizing": wasAuthorizing,
      "last_stream_options": lastStreamOptions,
      "post_draft": postDraft,
      "comment_drafts": _commentDrafts,
      "message_drafts": _messageDrafts
    }));
  }
}
