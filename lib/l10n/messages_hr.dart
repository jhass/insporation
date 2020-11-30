// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a hr locale. All the
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
  String get localeName => 'hr';

  static m0(count) => "${Intl.plural(count, zero: 'Nema aspekata', one: 'Jedan aspekt', other: '${count} aspekta')}";

  static m1(name) => "Odaberi askpekte za ${name}";

  static m2(name) => "Isbrisati aspekt ${name}?";

  static m3(userId) => "Ukloniti sesiju za ${userId} iz insporation*?";

  static m33(userId) => "Nije moguće autorizirati ${userId}. Provjeri unos, provjeri tvoju mrežu i provjeri je li tvoj „pod” pokreće najnoviju snimku razvoja?";

  static m4(name) => "${name} već je primatelj. Ne može se dvaput dodati.";

  static m5(name) => "${name} ne dijeli s tobom. Ne mogu se dodati kao primatelji!";

  static m6(name) => "Ne dijeliš s ${name}. Ne mogu se dodati kao primatelji!";

  static m7(name) => "Neuspjelo blokiranje korisnika ${name}";

  static m8(name) => "Neuspjelo uklanjanje aspekta ${name}";

  static m9(tag) => "Neuspjelo praćenje oznake #${tag}";

  static m10(oldName, newName) => "Neuspjelo preimenovanje aspekta ${oldName} u ${newName}";

  static m11(name) => "Neuspjelo deblokiranje korisnika ${name}";

  static m12(tag) => "Neuspjelo uklanjanje praćenja oznake #${tag}";

  static m13(count) => "${Intl.plural(count, zero: 'U nijednom aspektu', one: 'U jednom aspektu', other: 'U ${count} aspekta')}";

  static m14(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} i nitko drugi', one: '${first}, ${second} i još jedan', other: '${first}, ${second} i još ${othersCount}')}";

  static m15(first, second, third) => "${first}, ${second} i ${third}";

  static m16(first, second) => "${first} i ${second}";

  static m17(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nitko nije komentirao ${target}.', one: '${actors} je također komentirao ${target}.', other: '${actors} su također komentirali ${target}.')}";

  static m18(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Danas nitko nema rođendan.', one: '${actors} ima danas rođendan.', other: '${actors} imaju danas rođendan.')}";

  static m19(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nitko nije komentirao tvoju ${target}.', one: '${actors} je komentirao tvoju ${target}.', other: '${actors} su komentirali tvoju ${target}.')}";

  static m20(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nikome se ne sviđa tvoja objava ${target}.', one: '${actors} se sviđa tvoja objava ${target}.', other: '${actors} se sviđa tvoja objava ${target}.')}";

  static m21(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nitko te nije spomenuo u komentaru.', one: '${actors} te je spomenuo u komentaru.', other: '${actors} te je spomenulo u komentaru.')}";

  static m22(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nitko te nije spomenuo u komentaru izbrisane objave.', one: '${actors} te je spomenuo u komentaru izbrisane objave.', other: '${actors} te je spomenulo u komentaru izbrisane objave.')}";

  static m23(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nitko te nije spomenuo u ${target}.', one: '${actors} te je spomenuo u ${target}.', other: '${actors} su te spomenuli u ${target}.')}";

  static m24(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nitko nije proslijedio tvoju objavu ${target}.', one: '${actors} je proslijedio tvoju objavu ${target}.', other: '${actors} je proslijedilo tvoju objavu ${target}.')}";

  static m25(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nitko nije počeo s tobom dijeliti.', one: '${actors} je s tobom počeo dijeliti.', other: '${actors} su s tobom počeli dijeliti.')}";

  static m26(author) => "NSFW objava od ${author}";

  static m27(author) => "od ${author}";

  static m28(author, provider) => "${author} na ${provider}:";

  static m29(count) => "${Intl.plural(count, zero: 'Nema aspekata', one: 'Jedan aspekt', other: '${count} aspekta')}";

  static m30(name) => "Započeto dijeljenje s ${name}.";

  static m31(name) => "Prekinuto dijeljenje s ${name}.";

  static m32(count) => "${Intl.plural(count, zero: 'Do sada nema glasova', one: '1 glas do sada', other: '${count} glasova do sada')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "CatcherLocalization_dialogReportModeAccept" : MessageLookupByLibrary.simpleMessage("Pošalji izvještaj"),
    "CatcherLocalization_dialogReportModeCancel" : MessageLookupByLibrary.simpleMessage("Odbaci"),
    "CatcherLocalization_dialogReportModeDescription" : MessageLookupByLibrary.simpleMessage("Dogodila se neočekivana greška. Izvještaj o grešci je spreman za slanje programerima."),
    "CatcherLocalization_dialogReportModeTitle" : MessageLookupByLibrary.simpleMessage("insporation* je prekinuo rad :("),
    "addContact" : MessageLookupByLibrary.simpleMessage("Dodaj kontakt"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("Dodaj tvoju lokaciju"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("Dodaj anketu"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("Upiši ime"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("Svi aspekti"),
    "aspectStreamSelectorAspects" : m0,
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("Aspekti"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("Odaberi askpekte"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Blokiraj"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("Prekini obavijesti"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("Komentari"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Potvrdi brisanje"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("Proslijedi"),
    "contactAspectsPrompt" : m1,
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("Aspekti su aktualizirani."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("Blokiraš ih"),
    "contactStatusMutual" : MessageLookupByLibrary.simpleMessage("Dijelite uzajamno"),
    "contactStatusNotSharing" : MessageLookupByLibrary.simpleMessage("Ne dijelite uzajamno."),
    "contactStatusReceiving" : MessageLookupByLibrary.simpleMessage("Dijele s tobom."),
    "contactStatusSharing" : MessageLookupByLibrary.simpleMessage("Dijeliš s njima."),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("Stvori aspekt"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("Stvori"),
    "createComment" : MessageLookupByLibrary.simpleMessage("Komentiraj"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("Stvori anketu"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("Isbrisati komentar?"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("Isbrisati objavu?"),
    "deleteSessionPrompt" : m3,
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Proslijedi izbrisanu objavu"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Odznači sve"),
    "detailsOnErrorCopied" : MessageLookupByLibrary.simpleMessage("Detalji greške su kopirani u međuspremnik."),
    "detailsOnErrorDescription" : MessageLookupByLibrary.simpleMessage("Dogodila se sljedeća interna greška. Uključi ove podatke kad zatražiš pomoć."),
    "detailsOnErrorLabel" : MessageLookupByLibrary.simpleMessage("Pomoć"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("Oznaka je već dodana"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("Uredi aspekt"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("Uredi anketu"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("Uredi profil"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("Rođendan"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("Spol"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("Uredi profil"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("Lokacija"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("Ime"),
    "editProfileNsfwLabel" : MessageLookupByLibrary.simpleMessage("Označiti profil kao #nsfw?"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("Javno prikazati podatke profila?"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("Dozvoliti pretraživanje?"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("Aktualiziraj profil"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("Oznake"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("Uredi profil"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("Upiši adresu"),
    "errorAuthorizationFailed" : m33,
    "errorNetworkErrorOnAuthorization" : MessageLookupByLibrary.simpleMessage("Dogodila se mrežna greška. Provjeri ispravnost tvog „poda” i kvalitetu prijema. Zatim pokušaj ponovo."),
    "errorSignInTimeout" : MessageLookupByLibrary.simpleMessage("Vrijeme pokušaja autorizacije je isteklo. Je li tvoj „pod” podržava API?"),
    "errorUnexpectedErrorOnAuthorization" : MessageLookupByLibrary.simpleMessage("Došlo je do neočekivane greške prilikom pokušaja prijave."),
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("Neuspjelo dodavanje primatelja"),
    "failedToAddConversationParticipantDuplicate" : m4,
    "failedToAddConversationParticipantNotSharing" : m5,
    "failedToAddConversationParticipantNotSharingWith" : m6,
    "failedToBlockUser" : m7,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Neuspjelo stvaranje komentara"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Neuspjelo stvaranje aspekta"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("Neuspjelo stvaranje konverzacije"),
    "failedToDeleteAspect" : m8,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("Neuspjelo brisanje komentara"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Neuspjelo brisanje objave"),
    "failedToFollowTag" : m9,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Neuspjelo skrivanje konverzacije"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Neuspjelo skrivanje objave"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Neuspjelo označivanje sa „Sviđa mi se”"),
    "failedToLoadContent" : MessageLookupByLibrary.simpleMessage("Dogodila se greška prilikom pokušaja učitavanja sadržaja."),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("Neuspjelo označivanje obavijesti kao pročitane"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("Neuspjelo označivanje obavijesti kao nepročitane"),
    "failedToRenameAspect" : m10,
    "failedToRenderMessage" : MessageLookupByLibrary.simpleMessage("Nije moguće prikazati ovaj sadržaj. Prijavi ovaj problem s dolje navedenim detaljima greške, ako postoje."),
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Neuspjelo odgovaranje u konverzaciji"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("Neuspjelo stvaranje izvještaja"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Neuspjelo stvaranje izvještaja"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Neuspjelo prosljeđivanje objave"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Neuspjelo traženje adresa"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Neuspjelo pretplaćivanje na objavu"),
    "failedToUnblockUser" : m11,
    "failedToUnfollowTag" : m12,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("Neuspjelo uklanjanje oznake sviđanja"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("Neuspjelo otkazivanje pretplate na objavu"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("Neuspjelo aktualiziranje aspekata"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("Neuspjelo aktualiziranje profila"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("Neuspjelo prenošenje slike"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("Neuspjelo prenošenje slike profila"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("Neuspjelo glasanje za objavu"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("Praćene oznake"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("Podebljano"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("Kurziv"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("Precrtano"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("Sakrij"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("Nenumerirani popis"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("Umetni"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("Kȏd"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("Blok koda"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("Hashtag"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("Naslov"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("URL adresa slike"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("Ugradi sliku"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("Poveznica"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("Opis (opcionalno)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("Umetni poveznicu"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("URL"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("Spominjanje"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("Numerirani popis"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("Citiranje"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("Upiši potpunu diaspora* ID oznaku"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("Sviđanja"),
    "manageContact" : m13,
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("Upravljaj praćenim oznakama"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("Spomeni korisnika"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("Poruka"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("Kontakti"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("Konverzacije"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("Uredi profil"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("Obavijesti"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("Traži"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("Kanal"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("Zamijeni korisnika"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("Poruka"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("Primatelji"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("Tema"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("Započni novu konverzaciju"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("Ne"),
    "noItems" : MessageLookupByLibrary.simpleMessage("K vragu, nema se što prikazati!"),
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
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("izbrisana objava"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("objava"),
    "nsfwShieldTitle" : m26,
    "oEmbedAuthor" : m27,
    "oEmbedHeader" : m28,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Traži osobu"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Upiši odgovor"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Upiši pitanje"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("Prikaz rezultata"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Podaci"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Objave"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Objavi"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("Svi aspekti"),
    "publishTargetAspects" : m29,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Odaberi vidljivost objave"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Javno"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Napiši novu objavu"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Ukloni"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Odgovori"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("Prijavi"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("Opiši problem"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("Komentar za prijavu"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Prijavi"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Opiši problem"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Prijavi objavu"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Prosljediti objavu?"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("Proslijeđeno"),
    "retryLabel" : MessageLookupByLibrary.simpleMessage("Ponovi"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("Spremi"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("Traži"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("Upiši oznaku"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("Počni upisivati ime ili diaspora* ID"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("Počni upisivati oznaku"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("Ljudi"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("Ljudi po oznakama"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("Oznake"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Označi sve"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("Označi"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("Pošalji"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("Prijava poslana."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Prijava poslana."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("Pokaži sve NSFW objave"),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("Pokaži izvornu proslijeđenu objavu"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Pokaži ovu objavu"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Prijava"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("korisničkoime@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("diaspora* ID"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Aktiviraj obavijesti"),
    "startedSharing" : m30,
    "stoppedSharing" : m31,
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("Aktivnost"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("Aspekti"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("Komentirani"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("Praćene oznake"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("Sviđa mi se"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("Kanal"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("Spominjanja"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("Oznaka"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("Pošalji"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Traži oznaku"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("Snimi novu sliku"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("Snimi sliku"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("Deblokiraj"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("Profil je aktualiziran."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("Prenesi novu sliku"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("Prenesi sliku"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("Aktualiziraj sliku profila"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("Glasaj"),
    "voteCount" : m32,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Da")
  };
}
