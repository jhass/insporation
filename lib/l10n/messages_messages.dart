// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  static m0(count) => "${Intl.plural(count, zero: 'No aspects', one: 'One aspect', other: '${count} aspects')}";

  static m1(name) => "Select aspects for ${name}";

  static m2(name) => "Delete aspect ${name}?";

  static m3(name) => "${name} already is a recipient, cannot add them twice.";

  static m4(name) => "${name} is not sharing with you, cannot add them as a recipient!";

  static m5(name) => "You\'re not sharing with ${name}, cannot add them as a recipient!";

  static m6(name) => "Failed to remove aspect ${name}";

  static m7(tag) => "Failed to follow #${tag}";

  static m8(oldName, newName) => "Failed to rename aspect ${oldName} to ${newName}";

  static m9(tag) => "Failed to unfollow #${tag}";

  static m10(count) => "${Intl.plural(count, zero: 'In no aspects', one: 'In one aspect', other: 'In ${count} aspects')}";

  static m11(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} and no others', one: '${first}, ${second} and one more', other: '${first}, ${second} and ${othersCount} others')}";

  static m12(first, second, third) => "${first}, ${second} and ${third}";

  static m13(first, second) => "${first} and ${second}";

  static m14(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody also commented on a ${target}.', one: '${actors} also commented on ${target}.', other: '${actors} also commented on ${target}.')}";

  static m15(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody has their birthday today.', one: '${actors} has their birthday today.', other: '${actors} have their birthday your today.')}";

  static m16(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody commented on your ${target}.', one: '${actors} commented your ${target}.', other: '${actors} commented your ${target}.')}";

  static m17(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody liked your ${target}.', one: '${actors} liked your ${target}.', other: '${actors} liked your ${target}.')}";

  static m18(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a comment.', one: '${actors} mentioned you in a comment.', other: '${actors} mentioned you in a comment.')}";

  static m19(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a comment on a deleted post.', one: '${actors} mentioned you in a comment on a deleted post.', other: '${actors} mentioned you in a comment on a deleted post.')}";

  static m20(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody mentioned you in a ${target}.', one: '${actors} mentioned you in a ${target}.', other: '${actors} mentioned you in a ${target}.')}";

  static m21(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'Nobody reshared your ${target}.', one: '${actors} reshared your ${target}.', other: '${actors} reshared your ${target}.')}";

  static m22(actorCount, actors) => "${Intl.plural(actorCount, zero: 'Nobody started sharing with you.', one: '${actors} started sharing with you.', other: '${actors} started sharing with you.')}";

  static m23(author) => "NSFW post by ${author}";

  static m24(author) => "by ${author}";

  static m25(author, provider) => "${author} on ${provider}:";

  static m26(count) => "${Intl.plural(count, zero: 'No aspects', one: 'One aspect', other: '${count} aspects')}";

  static m27(name) => "Started sharing with ${name}.";

  static m28(name) => "Stopped sharing with ${name}.";

  static m29(count) => "${Intl.plural(count, zero: 'No votes so far', one: '1 vote so far', other: '${count} votes so far')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
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
    "deletePrompt" : MessageLookupByLibrary.simpleMessage("Delete post?"),
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("Reshare of a deleted post"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("Deselect all"),
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
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("Failed to add recipient"),
    "failedToAddConversationParticipantDuplicate" : m3,
    "failedToAddConversationParticipantNotSharing" : m4,
    "failedToAddConversationParticipantNotSharingWith" : m5,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("Failed to create comment"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("Failed to create aspect"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("Failed to create conversation"),
    "failedToDeleteAspect" : m6,
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("Failed to delete the post"),
    "failedToFollowTag" : m7,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("Failed to hide conversation"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("Failed to hide the post"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("Failed to like the post"),
    "failedToRenameAspect" : m8,
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("Failed to reply to conversation"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("Failed to create report"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("Failed to reshare post"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("Failed to search for addresses"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("Failed to subscribe to the post"),
    "failedToUnfollowTag" : m9,
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
    "manageContact" : m10,
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
    "notificationActorsForMoreThanThreePeople" : m11,
    "notificationActorsForThreePeople" : m12,
    "notificationActorsForTwoPeople" : m13,
    "notificationAlsoCommented" : m14,
    "notificationBirthday" : m15,
    "notificationCommented" : m16,
    "notificationLiked" : m17,
    "notificationMentionedInComment" : m18,
    "notificationMentionedInCommentOnDeletedPost" : m19,
    "notificationMentionedInPost" : m20,
    "notificationReshared" : m21,
    "notificationStartedSharing" : m22,
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("deleted post"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("post"),
    "nsfwShieldTitle" : m23,
    "oEmbedAuthor" : m24,
    "oEmbedHeader" : m25,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("Search for person"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("Enter an answer"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("Enter a question"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("View results"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("Info"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("Posts"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("Publish post"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("All aspects"),
    "publishTargetAspects" : m26,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("Select post visibility"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("Public"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("Write a new post"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("Remove"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("Reply"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("Report"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("Please describe the issue"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("Report post"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("Reshare post?"),
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
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("Report sent."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("Show all NSFW posts"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("Show this post"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("Sign in"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("username@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("diaspora* ID"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("Enable notifications"),
    "startedSharing" : m27,
    "stoppedSharing" : m28,
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
    "voteCount" : m29,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("Yes")
  };
}
