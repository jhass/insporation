// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static m0(count) => "${Intl.plural(count, zero: 'Aucun aspect', one: 'Un aspect', other: '${count} aspects')}";

  static m1(name) => "Sélectionner des aspects pour ${name}";

  static m2(name) => "Supprimer l’aspect ${name} ?";

  static m3(userId) => "Supprimer la session pour ${userId} d\'insporation* ?";

  static m4(name) => "${name} est déjà destinataire ; impossible de l’ajouter deux fois.";

  static m5(name) => "${name} ne partage pas avec vous ; impossible de l’ajouter comme destinataire !";

  static m6(name) => "Vous ne partagez pas avec ${name} ; impossible de l’ajouter comme destinataire !";

  static m7(name) => "Échec du blocage de ${name}";

  static m8(name) => "Échec de la suppression de l’aspect ${name}";

  static m9(tag) => "Échec du suivi de #${tag}";

  static m10(oldName, newName) => "Échec du renommage de l’aspect ${oldName} en ${newName}";

  static m11(name) => "Échec du déblocage de ${name}";

  static m12(tag) => "Échec de l’arrêt du suivi de #${tag}";

  static m13(count) => "${Intl.plural(count, zero: 'Dans aucun aspect', one: 'Dans un aspect', other: 'Dans ${count} aspects')}";

  static m14(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} et personne d’autre', one: '${first}, ${second} et un de plus', other: '${first}, ${second} et ${othersCount} autres')}";

  static m15(first, second, third) => "${first}, ${second} et ${third}";

  static m16(first, second) => "${first} et ${second}";

  static m17(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Personne n’a commenté ${target}.', one: '${actors} a commenté ${target}.', other: '${actors} ont commenté ${target}.')}";

  static m18(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Personne n’a son anniveraire aujourd’hui.', one: '${actors} a son anniversaire ajourd’hui.', other: '${actors} ont leur anniversaire aujourd’hui.')}";

  static m19(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Personne n’a commenté votre ${target}.', one: '${actors} a commenté votre ${target}.', other: '${actors} ont commenté votre ${target}.')}";

  static m20(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Personne n’a aimé votre ${target}.', one: '${actors} a aimé votre ${target}.', other: '${actors} ont aimé votre ${target}.')}";

  static m21(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Personne ne vous a mentionné·e dans un commentaire.', one: '${actors} vous a mentionné·e dans un commentaire.', other: '${actors} vous ont mentionné·e dans un commentaire.')}";

  static m22(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Personne ne vous a mentionné·e dans un commentaire sur une publication supprimée.', one: '${actors} vous a mentionné·e dans un commentaire sur une publication supprimée.', other: '${actors} vous ont mentionné·e dans un commentaire sur une publication supprimée.')}";

  static m23(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Personne ne vous a mentionné·e dans une ${target}.', one: '${actors} vous a mentionné·e dans une ${target}.', other: '${actors} vous ont mentionné·e dans une ${target}.')}";

  static m24(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Personne n’a repartagé votre ${target}.', one: '${actors} a repartagé votre ${target}.', other: '${actors} ont repartagé votre ${target}.')}";

  static m25(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Personne n’a commencé à partager avec vous.', one: '${actors} a commencé à partager avec vous.', other: '${actors} ont commencé à partager avec vous.')}";

  static m26(author) => "Publication sensible de ${author}";

  static m27(author) => "par ${author}";

  static m28(author, provider) => "${author} sur ${provider} :";

  static m29(count) => "${Intl.plural(count, zero: 'Aucun aspect', one: 'Un aspect', other: '${count} aspects')}";

  static m30(name) => "Vous partagez désormais avec ${name}.";

  static m31(name) => "Vous avez arrêté de partager avec ${name}.";

  static m32(count) => "${Intl.plural(count, zero: 'Aucun vote jusqu’à présent', one: '1 vote jusqu’à présent', other: '${count} votes jusqu’à présent')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "addContact" : MessageLookupByLibrary.simpleMessage("Ajouter un contact"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("Ajouter votre position"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("Ajouter un sondage"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("Entrez un nom"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("Tous les aspects"),
    "aspectStreamSelectorAspects" : m0,
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("Aspects"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("Sélectionner les aspects"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Bloquer"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("Arrêter les notifications"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("Commentaires"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Confirmer la suppression"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("Repartager"),
    "contactAspectsPrompt" : m1,
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("Aspects mis à jour."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("Vous l’avez bloqué·e"),
    "contactStatusMutual" : MessageLookupByLibrary.simpleMessage("Vous partagez l’un avec l’autre"),
    "contactStatusNotSharing" : MessageLookupByLibrary.simpleMessage("Vous ne partagez pas l’un avec l’autre."),
    "contactStatusReceiving" : MessageLookupByLibrary.simpleMessage("Cette personne partage avec vous."),
    "contactStatusSharing" : MessageLookupByLibrary.simpleMessage("Vous partagez avec cette personne."),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("Créer un aspect"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("Créer"),
    "createComment" : MessageLookupByLibrary.simpleMessage("Commenter"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("Créer le sondage"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("Supprimer le commentaire ?"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("Supprimer la publication ?"),
    "deleteSessionPrompt" : m3,
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Repartage d’une publication supprimée"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Tout désélectionner"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("Étiquette déjà ajoutée"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("Modifier l’aspect"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("Modifier le sondage"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("Modifier le profil"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("Date de naissance"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("Genre"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("Modifier le profil"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("Position"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("Nom"),
    "editProfileNsfwLabel" : MessageLookupByLibrary.simpleMessage("Marquer le profil comme #nsfw ?"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("Rendre publiques les infos du profil ?"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("Autoriser à ce qu’on trouve votre profil via la recherche ?"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("Mettre à jour le profil"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("Étiquettes"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("Modifier le profil"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("Entrez une adresse"),
    "errorSignInTimeout" : MessageLookupByLibrary.simpleMessage("Délai d\'attente lors de la tentative d\'authentification, êtes-vous sûr·e que votre pod prend en charge l\'API ?"),
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("Échec de l’ajout du destinataire"),
    "failedToAddConversationParticipantDuplicate" : m4,
    "failedToAddConversationParticipantNotSharing" : m5,
    "failedToAddConversationParticipantNotSharingWith" : m6,
    "failedToBlockUser" : m7,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Échec de la création du commentaire"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Échec de la création de l’aspect"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("Échec de la création de la conversation"),
    "failedToDeleteAspect" : m8,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("Échec de la suppression du commentaire"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Échec de la suppression de la publication"),
    "failedToFollowTag" : m9,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Échec du masquage de la conversation"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Échec du masquage de la publication"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Échec de l’ajout de la mention j’aime"),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("Échec du marquage de la publication comme lue"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("Échec du marquage de la notification comme non lue"),
    "failedToRenameAspect" : m10,
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Échec de la réponse à la conversation"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("Échec de la création du signalement"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Échec de la création du signalement"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Échec du repartage de la publication"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Échec de la recherche d’adresses"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Échec de l’abonnement à la publication"),
    "failedToUnblockUser" : m11,
    "failedToUnfollowTag" : m12,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("Échec de la suppression du j’aime"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("Échec du désabonnement de la publication"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("Échec de la mise à jour des aspects"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("Échec de la mise à jour du profil"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("Échec du téléversement de la photo"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("Échec du téléversement de l’image de profil"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("Échec du vote"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("Étiquettes suivies"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("Gras"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("Italique"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("Barré"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("Masquer"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("Liste à puces"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("Insérer"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("Code"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("Bloc de code"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("Étiquette"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("En-tête"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("URL de l’image"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("Incorporer une image"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("Lien"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("Description (optionnel)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("Insérer un lien"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("URL"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("Mention"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("Liste numérotée"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("Citation"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("Entrez un identifiant diaspora* complet"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("J’aime"),
    "manageContact" : m13,
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("Gérer les étiquettes suivies"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("Mentionner un utilisateur"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("Écrire un message"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("Contacts"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("Conversations"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("Modifier le profil"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("Notifications"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("Rechercher"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("Stream"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("Changer d\'utilisateur"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("Message"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("Destinataires"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("Objet"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("Démarrer une nouvelle conversation"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("Non"),
    "noItems" : MessageLookupByLibrary.simpleMessage("Mince, rien à afficher !"),
    "notificationActorsForMoreThanThreePeople" : m14,
    "notificationActorsForThreePeople" : m15,
    "notificationActorsForTwoPeople" : m16,
    "notificationAlsoCommented" : m17,
    "notificationBirthday" : m18,
    "notificationCommented" : m19,
    "notificationLiked" : m20,
    "notificationMentionedInComment" : m21,
    "notificationMentionedInCommentOnDeletedPost" : m22,
    "notificationMentionedInPost" : m23,
    "notificationReshared" : m24,
    "notificationStartedSharing" : m25,
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("publication supprimée"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("publication"),
    "nsfwShieldTitle" : m26,
    "oEmbedAuthor" : m27,
    "oEmbedHeader" : m28,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Rechercher une personne"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Entrez une réponse"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Entrez une question"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("Afficher les résultats"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Infos"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Publications"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Publier"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("Tous les aspects"),
    "publishTargetAspects" : m29,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Sélectionner la visibilité de la publication"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Publique"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Écrire une nouvelle publication"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Retirer"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Répondre"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("Signaler"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("Veuillez décrire le problème"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("Signaler le commentaire"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Signaler"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Veuillez décrire le problème"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Signaler la publication"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Repartager la publication ?"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("Repartages"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("Rechercher"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("Entrez une étiquette"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("Commencez à taper un nom ou un identifiant diaspora*"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("Commencez à entrer une étiquette"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("Gens"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("Personnes par étiquette"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("Étiquettes"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Tout sélectionner"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("Sélectionner"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("Envoyer"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("Signalement envoyé."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Signalement envoyé."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("Afficher toutes les publications sensibles"),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("Afficher la publication originellement repartagée"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Afficher cette publication"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Se connecter"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("nom_dutilisateur@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("Identifiant diaspora*"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Activer les notifications"),
    "startedSharing" : m30,
    "stoppedSharing" : m31,
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("Activité"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("Aspects"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("Commenté"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("Étiquettes suivies"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("Aimé"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("Stream"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("Mentions"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("Étiquette"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("Soumettre"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Rechercher une étiquette"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("Prendre une nouvelle image"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("Prendre une photo"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("Débloquer"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("Profil mis à jour."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("Téléverser une nouvelle image"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("Téléverser une photo"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("Mettre à jour l’image du profil"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("Voter"),
    "voteCount" : m32,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Oui")
  };
}
