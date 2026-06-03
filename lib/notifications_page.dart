import 'package:flutter/material.dart' hide Notification, Page, NavigationBar;
import 'package:provider/provider.dart';

import 'src/client.dart';
import 'src/item_stream.dart';
import 'src/localizations.dart';
import 'src/navigation.dart';
import 'src/timeago.dart';
import 'src/utils.dart';
import 'src/widgets.dart';
import 'src/colors.dart' as colors;

class NotificationStream extends ItemStream<Notification> {
  @override
  Future<Page<Notification>> loadPage({required Client client, String? page}) =>
    client.fetchNotifications(page: page);
}

class NotificationsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ItemStreamState<Notification, NotificationsPage> {
  @override
  Widget buildBody(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(currentPage: PageType.notifications),
      body: buildStream(context)
    );
  }

  @override
  ItemStream<Notification> createStream() => NotificationStream();

  @override
  Widget buildItem(BuildContext context, Notification item) => _NotificationListItem(item);
}

class _NotificationListItem extends StatefulWidget {
  _NotificationListItem(this.notification, {Key? key}) : super(key: key);

  final Notification notification;

  @override
  State<StatefulWidget> createState() => _NotificationListItemState();
}

class _NotificationListItemState extends State<_NotificationListItem> with StateLocalizationHelpers {
  String? _previewBody;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchPreview());
  }

  Future<void> _fetchPreview() async {
    if (widget.notification.targetGuid == null || !_hasContentPreview) return;

    try {
      final client = context.read<Client>();
      final post = await client.fetchPost(widget.notification.targetGuid!);
      if (mounted && post.body.isNotEmpty) {
        setState(() => _previewBody = _notificationBodyPreview(post.body));
      }
    } catch (_) {
      // Preview is optional, silently ignore errors
    }
  }

  bool get _hasContentPreview {
    switch (widget.notification.type) {
      case NotificationType.startedSharing:
      case NotificationType.contactsBirthday:
        return false;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.notification.guid),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: widget.notification.read ? theme.colorScheme.secondary : Colors.transparent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.done),
      ),
      confirmDismiss: _toggleRead,
      child: InkWell(
        onTap: _canGoToTarget ? _goToTarget : null,
        child: Container(
          decoration:  BoxDecoration(
            color: widget.notification.read ? theme.colorScheme.surface : colors.unreadItemBackground(theme),
            border: Border(
              left: widget.notification.read ? BorderSide.none : BorderSide(color: theme.colorScheme.secondary, width: 2),
              bottom: BorderSide(color: widget.notification.read ? theme.dividerColor : colors.unreadItemBottomBorder(theme))
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: AvatarStack(people: widget.notification.eventCreators),
            title: Text(_title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Timeago(
                  widget.notification.createdAt,
                  textStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),
                if (_previewBody != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _previewBody!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    final actorCount = widget.notification.eventCreators.length;

    switch (widget.notification.type) {
      case NotificationType.alsoCommented:
        return l.notificationAlsoCommented(actorCount, _actors, _targetPost);
      case NotificationType.commentOnPost:
        return l.notificationCommented(actorCount, _actors, _targetPost);
      case NotificationType.contactsBirthday:
        return l.notificationBirthday(actorCount, _actors);
      case NotificationType.liked:
        return l.notificationLiked(actorCount, _actors, _targetPost);
      case NotificationType.likedComment:
        return l.notificationLikedComment(actorCount, _actors, _targetComment);
      case NotificationType.mentioned:
        return l.notificationMentionedInPost(actorCount, _actors, _targetPost);
      case NotificationType.mentionedInComment:
        return widget.notification.targetGuid != null ?
          l.notificationMentionedInComment(actorCount, _actors) :
          l.notificationMentionedInCommentOnDeletedPost(actorCount, _actors);
      case NotificationType.reshared:
        return l.notificationReshared(actorCount, _actors, _targetPost);
      case NotificationType.startedSharing:
        return l.notificationStartedSharing(actorCount, _actors);
    }
  }

  String get _actors {
    final names = widget.notification.eventCreators.map((actor) => actor.name ?? actor.diasporaId).toList();
    if (names.length == 1) {
      return names[0];
    } else if (names.length == 2) {
      return l.notificationActorsForTwoPeople(names[0], names[1]);
    } else if (names.length == 3) {
      return l.notificationActorsForThreePeople(names[0], names[1], names[2]);
    } else {
      return l.notificationActorsForMoreThanThreePeople(names[0], names[1], names.length - 2);
    }
  }

  String get _targetPost => widget.notification.targetGuid == null ? l.notificationTargetDeletedPost : l.notificationTargetPost;

  String get _targetComment => widget.notification.targetGuid == null ? l.notificationTargetDeletedComment : l.notificationTargetComment;

  bool get _canGoToTarget {
    switch (widget.notification.type) {
      case NotificationType.startedSharing:
      case NotificationType.contactsBirthday:
        return true;
      default:
        return widget.notification.targetGuid != null;
    }
  }

  Future<bool> _toggleRead(_) async {
    await _setRead(!widget.notification.read);

    return false;
  }

  Future<void> _setRead(bool newStatus) async {
    if (widget.notification.read == newStatus) {
      return;
    }

    final client = context.read<Client>(),
      unreadCount = context.read<UnreadNotificationsCount>();

    setState(() => widget.notification.read = newStatus);
    if (newStatus) {
      unreadCount.decrement();
    } else {
      unreadCount.increment();
    }

    try {
      await client.setNotificationRead(widget.notification, isRead: newStatus);
    } catch (e, s)  {
      tryShowErrorSnackBar(context, newStatus ? l.failedToMarkNotificationAsRead : l.failedToMarkNotificationAsUnread, e, s);

      if (mounted) {
        setState(() => widget.notification.read = !newStatus);
      }

      if (newStatus) {
        unreadCount.increment();
      } else {
        unreadCount.decrement();
      }
    }
  }

  void _goToTarget() async {
    _setRead(true);

    switch (widget.notification.type) {
      case NotificationType.alsoCommented:
      case NotificationType.commentOnPost:
      case NotificationType.liked:
      case NotificationType.likedComment:
      case NotificationType.mentioned:
      case NotificationType.reshared:
      case NotificationType.mentionedInComment:
        Navigator.pushNamed(context, "/post", arguments: widget.notification.targetGuid);
        break;
      case NotificationType.contactsBirthday:
      case NotificationType.startedSharing:
        Navigator.pushNamed(context, "/profile", arguments: widget.notification.eventCreators.first);
        break;
    }
  }
}

/// Returns a plain-text preview for a notification body, mirroring the
/// algorithm used by the Diaspora server in `MessageRenderer#title`.
///
/// Attempts to extract a heading from the first line:
/// - Setext style: text on one line followed by `===` or `---`
/// - ATX style: line starting with one or more `#` characters
///
/// Falls back to stripping markdown from the full body.
String _notificationBodyPreview(String body) {
  final trimmed = body.trimLeft();

  // Setext heading: up to 200-char line followed by === or --- line
  final setext = RegExp(r'^(.{1,200})\n[=\-]{2,}(?:\r?\n|$)').firstMatch(trimmed);
  if (setext != null) {
    return _stripMarkdown(setext[1]!);
  }

  // ATX heading: # / ## / … up to ######
  final atx = RegExp(r'^#{1,6}\s+(.{1,200}?)(?:\s+#+)?\s*(?:\r?\n|$)').firstMatch(trimmed);
  if (atx != null) {
    return _stripMarkdown(atx[1]!);
  }

  // Fallback: strip markdown from the entire body
  return _stripMarkdown(body);
}

/// Strips Markdown syntax from [text] and returns plain text with
/// whitespace squished. Mirrors the behaviour of Redcarpet::Render::StripDown
/// used by the Diaspora server.
String _stripMarkdown(String text) {
  return text
    // Diaspora @mentions: @{Name; diaspora@id} → @Name
    .replaceAllMapped(RegExp(r'@\{(?:([^};]+);\s*)?([^}]+)\}'), (m) {
      final name = m[1]?.trim() ?? m[2]!.trim();
      return '@$name';
    })
    // Images: ![alt](url) → alt
    .replaceAllMapped(RegExp(r'!\[([^\]]*)\]\([^)]+\)'), (m) => m[1] ?? '')
    // Links: [text](url) → text
    .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]+\)'), (m) => m[1] ?? '')
    // Fenced code blocks: ```lang\n...\n``` → content
    .replaceAllMapped(RegExp(r'```[^\n]*\n([\s\S]*?)```', multiLine: true), (m) => m[1] ?? '')
    // Inline code: `code` → code
    .replaceAllMapped(RegExp(r'`+([^`\n]+)`+'), (m) => m[1] ?? '')
    // ATX headers: # heading → heading
    .replaceAllMapped(RegExp(r'^#{1,6}\s+(.*?)(?:\s+#+)?\s*$', multiLine: true), (m) => m[1] ?? '')
    // Setext underlines (=== or ---) — already exposed the heading text above
    .replaceAll(RegExp(r'^[=\-]{2,}\s*$', multiLine: true), '')
    // Bold+italic / bold / italic with *
    .replaceAllMapped(RegExp(r'\*{1,3}([^*\n]+)\*{1,3}'), (m) => m[1] ?? '')
    // Bold+italic / bold / italic with _
    .replaceAllMapped(RegExp(r'_{1,3}([^_\n]+)_{1,3}'), (m) => m[1] ?? '')
    // Strikethrough: ~~text~~
    .replaceAllMapped(RegExp(r'~~([^~\n]+)~~'), (m) => m[1] ?? '')
    // Blockquotes: > text → text
    .replaceAll(RegExp(r'^>\s?', multiLine: true), '')
    // Horizontal rules
    .replaceAll(RegExp(r'^(?:[-*_] *){3,}\s*$', multiLine: true), '')
    // List items: - item / * item / + item / 1. item → item
    .replaceAll(RegExp(r'^[ \t]*(?:[-*+]|\d+\.)\s+', multiLine: true), '')
    // Squish: collapse all whitespace to a single space
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .replaceAll(RegExp(r'\n+'), ' ')
    .trim();
}
