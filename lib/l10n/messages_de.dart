// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static m0(count) => "${Intl.plural(count, zero: 'Keine Aspekte', one: 'Ein Aspekt', other: '${count} Aspekte')}";

  static m1(name) => "Aspekte für ${name} auswählen";

  static m2(name) => "Aspekt ${name} wirklich löschen?";

  static m3(name) => "${name} ist bereits ein Empfänger, kann nicht erneut hinzugefügt werden.";

  static m4(name) => "${name} teilt nicht mit dir, kann nicht als Empfänger hinzugefügt werden.";

  static m5(name) => "Du teilst nicht mit ${name}, kann nicht als Empfänger hinzugefügt werden.";

  static m6(name) => "Konnte ${name} nicht blockieren";

  static m7(name) => "Aspekt ${name} konnte nicht gelöscht werden";

  static m8(tag) => "Konnte #${tag} nicht folgen";

  static m9(oldName, newName) => "Konnte Aspekt ${oldName} nicht nach ${newName} umbenennen";

  static m10(name) => "Konnte ${name} nicht entblocken";

  static m11(tag) => "Konnte #${tag} nicht entfolgen";

  static m12(count) => "${Intl.plural(count, zero: 'In keinem Aspekt', one: 'In einem Aspekt', other: 'In ${count} Aspekten')}";

  static m13(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} und niemand sonst', one: '${first}, ${second} und noch jemand', other: '${first}, ${second} und ${othersCount} andere')}";

  static m14(first, second, third) => "${first}, ${second} und ${third}";

  static m15(first, second) => "${first} und ${second}";

  static m16(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Niemand hat auch einen ${target} kommentiert.', one: '${actors} hat auch einen ${target} kommentiert.', other: '${actors} hat auch einen ${target} kommentiert.')}";

  static m17(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Niemand hat heute Geburtstag.', one: '${actors} hat heute Geburtstag.', other: '${actors} haben heute Geburtstag.')}";

  static m18(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Niemand hat deinen ${target} kommentiert.', one: '${actors} hat deinen ${target} kommentiert.', other: '${actors} haben deinen ${target} kommentiert.')}";

  static m19(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Niemand gefällt dein ${target}.', one: '${actors} gefällt dein ${target}.', other: '${actors} gefallen dein ${target}.')}";

  static m20(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Niemand hat dich in einem Kommentar erwähnt.', one: '${actors} hat dich in einem Kommentar erwähnt.', other: '${actors} haben dich in einem Kommentar erwähnt.')}";

  static m21(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Niemand hat dich in einem Kommentar zu einem gelöschten Beitrag erwähnt.', one: '${actors} hat dich in einem Kommentar zu einem gelöschten Beitrag erwähnt.', other: '${actors} haben dich in einem Kommentar zu einem gelöschten Beitrag erwähnt.')}";

  static m22(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Niemand hat dich in einem ${target} erwähnt.', one: '${actors} hat dich in einem ${target} erwähnt.', other: '${actors} haben dich in einem ${target} erwähnt.')}";

  static m23(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Niemand hat deinen ${target} weitergesagt.', one: '${actors} hat deinen ${target} weitergesagt.', other: '${actors} haben deinen ${target} weitergesagt.')}";

  static m24(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Niemand hat angefangen mit dir zu teilen.', one: '${actors} hat angefangen mit dir zu teilen.', other: '${actors} haben angefangen mit dir zu teilen.')}";

  static m25(author) => "NSFW Beitrag von ${author}";

  static m26(author) => "von ${author}";

  static m27(author, provider) => "${author} auf ${provider}:";

  static m28(count) => "${Intl.plural(count, zero: 'Keine Aspekte', one: 'Ein Aspekt', other: '${count} Aspekte')}";

  static m29(name) => "Du teilst nun mit ${name}.";

  static m30(name) => "Du teilst nun nicht mehr mit ${name}.";

  static m31(count) => "${Intl.plural(count, zero: 'Bisher keine Stimmen', one: 'Eine Stimme', other: '${count} Stimmen')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "addContact" : MessageLookupByLibrary.simpleMessage("Kontakt hinzufügen"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("Eigenen Standort hinzufügen"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("Eine Umfrage hinzufügen"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("Gib einen Namen ein"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("Alle Aspekte"),
    "aspectStreamSelectorAspects" : m0,
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("Aspekte"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("Aspekte auswählen"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Blockieren"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("Benachrichtigungen stoppen"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("Kommentare"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("Weitersagen"),
    "contactAspectsPrompt" : m1,
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("Aspekte aktualisiert."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("Von dir blockiert"),
    "contactStatusMutual" : MessageLookupByLibrary.simpleMessage("Ihr teilt miteinander"),
    "contactStatusNotSharing" : MessageLookupByLibrary.simpleMessage("Ihr teilt nicht miteinander."),
    "contactStatusReceiving" : MessageLookupByLibrary.simpleMessage("Diese Person teilt mit dir."),
    "contactStatusSharing" : MessageLookupByLibrary.simpleMessage("Du teilst mit dieser Person."),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("Aspekt erstellen"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("Erstellen"),
    "createComment" : MessageLookupByLibrary.simpleMessage("Kommentieren"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("Umfrage erstellen"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("Kommentar löschen?"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("Beitrag löschen?"),
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Weitersagung eines gelöschten Beitrags"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Alle abwählen"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("Tag wurde bereits hinzugefügt"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("Aspekt bearbeiten"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("Umfrage bearbeiten"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("Geburtstag"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("Gender"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("Profile bearbeiten"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("Standort"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("Name"),
    "editProfileNsfwLabel" : MessageLookupByLibrary.simpleMessage("Profile als #nsfw markieren?"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("Profil öffentlich machen?"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("Profil in der Suche anzeigen?"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("Profil speichern"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("Tags"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("Profil"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("Gib eine Adresse ein"),
    "errorSignInTimeout" : MessageLookupByLibrary.simpleMessage("Zeitüberschreitung beim Versuch der Authentifizierung. Sicher, dass dein Pod die API unterstützt?"),
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("Empfänger konnte nicht hinzugefügt werden"),
    "failedToAddConversationParticipantDuplicate" : m3,
    "failedToAddConversationParticipantNotSharing" : m4,
    "failedToAddConversationParticipantNotSharingWith" : m5,
    "failedToBlockUser" : m6,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Kommentar konnte nicht erstellt werden"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Aspekt konnte nicht erstellt werden"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("Unterhaltung konnte nicht erstellt werden"),
    "failedToDeleteAspect" : m7,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("Konnte Kommentar nicht löschen"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Beitrag konnte nicht gelöscht werden"),
    "failedToFollowTag" : m8,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Die Unterhaltung konnte nicht versteckt werden"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Der Beitrag konnte nicht versteckt werden"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Konnte den Beitrag nicht mit einem „Gefällt mir“ markieren"),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("Konnte Benachrichtigung nicht als gelesen markieren"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("Konnte Benachrichtigung nicht als ungelesen markieren"),
    "failedToRenameAspect" : m9,
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Konnte auf die Unterhaltung nicht antworten"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("Konnte den Kommentar nicht melden"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Konnte den Beitrag nicht melden"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Konnte den Beitrag nicht weitersagen"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Konnte nicht nach den Adressen suchen"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Konnte die Benachrichtigungen für den Beitrag nicht anstellen"),
    "failedToUnblockUser" : m10,
    "failedToUnfollowTag" : m11,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("Konnte das „Gefällt mir“ nicht vom Beitrag entfernen"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("Konnte die Benachrichtigungen für den Beitrag nicht abbestellen"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("Konnte die Aspekte nicht aktualisieren"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("Konnte das Profil nicht speichern"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("Konnte das Bild nicht hochladen"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("Konnte das Profilbild nicht hochladen"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("Konnte nicht abstimmen"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("Verfolgte tags"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("Fett"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("Kursiv"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("Durchgestrichen"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("Verstecken"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("Liste"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("Einfügen"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("Code"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("Codeblock"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("Tag"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("Überschrift"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("Bildadresse"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("Bild einbetten"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("Link"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("Beschreibung (optional)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("Link einfügen"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("Adresse"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("Erwähnung"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("Nummerierte Liste"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("Zitat"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("Gib eine volle diaspora* ID ein"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("Gefällt"),
    "manageContact" : m12,
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("Verfolgte Tags verwalten"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("In Beitrag erwähnen"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("Nachricht senden"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("Kontakte"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("Unterhaltungen"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("Suche"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("Stream"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("Nutzer wechseln"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("Nachricht"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("Empfänger"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("Betreff"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("Unterhaltung beginnen"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("Nein"),
    "noItems" : MessageLookupByLibrary.simpleMessage("Leider nichts zum anzeigen gefunden 😕"),
    "notificationActorsForMoreThanThreePeople" : m13,
    "notificationActorsForThreePeople" : m14,
    "notificationActorsForTwoPeople" : m15,
    "notificationAlsoCommented" : m16,
    "notificationBirthday" : m17,
    "notificationCommented" : m18,
    "notificationLiked" : m19,
    "notificationMentionedInComment" : m20,
    "notificationMentionedInCommentOnDeletedPost" : m21,
    "notificationMentionedInPost" : m22,
    "notificationReshared" : m23,
    "notificationStartedSharing" : m24,
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("gelöschten Beitrag"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("Beitrag"),
    "nsfwShieldTitle" : m25,
    "oEmbedAuthor" : m26,
    "oEmbedHeader" : m27,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Nach Person suchen"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Gib eine Antwort ein"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Gib eine Frage ein"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("Ergebnisse anschauen"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Infos"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Beiträge"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Beitrag erstellen"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("Alle Aspekte"),
    "publishTargetAspects" : m28,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Beitragssichtbarkeit auswählen"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Öffentlich"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Beitrag erstellen"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Löschen"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Antworten"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("Kommentar melden"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("Bitte beschreibe das Problem"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("Kommentar melden"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Beitrag melden"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Bitte beschreibe das Problem"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Beitrag melden"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Beitrag weitersagen?"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("Weitersagungen"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("Speichern"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("Suchen"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("Gib einen Tag ein"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("Gib einen Namen oder eine diaspora* ID ein"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("Gib einen Tag ein"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("Leute"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("Leute mit Tag"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("Tags"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Alle auswählen"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("Auswählen"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("Abschicken"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("Kommentar gemeldet."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Beitrag gemeldet."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("Zeige alle NSFW Beiträge"),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("Den ursprünglich wieder weitergesagten Beitrag anzeigen"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Zeige diesen Beitrag"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Anmelden"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("benutzername@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("diaspora* ID"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Benachrichtigungen für Beitrag anstellen"),
    "startedSharing" : m29,
    "stoppedSharing" : m30,
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("Aktivitäten"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("Aspekte"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("Kommentiert"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("Verfolgte Tags"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("Gefällt mir"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("Stream"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("Erwähnungen"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("Tag"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("Senden"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Suche nach einem Tag"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("Neues Profilbild machen"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("Bild machen"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("Entblocken"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("Profil aktualisiert."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("Neues Profilbild hochladen"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("Ein Bild hochladen"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("Neues Profilbild hochladen"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("Abstimmen"),
    "voteCount" : m31,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Ja")
  };
}
