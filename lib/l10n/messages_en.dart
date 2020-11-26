// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(count) => "${Intl.plural(count, zero: 'No aspects', one: 'One aspect', other: '${count} aspects')}";

  static m1(name) => "Select aspects for ${name}";

  static m2(name) => "Delete aspect ${name}?";

  static m3(userId) => "Remove session for ${userId} from insporation*?";

  static m33(userId) => "Could not authorize to ${userId}, is it spelled correctly, is your network working and is your pod running the latest development snapshot?";

  static m4(name) => "${name} already is a recipient, cannot add them twice.";

  static m5(name) => "${name} is not sharing with you, cannot add them as a recipient!";

  static m6(name) => "You\'re not sharing with ${name}, cannot add them as a recipient!";

  static m7(name) => "Failed to block ${name}";

  static m8(name) => "Failed to remove aspect ${name}";

  static m9(tag) => "Failed to follow #${tag}";

  static m10(oldName, newName) => "Failed to rename aspect ${oldName} to ${newName}";

  static m11(name) => "Failed to unblock ${name}";

  static m12(tag) => "Failed to unfollow #${tag}";

  static m13(count) => "${Intl.plural(count, zero: 'In no aspects', one: 'In one aspect', other: 'In ${count} aspects')}";

  static m14(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} and no others', one: '${first}, ${second} and one more', other: '${first}, ${second} and ${othersCount} others')}";

  static m15(first, second, third) => "${first}, ${second} and ${third}";

  static m16(first, second) => "${first} and ${second}";

  static m17(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody also commented on a ${target}.', one: '${actors} also commented on ${target}.', other: '${actors} also commented on ${target}.')}";

  static m18(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody has their birthday today.', one: '${actors} has their birthday today.', other: '${actors} have their birthday your today.')}";

  static m19(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody commented on your ${target}.', one: '${actors} commented your ${target}.', other: '${actors} commented your ${target}.')}";

  static m20(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody liked your ${target}.', one: '${actors} liked your ${target}.', other: '${actors} liked your ${target}.')}";

  static m21(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a comment.', one: '${actors} mentioned you in a comment.', other: '${actors} mentioned you in a comment.')}";

  static m22(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a comment on a deleted post.', one: '${actors} mentioned you in a comment on a deleted post.', other: '${actors} mentioned you in a comment on a deleted post.')}";

  static m23(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a ${target}.', one: '${actors} mentioned you in a ${target}.', other: '${actors} mentioned you in a ${target}.')}";

  static m24(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody reshared your ${target}.', one: '${actors} reshared your ${target}.', other: '${actors} reshared your ${target}.')}";

  static m25(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody started sharing with you.', one: '${actors} started sharing with you.', other: '${actors} started sharing with you.')}";

  static m26(author) => "NSFW post by ${author}";

  static m27(author) => "by ${author}";

  static m28(author, provider) => "${author} on ${provider}:";

  static m29(count) => "${Intl.plural(count, zero: 'No aspects', one: 'One aspect', other: '${count} aspects')}";

  static m30(name) => "Started sharing with ${name}.";

  static m31(name) => "Stopped sharing with ${name}.";

  static m32(count) => "${Intl.plural(count, zero: 'No votes so far', one: '1 vote so far', other: '${count} votes so far')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "CatcherLocalization_dialogReportModeAccept" : MessageLookupByLibrary.simpleMessage("Send report"),
    "CatcherLocalization_dialogReportModeCancel" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "CatcherLocalization_dialogReportModeDescription" : MessageLookupByLibrary.simpleMessage("An unexpected error occurred, an error report is ready to be send to the developers."),
    "CatcherLocalization_dialogReportModeTitle" : MessageLookupByLibrary.simpleMessage("insporation* crashed :("),
    "addContact" : MessageLookupByLibrary.simpleMessage("Add contact"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("Add your location"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("Add a poll"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("Enter a name"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("All aspects"),
    "aspectStreamSelectorAspects" : m0,
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("Aspects"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("Select aspects"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("Block"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("Stop notifications"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("Comments"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Confirm delete"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("Reshare"),
    "contactAspectsPrompt" : m1,
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("Aspects updated."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("You blocked them"),
    "contactStatusMutual" : MessageLookupByLibrary.simpleMessage("You are sharing with each other"),
    "contactStatusNotSharing" : MessageLookupByLibrary.simpleMessage("You are not sharing with each other."),
    "contactStatusReceiving" : MessageLookupByLibrary.simpleMessage("They are sharing with you."),
    "contactStatusSharing" : MessageLookupByLibrary.simpleMessage("You are sharing with them."),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("Create an aspect"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("Create"),
    "createComment" : MessageLookupByLibrary.simpleMessage("Comment"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("Create poll"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("Delete comment?"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("Delete post?"),
    "deleteSessionPrompt" : m3,
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Reshare of a deleted post"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Deselect all"),
    "detailsOnErrorCopied" : MessageLookupByLibrary.simpleMessage("Error details copied to clipboard."),
    "detailsOnErrorDescription" : MessageLookupByLibrary.simpleMessage("The following internal error occurred. Please include this when asking for help."),
    "detailsOnErrorLabel" : MessageLookupByLibrary.simpleMessage("Help"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("Tag already added"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("Edit aspect"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("Edit poll"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("Edit profile"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("Birthday"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("Gender"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("Edit profile"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("Location"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("Name"),
    "editProfileNsfwLabel" : MessageLookupByLibrary.simpleMessage("Mark profile as #nsfw?"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("Make profile info public?"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("Allow to be searched for?"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("Update profile"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("Tags"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("Edit profile"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("Enter an address"),
    "errorAuthorizationFailed" : m33,
    "errorNetworkErrorOnAuthorization" : MessageLookupByLibrary.simpleMessage("A network error occurred, please ensure that you spelled your pod correctly and that you have a good reception, then try again."),
    "errorSignInTimeout" : MessageLookupByLibrary.simpleMessage("Timeout while trying to authorize, are you sure your pod supports the API?"),
    "errorUnexpectedErrorOnAuthorization" : MessageLookupByLibrary.simpleMessage("An unexpected error happened while trying to sign in."),
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("Failed to add recipient"),
    "failedToAddConversationParticipantDuplicate" : m4,
    "failedToAddConversationParticipantNotSharing" : m5,
    "failedToAddConversationParticipantNotSharingWith" : m6,
    "failedToBlockUser" : m7,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Failed to create comment"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Failed to create aspect"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("Failed to create conversation"),
    "failedToDeleteAspect" : m8,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("Failed to delete comment"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Failed to delete the post"),
    "failedToFollowTag" : m9,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Failed to hide conversation"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Failed to hide the post"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Failed to like the post"),
    "failedToLoadContent" : MessageLookupByLibrary.simpleMessage("An error occured while trying to load the content."),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("Failed to mark notification as read"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("Failed to mark notification as unread"),
    "failedToRenameAspect" : m10,
    "failedToRenderMessage" : MessageLookupByLibrary.simpleMessage("Could not render this content. Please report this with the error details below, if present."),
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Failed to reply to conversation"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("Failed to create the report"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Failed to create report"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Failed to reshare post"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Failed to search for addresses"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Failed to subscribe to the post"),
    "failedToUnblockUser" : m11,
    "failedToUnfollowTag" : m12,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("Failed to unlike the post"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("Failed to unsubscribe from the post"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("Failed to update aspects"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("Failed to update profile"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("Failed to upload photo"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("Failed to upload profile picture"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("Failed to vote on post"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("Followed tags"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("Bold"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("Italic"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("Strikethrough"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("Hide"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("Bulleted list"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("Insert"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("Code"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("Code block"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("Hashtag"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("Heading"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("Image URL"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("Embed an image"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("Link"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("Description (optional)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("Insert a link"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("URL"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("Mention"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("Numbered list"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("Quote"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("Enter a full diaspora* ID"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("Likes"),
    "manageContact" : m13,
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("Manage followed tags"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("Mention user"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("Message"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("Contacts"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("Conversations"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("Edit profile"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("Notifications"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("Search"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("Stream"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("Switch user"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("Message"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("Recipients"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("Subject"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("Start a new conversation"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("No"),
    "noItems" : MessageLookupByLibrary.simpleMessage("Darn, nothing to display!"),
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
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("deleted post"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("post"),
    "nsfwShieldTitle" : m26,
    "oEmbedAuthor" : m27,
    "oEmbedHeader" : m28,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Search for person"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Enter an answer"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Enter a question"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("View results"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Info"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Posts"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Publish post"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("All aspects"),
    "publishTargetAspects" : m29,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Select post visibility"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Public"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Write a new post"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Remove"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Reply"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("Report"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("Please describe the issue"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("Report comment"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Report"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Please describe the issue"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Report post"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Reshare post?"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("Reshares"),
    "retryLabel" : MessageLookupByLibrary.simpleMessage("Retry"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("Save"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("Search"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("Enter a tag"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("Start typing a name or diaspora* ID"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("Start typing tag"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("People"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("People by tag"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("Tags"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Select all"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("Select"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("Send"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("Report sent."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Report sent."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("Show all NSFW posts"),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("Show the originally reshared post"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Show this post"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Sign in"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("username@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("diaspora* ID"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Enable notifications"),
    "startedSharing" : m30,
    "stoppedSharing" : m31,
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("Activity"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("Aspects"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("Commented"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("Followed tags"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("Liked"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("Stream"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("Mentions"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("Tag"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("Submit"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Search for a tag"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("Take new picture"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("Take a photo"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("Unblock"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("Profile updated."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("Upload new picture"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("Upload a photo"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("Update profile picture"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("Vote"),
    "voteCount" : m32,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Yes")
  };
}
