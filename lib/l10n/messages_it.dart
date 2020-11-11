// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static m2(name) => "Eliminare l’aspetto ${name}?";

  static m7(name) => "Impossibile bloccare ${name}";

  static m8(name) => "Impossibile rimuovere l’aspetto ${name}";

  static m9(tag) => "Impossibile seguire #${tag}";

  static m10(oldName, newName) => "Impossibile rinominare l’aspetto ${oldName} in ${newName}";

  static m11(name) => "Impossibile sbloccare ${name}";

  static m12(tag) => "Impossibile smettere di seguire #${tag}";

  static m15(first, second, third) => "${first}, ${second} e ${third}";

  static m16(first, second) => "${first} e ${second}";

  static m27(author) => "da ${author}";

  static m28(author, provider) => "${author} su ${provider}:";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "addContact" : MessageLookupByLibrary.simpleMessage("Aggiungi contatto"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("Aggiungi la tua posizione"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("Aggiungi un sondaggio"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("Inserisci un nome"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("Tutti gli aspetti"),
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("Aspetti"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("Seleziona aspetti"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Blocca"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("Blocca le notifiche"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("Commenti"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Conferma l’eliminazione"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("Ricondividi"),
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("Aspetti aggiornati."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("Bloccato/a da te"),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("Crea un aspetto"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("Crea"),
    "createComment" : MessageLookupByLibrary.simpleMessage("Commenta"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("Crea il sondaggio"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("Eliminare il commento?"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("Eliminare il post?"),
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Ricondivisione di un post eliminato"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Deseleziona tutto"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("Etichetta già aggiunta"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("Modifica l’aspetto"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("Modifica il sondaggio"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("Modifica il profilo"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("Compleanno"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("Sesso"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("Modifica il profilo"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("Posizione"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("Nome"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("Rendere pubbliche le informazioni del profilo?"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("Permettere che il tuo profilo possa essere trovato via la ricerca?"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("Aggiorna il profilo"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("Etichette"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("Modifica il profilo"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("Inserisci un indirizzo"),
    "failedToBlockUser" : m7,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Aggiunta del commento non riuscita"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Creazione dell’aspetto non riuscita"),
    "failedToDeleteAspect" : m8,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("Eliminazione del commento non riuscita"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Eliminazione del post non riuscita"),
    "failedToFollowTag" : m9,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Impossibile nascondere la conversazione"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Non è stato possibile nascondere il post"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Aggiunta della menzione «Mi piace» non riuscita"),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("Impossibile contrassegnare la notifica come già letta"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("Impossibile contrassegnare la notifica come da leggere"),
    "failedToRenameAspect" : m10,
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Impossibile rispondere alla conversazione"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("Creazione della segnalazione non riuscita"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Creazione della segnalazione non riuscita"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Ricondivisione del post non riuscita"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Impossibile cercare gli indirizzi"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Iscrizione al post non riuscita"),
    "failedToUnblockUser" : m11,
    "failedToUnfollowTag" : m12,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("Eliminazione della menzione «Mi piace» non riuscita"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("Cancellazione dell’iscrizione al post non riuscita"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("Impossibile aggiornare gli aspetti"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("Impossibile aggiornare il profilo"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("Impossibile caricare la foto"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("Impossibile caricare l’immagine del profilo"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("Impossibile votare"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("Etichette seguite"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("Grassetto"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("Corsivo"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("Barrato"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("Nascondi"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("Elenco puntato"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("Inserisci"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("Codice"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("Blocco di codice"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("Etichetta"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("Intestazione"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("URL immagine"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("Incorpora un’immagine"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("Collegamento"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("Descrizione (facoltativa)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("Inserisci un collegamento"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("URL"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("Menzione"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("Elenco numerato"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("Citazione"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("Inserisci un ID diaspora* completo"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("Mi piace"),
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("Gestisci le etichette seguite"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("Menziona l’utente"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("Scrivi messaggio"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("Contatti"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("Conversazioni"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("Modifica il profilo"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("Notifiche"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("Cerca"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("Flusso"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("Cambia utente"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("Messaggio"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("Destinatari"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("Oggetto"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("Inizia una nuova conversazione"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("No"),
    "noItems" : MessageLookupByLibrary.simpleMessage("Che peccato, niente da mostrare!"),
    "notificationActorsForThreePeople" : m15,
    "notificationActorsForTwoPeople" : m16,
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("post eliminato"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("post"),
    "oEmbedAuthor" : m27,
    "oEmbedHeader" : m28,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Cerca una persona"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Inserisci una risposta"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Inserisci una domanda"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("Visualizza i risultati"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Informazioni"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Post"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Pubblica il post"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("Tutti gli aspetti"),
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Seleziona la visibilità del post"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Pubblico"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Scrivi un nuovo post"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Rispondi"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("Segnala"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("Si prega di descrivere il problema"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("Segnala il commento"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Segnala"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Si prega di descrivere il problema"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Segnala il post"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Ricondividere il post?"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("Ricondivisioni"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("Salva"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("Cerca"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("Inserisci un’etichetta"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("Inizia a digitare un nome o un ID diaspora*"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("Inizia a digitare l’etichetta"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("Persone"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("Persone per etichetta"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("Etichette"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Seleziona tutto"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("Seleziona"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("Invia"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("Segnalazione inviata."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Segnalazione inviata."),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("Mostra il post originariamente ricondiviso"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Mostra questo post"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Accedi"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("nomeutente@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("ID diaspora*"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Abilita le notifiche"),
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("Attività"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("Aspetti"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("Commentati"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("Etichette seguite"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("Piaciuti"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("Flusso"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("Menzioni"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("Etichetta"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("Invia"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Cerca un’etichetta"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("Scatta una nuova foto"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("Scatta una foto"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("Sblocca"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("Profilo aggiornato."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("Carica nuova immagine"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("Carica una foto"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("Modifica immagine di profilo"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("Vota"),
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Sì")
  };
}
