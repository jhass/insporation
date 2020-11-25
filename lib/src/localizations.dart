import 'dart:ui';

import 'package:catcher/model/localization_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';
import 'posts.dart';
import 'timeago.dart';

// Keep timeagoLocaleMessages in timeago.dart in sync!
// Keep catcherLocalizationOptions below in sync!
// Add iOS specific translation files to the project via "Add Files to"
const supportedLocales = [
  const Locale('ar'),
  const Locale('de'),
  const Locale('en'),
  const Locale('fr'),
  const Locale('hr'),
  const Locale('it')
];


final catcherLocalizationOptions = [
  CatcherLocalization('ar'),
  CatcherLocalization('de'),
  CatcherLocalization('en'),
  CatcherLocalization('fr', defaults: LocalizationOptions.buildDefaultFrenchOptions()),
  CatcherLocalization('hr'),
  CatcherLocalization('it', defaults: LocalizationOptions.buildDefaultItalianOptions())
];

mixin LocalizationHelpers {
  InsporationLocalizations l(BuildContext context) => InsporationLocalizations.of(context);

  MaterialLocalizations ml(BuildContext context) => MaterialLocalizations.of(context);
}

class InsporationLocalizations {
  static const LocalizationsDelegate<InsporationLocalizations> delegate = _InsporationLocalizationsDelegate();

  InsporationLocalizations(this.localeName);

  static Future<InsporationLocalizations> load(Locale locale) {
    final String localeName = Intl.canonicalizedLocale(locale.toString());

    return initializeMessages(localeName).then((_) {
      return InsporationLocalizations(localeName);
    });
  }

  static InsporationLocalizations of(BuildContext context) {
    return Localizations.of<InsporationLocalizations>(context, InsporationLocalizations);
  }

  final String localeName;

  String get saveButtonLabel => Intl.message(
    'Save',
    name: 'saveButtonLabel',
    desc: 'Label for a dialog save button',
    locale: localeName
  );

  String get submitButtonLabel => Intl.message(
    'Submit',
    name: 'submitButtonLabel',
    desc: 'Label for a dialog submit button',
    locale: localeName
  );

  String get createButtonLabel => Intl.message(
    'Create',
    name: 'createButtonLabel',
    desc: 'Label for a dialog create button',
    locale: localeName
  );

  String get insertButtonLabel => Intl.message(
    'Insert',
    name: 'insertButtonLabel',
    desc: 'Label for a dialog insert button',
    locale: localeName
  );

  String get yesButtonLabel => Intl.message(
    'Yes',
    name: 'yesButtonLabel',
    desc: 'Label for a dialog yes button',
    locale: localeName
  );

  String get noButtonLabel => Intl.message(
    'No',
    name: 'noButtonLabel',
    desc: 'Label for a dialog no button',
    locale: localeName
  );

  String get retryLabel => Intl.message(
    'Retry',
    name: 'retryLabel',
    desc: 'Label for a retry button',
    locale: localeName
  );

  String get confirmDeleteButtonLabel => Intl.message(
    'Confirm delete',
    name: 'confirmDeleteButtonLabel',
    desc: 'Label for a dialog confirm delete button',
    locale: localeName
  );

  String get removeButtonLabel => Intl.message(
    'Remove',
    name: 'removeButtonLabel',
    desc: 'Label for a dialog remove button',
    locale: localeName
  );

  String get selectButtonLabel => Intl.message(
    'Select',
    name: 'selectButtonLabel',
    desc: 'Label for a dialog select button',
    locale: localeName
  );

  String get selectAllButtonLabel => Intl.message(
    'Select all',
    name: 'selectAllButtonLabel',
    desc: 'Label for a select all button',
    locale: localeName
  );

  String get deselectAllButtonLabel => Intl.message(
    'Deselect all',
    name: 'deselectAllButtonLabel',
    desc: 'Label for a deselect all button',
    locale: localeName
  );

  String get detailsOnErrorLabel => Intl.message(
    'Help',
    name: 'detailsOnErrorLabel',
    desc: 'Label for the show details button in error messages',
    locale: localeName
  );

  String get detailsOnErrorDescription => Intl.message(
    'The following internal error occurred. Please include this when asking for help.',
    name: 'detailsOnErrorDescription',
    desc: 'Label for the show details button in error messages',
    locale: localeName
  );

  String get detailsOnErrorCopied => Intl.message(
    'Error trace copied to clipboard.',
    name: 'detailsOnErrorCopied',
    desc: 'Success message after error details were copied to clipboard',
    locale: localeName
  );

  String get signInAction => Intl.message(
    'Sign in',
    name: 'signInAction',
    desc: 'Sign in button label',
    locale: localeName
  );

  String get signInLabel => Intl.message(
    'diaspora* ID',
    name: 'signInLabel',
    desc: 'Label for sign in field',
    locale: localeName
  );

  String get signInHint => Intl.message(
    'username@diaspora.pod',
    name: 'signInHint',
    desc: 'Hint text for sign in field',
    locale: localeName,
  );

  String get invalidDiasporaId => Intl.message(
    'Enter a full diaspora* ID',
    name: 'invalidDiasporaId',
    desc: 'Error message after an invalid diaspora* ID was entered',
    locale: localeName
  );

  String get errorSignInTimeout => Intl.message(
    'Timeout while trying to authorize, are you sure your pod supports the API?', // TODO update after AppAuth-Android#611
    name: 'errorSignInTimeout',
    desc: 'Error message after authorization timed out',
    locale: localeName
  );

  String errorAuthorizationFailed(String userId) => Intl.message(
      'Could not authorize to $userId, is it spelled correctly, is your network working and is your pod running the latest development snapshot?', // TODO update message after diaspora 0.8 release
      args: [userId],
      name: 'errorAuthorizationFailed',
      desc: 'Error message after authorization failed',
      examples: const {'userId': 'user@example.org'},
      locale: localeName
  );

  String get errorNetworkErrorOnAuthorization => Intl.message(
      'A network error occurred, please ensure that you spelled your pod correctly and that you have a good reception, then try again.',
      name: 'errorNetworkErrorOnAuthorization',
      desc: 'Error message after a network error occurred during authorization',
      locale: localeName
  );

  String get errorUnexpectedErrorOnAuthorization => Intl.message(
    'An unexpected error happened while trying to sign in.',
    name: 'errorUnexpectedErrorOnAuthorization',
    desc: 'Error message after an unexpected error happened during authorization',
    locale: localeName
  );

  String deleteSessionPrompt(String userId) => Intl.message(
    'Remove session for $userId from insporation*?',
    name: 'deleteSessionPrompt',
    args: [userId],
    desc: 'Title for delete session prompt dialog',
    examples: const {'userId': 'user@example.org'},
    locale: localeName
  );

  String get navigationItemTitleStream => Intl.message(
    'Stream',
    name: 'navigationItemTitleStream',
    desc: 'Title for the Stream navigation item',
    locale: localeName
  );

  String get navigationItemTitleConversations => Intl.message(
    'Conversations',
    name: 'navigationItemTitleConversations',
    desc: 'Title for the Conversations navigation item',
    locale: localeName
  );

  String get navigationItemTitleSearch => Intl.message(
    'Search',
    name: 'navigationItemTitleSearch',
    desc: 'Title for the search navigation item',
    locale: localeName
  );

  String get navigationItemTitleNotifications => Intl.message(
    'Notifications',
    name: 'navigationItemTitleNotifications',
    desc: 'Title for the notifications navigation item',
    locale: localeName
  );

  String get navigationItemTitleContacts => Intl.message(
    'Contacts',
    name: 'navigationItemTitleContacts',
    desc: 'Title for the contacts navigation item',
    locale: localeName
  );

  String get navigationItemTitleEditProfile => Intl.message(
    'Edit profile',
    name: 'navigationItemTitleEditProfile',
    desc: 'Title for the edit profile navigation item',
    locale: localeName
  );

  String get navigationItemTitleSwitchUser => Intl.message(
    'Switch user',
    name: 'navigationItemTitleSwitchUser',
    desc: 'Title for the switch user navigation item',
    locale: localeName
  );

  String streamName(StreamType type) {
    switch (type) {
      case StreamType.main:
        return streamNameMain;
      case StreamType.activity:
        return streamNameActivity;
      case StreamType.aspects:
        return streamNameAspects;
      case StreamType.followedTags:
        return streamNameFollowedTags;
      case StreamType.mentions:
        return streamNameMentions;
      case StreamType.liked:
        return streamNameLiked;
      case StreamType.commented:
        return streamNameCommented;
      case StreamType.tag:
        return streamNameTag;
    }

    assert(false, 'Missing handling for $type');
    return '';
  }

  String get streamNameMain => Intl.message(
    'Stream',
    name: 'streamNameMain',
    desc: 'Name of the main stream',
    locale: localeName
  );

  String get streamNameActivity => Intl.message(
    'Activity',
    name: 'streamNameActivity',
    desc: 'Name of the activity stream',
    locale: localeName
  );

  String get streamNameAspects => Intl.message(
    'Aspects',
    name: 'streamNameAspects',
    desc: 'Name of the aspects stream',
    locale: localeName
  );

  String get streamNameFollowedTags => Intl.message(
    'Followed tags',
    name: 'streamNameFollowedTags',
    desc: 'Name of the followed tags stream',
    locale: localeName
  );

  String get streamNameMentions => Intl.message(
    'Mentions',
    name: 'streamNameMentions',
    desc: 'Name of the mentions stream',
    locale: localeName
  );

  String get streamNameLiked => Intl.message(
    'Liked',
    name: 'streamNameLiked',
    desc: 'Name of the liked stream',
    locale: localeName
  );

  String get streamNameCommented => Intl.message(
    'Commented',
    name: 'streamNameCommented',
    desc: 'Name of the commented stream',
    locale: localeName
  );

  String get streamNameTag => Intl.message(
    'Tag',
    name: 'streamNameTag',
    desc: 'Name of a tag stream',
    locale: localeName
  );

  String get noItems => Intl.message(
    'Darn, nothing to display!',
    name: 'noItems',
    desc: "Fallback message when something didn't return any items",
    locale: localeName
  );

  String get deletedPostReshareHint => Intl.message(
    'Reshare of a deleted post',
    name: 'deletedPostReshareHint',
    desc: 'Fallback message when showing a reshare of a deleted post',
    locale: localeName
  );

  String get createComment => Intl.message(
    'Comment',
    name: 'createComment',
    desc: 'Label for create comment button',
    locale: localeName
  );

  String get commentsHeader => Intl.message(
    'Comments',
    name: 'commentsHeader',
    desc: 'Header for comment stream',
    locale: localeName
  );

  String get failedToCommentOnPost => Intl.message(
    'Failed to create comment',
    name: 'failedToCommentOnPost',
    desc: 'Error message after commenting on a post failed',
    locale: localeName
  );

  String get deleteCommentPrompt => Intl.message(
    'Delete comment?',
    name: 'deleteCommentPrompt',
    desc: 'Title for delete comment prompt dialog',
    locale: localeName
  );

  String get failedToDeleteComment => Intl.message(
    'Failed to delete comment',
    name: 'failedToDeleteComment',
    desc: 'Error message after deleting a comment failed',
    locale: localeName
  );

  String get reportComment => Intl.message(
    'Report',
    name: 'reportComment',
    desc: 'Tooltip for report comment icon button',
    locale: localeName
  );

  String get reportCommentPrompt => Intl.message(
    'Report comment',
    name: 'reportCommentPrompt',
    desc: 'Title for report comment prompt dialog',
    locale: localeName
  );

  String get reportCommentHint => Intl.message(
    'Please describe the issue',
    name: 'reportCommentHint',
    desc: 'Hint text for comment report field',
    locale: localeName
  );

  String get sentCommentReport => Intl.message(
    'Report sent.',
    name: 'sentCommentReport',
    desc: 'Success message after a comment report was sent',
    locale: localeName
  );

  String get failedToReportComment => Intl.message(
    'Failed to create the report',
    name: 'failedToReportComment',
    desc: "Error message after a comment report couldn't be sent",
    locale: localeName
  );

  String get likesHeader => Intl.message(
    'Likes',
    name: 'likesHeader',
    desc: 'Header for likes list',
    locale: localeName
  );

  String get failedToLikePost => Intl.message(
    'Failed to like the post',
    name: 'failedToLikePost',
    desc: 'Error message after liking a post failed',
    locale: localeName
  );

  String get failedToUnlikePost => Intl.message(
    'Failed to unlike the post',
    name: 'failedToUnlikePost',
    desc: 'Error message after unliking a post failed',
    locale: localeName
  );

  String get resharesHeader => Intl.message(
    'Reshares',
    name: 'resharesHeader',
    desc: 'Header for reshares list',
    locale: localeName
  );

  String get resharePrompt => Intl.message(
    'Reshare post?',
    name: 'resharePrompt',
    desc: 'Title for reshare post prompt dialog',
    locale: localeName
  );

  String get confirmReshare => Intl.message(
    'Reshare',
    name: 'confirmReshare',
    desc: 'Label for confirm button in the reshare prompt',
    locale: localeName
  );

  String get failedToResharePost => Intl.message(
    'Failed to reshare post',
    name: 'failedToResharePost',
    desc: 'Error message after resharing a post failed',
    locale: localeName
  );

  String get startPostSubscription => Intl.message(
    'Enable notifications',
    name: 'startPostSubscription',
    desc: 'Tooltip for start post subscription icon button',
    locale: localeName
  );

  String get cancelPostSubscription => Intl.message(
    'Stop notifications',
    name: 'cancelPostSubscription',
    desc: 'Tooltip for cancel post subscription icon button',
    locale: localeName
  );

  String get failedToSubscribeToPost => Intl.message(
    'Failed to subscribe to the post',
    name: 'failedToSubscribeToPost',
    desc: 'Error message after failing to subscribe to a post',
    locale: localeName
  );

  String get failedToUnsubscribeFromPost => Intl.message(
    'Failed to unsubscribe from the post',
    name: 'failedToUnsubscribeFromPost',
    desc: 'Error message after failing to unsubscribe from a post',
    locale: localeName
  );

  String get deletePostPrompt => Intl.message(
    'Delete post?',
    name: 'deletePostPrompt',
    desc: 'Title for delete post prompt dialog',
    locale: localeName
  );

  String get failedToDeletePost => Intl.message(
    'Failed to delete the post',
    name: 'failedToDeletePost',
    desc: 'Error message after failing to delete a post',
    locale: localeName
  );

  String get hidePost => Intl.message(
    'Hide',
    name: 'hidePost',
    desc: 'Tooltip for hide post icon button',
    locale: localeName
  );

  String get failedToHidePost => Intl.message(
    'Failed to hide the post',
    name: 'failedToHidePost',
    desc: 'Error message after failing to hide a post',
    locale: localeName
  );

  String get reportPost => Intl.message(
    'Report',
    name: 'reportPost',
    desc: 'Tooltip for report post icon button',
    locale: localeName
  );

  String get reportPostPrompt => Intl.message(
    'Report post',
    name: 'reportPostPrompt',
    desc: 'Title for report post prompt dialog',
    locale: localeName
  );

  String get reportPostHint => Intl.message(
    'Please describe the issue',
    name: 'reportPostHint',
    desc: 'Hint text for post report field',
    locale: localeName
  );

  String get sentPostReport => Intl.message(
    'Report sent.',
    name: 'sentPostReport',
    desc: 'Success message after a post report was sent',
    locale: localeName
  );

  String get failedToReportPost => Intl.message(
    'Failed to create report',
    name: 'failedToReportPost',
    desc: "Error message after a post report couldn't be sent",
    locale: localeName
  );

  String get showOriginalPost => Intl.message(
    'Show the originally reshared post',
    name: 'showOriginalPost',
    desc: "Tooltip message for the show original post button",
    locale: localeName
  );

  String voteCount(int count) => Intl.plural(
    count,
    zero: 'No votes so far',
    one: '1 vote so far',
    other: '$count votes so far',
    name: 'voteCount',
    args: [count],
    desc: 'Label for how many votes are registered on a poll',
    locale: localeName
  );

  String get pollResultsButtonLabel => Intl.message(
    'View results',
    name: 'pollResultsButtonLabel',
    desc: 'Label for view poll results button',
    locale: localeName
  );

  String get voteButtonLabel => Intl.message(
    'Vote',
    name: 'voteButtonLabel',
    desc: 'Label for poll vote submission',
    locale: localeName
  );

  String get failedToVote => Intl.message(
    'Failed to vote on post',
    name: 'failedToVote',
    desc: 'Error message after voting on a poll failed',
    locale: localeName
  );

  String oEmbedHeader(String author, String provider) => Intl.message(
    '$author on $provider:',
    name: 'oEmbedHeader',
    args: [author, provider],
    desc: 'Header above HTML style oEmbeds',
    examples: const {'author': 'Alice', 'provider': 'Twitter'},
    locale: localeName
  );

  String oEmbedAuthor(String author) => Intl.message(
    'by $author',
    name: 'oEmbedAuthor',
    args: [author],
    desc: 'Subtitle on oEmbed thumbnails',
    examples: const {'author': 'Alice'},
    locale: localeName
  );

  String nsfwShieldTitle(String author) => Intl.message(
    'NSFW post by $author',
    name: 'nsfwShieldTitle',
    args: [author],
    desc: 'Title on the NSFW shield',
    examples: const {'author': 'Alice'},
    locale: localeName
  );

  String get showAllNsfwPostsButtonLabel => Intl.message(
    'Show all NSFW posts',
    name: 'showAllNsfwPostsButtonLabel',
    desc: 'Label on show all NSFW posts button',
    locale: localeName
  );

  String get showThisNsfwPostButtonLabel => Intl.message(
    'Show this post',
    name: 'showThisNsfwPostButtonLabel',
    desc: 'Label on show this NSFW post button',
    locale: localeName
  );

  String get aspectsPrompt => Intl.message(
    'Select aspects',
    name: 'aspectsPrompt',
    desc: 'Title for the aspect selection dialog',
    locale: localeName
  );

  String get formatItalic => Intl.message(
    'Italic',
    name: 'formatItalic',
    desc: 'Tooltip for format italic button',
    locale: localeName
  );

  String get formatBold => Intl.message(
    'Bold',
    name: 'formatBold',
    desc: 'Tooltip for format bold button',
    locale: localeName
  );

  String get formatStrikethrough => Intl.message(
    'Strikethrough',
    name: 'formatStrikethrough',
    desc: 'Tooltip for format strikethrough button',
    locale: localeName
  );

  String get insertHeading => Intl.message(
    'Heading',
    name: 'insertHeading',
    desc: 'Tooltip for insert heading button',
    locale: localeName
  );

  String get insertBulletedList => Intl.message(
    'Bulleted list',
    name: 'insertBulletedList',
    desc: 'Tooltip for insert bulleted list button',
    locale: localeName
  );

  String get insertNumberedList => Intl.message(
    'Numbered list',
    name: 'insertNumberedList',
    desc: 'Tooltip for insert numbered list button',
    locale: localeName
  );

  String get insertQuote => Intl.message(
    'Quote',
    name: 'insertQuote',
    desc: 'Tooltip for insert quote button',
    locale: localeName
  );

  String get insertCode => Intl.message(
    'Code',
    name: 'insertCode',
    desc: 'Tooltip for insert code button',
    locale: localeName
  );

  String get insertCodeBlock => Intl.message(
    'Code block',
    name: 'insertCodeBlock',
    desc: 'Tooltip for insert code block button',
    locale: localeName
  );

  String get insertLink => Intl.message(
    'Link',
    name: 'insertLink',
    desc: 'Tooltip for insert link button',
    locale: localeName
  );

  String get insertImageURL => Intl.message(
    'Image URL',
    name: 'insertImageURL',
    desc: 'Tooltip for insert image URL button',
    locale: localeName
  );

  String get insertHashtag => Intl.message(
    'Hashtag',
    name: 'insertHashtag',
    desc: 'Tooltip for insert hashtag button',
    locale: localeName
  );

  String get insertMention => Intl.message(
    'Mention',
    name: 'insertMention',
    desc: 'Tooltip for insert mention button',
    locale: localeName
  );

  String get insertLinkPrompt => Intl.message(
    'Insert a link',
    name: 'insertLinkPrompt',
    desc: 'Title for insert link prompt dialog',
    locale: localeName
  );

  String get insertImageURLPrompt => Intl.message(
    'Embed an image',
    name: 'insertImageURLPrompt',
    desc: 'Title for insert image URL prompt dialog',
    locale: localeName
  );

  String get insertLinkURLHint => Intl.message(
    'URL',
    name: 'insertLinkURLHint',
    desc: 'Hint text for URL field in insert link dialog',
    locale: localeName
  );

  String get insertLinkDescriptionHint => Intl.message(
    'Description (optional)',
    name: 'insertLinkDescriptionHint',
    desc: 'Hint text for description field in insert link dialog',
    locale: localeName
  );

  String get searchDialogHint => Intl.message(
    'Search',
    name: 'searchDialogHint',
    desc: 'Hint text for the search dialog input field',
    locale: localeName
  );

  String get tagSearchDialogHint => Intl.message(
    'Search for a tag',
    name: 'tagSearchDialogHint',
    desc: 'Hint text for the tag search dialog input field',
    locale: localeName
  );

  String get peopleSearchDialogHint => Intl.message(
    'Search for person',
    name: 'peopleSearchDialogHint',
    desc: 'Hint text for the people search dialog input field',
    locale: localeName
  );

  String get aspectsListTitle => Intl.message(
    'Aspects',
    name: 'aspectsListTitle',
    desc: 'Title for the aspects list page',
    locale: localeName
  );

  String get createAspectPrompt => Intl.message(
    'Create an aspect',
    name: 'createAspectPrompt',
    desc: 'Title for the create aspect prompt dialog',
    locale: localeName
  );

  String get failedToCreateAspect => Intl.message(
    'Failed to create aspect',
    name: 'failedToCreateAspect',
    desc: 'Error message after failing to create an aspect',
    locale: localeName
  );

  String get editAspectPrompt => Intl.message(
    'Edit aspect',
    name: 'editAspectPrompt',
    desc: 'Title for the edit aspect prompt dialog',
    locale: localeName
  );

  String failedToRenameAspect(String oldName,  String newName) => Intl.message(
    'Failed to rename aspect $oldName to $newName',
    name: 'failedToRenameAspect',
    args: [oldName, newName],
    desc: 'Error message after renaming an aspect failed',
    examples: const {'oldName':  'Friends',  'newName': 'Enemies'},
    locale: localeName
  );

  String deleteAspectPrompt(String name) => Intl.message(
    'Delete aspect $name?',
    name: 'deleteAspectPrompt',
    args: [name],
    desc: 'Title for the delete aspect prompt dialog',
    examples: const {'name': 'Colleagues'},
    locale: localeName
  );

  String failedToDeleteAspect(String name) => Intl.message(
    'Failed to remove aspect $name',
    name: 'failedToDeleteAspect',
    args: [name],
    desc: 'Error message after deleting an aspect failed',
    examples: const {'name': 'Leaders'},
    locale: localeName
  );

  String get aspectNameHint => Intl.message(
    'Enter a name',
    name: 'aspectNameHint',
    desc: 'Hint text for an aspect name field',
    locale: localeName
  );

  String get replyToConversation => Intl.message(
    'Reply',
    name: 'replyToConversation',
    desc: 'Label for reply to conversation button',
    locale: localeName
  );

  String get failedToReplyToConversation => Intl.message(
    'Failed to reply to conversation',
    name: 'failedToReplyToConversation',
    desc: 'Error message after replying to a conversation failed',
    locale: localeName
  );

  String get failedToHideConversation => Intl.message(
    'Failed to hide conversation',
    name: 'failedToHideConversation',
    desc: 'Error message after hiding a conversation failed',
    locale: localeName
  );

  String get editProfileTitle => Intl.message(
    'Edit profile',
    name: 'editProfileTitle',
    desc: 'Title for edit profile page',
    locale: localeName
  );

  String get uploadProfilePictureHeader => Intl.message(
    'Update profile picture',
    name: 'uploadProfilePictureHeader',
    desc: 'Header for upload profile picture section on the edit profile page',
    locale: localeName
  );

  String get takeNewPicture => Intl.message(
    'Take new picture',
    name: 'takeNewPicture',
    desc: 'Label for take a new picture button',
    locale: localeName
  );

  String get uploadNewPicture => Intl.message(
    'Upload new picture',
    name: 'uploadNewPicture',
    desc: 'Label for upload a new picture button',
    locale: localeName
  );

  String get failedToUploadProfilePicture => Intl.message(
    'Failed to upload profile picture',
    name: 'failedToUploadProfilePicture',
    desc: 'Error message after uploading a profile picture failed',
    locale: localeName
  );

  String get editProfileHeader => Intl.message(
    'Edit profile',
    name: 'editProfileHeader',
    desc: 'Header for edit profile section on edit profile page',
    locale: localeName
  );

  String get editProfileNameLabel => Intl.message(
    'Name',
    name: 'editProfileNameLabel',
    desc: 'Label for edit profile name field',
    locale: localeName
  );

  String get editProfileLocationLabel => Intl.message(
    'Location',
    name: 'editProfileLocationLabel',
    desc: 'Label for edit profile location field',
    locale: localeName
  );

  String get editProfileGenderLabel => Intl.message(
    'Gender',
    name: 'editProfileGenderLabel',
    desc: 'Label for edit profile gender field',
    locale: localeName
  );

  String get editProfileBirthdayLabel => Intl.message(
    'Birthday',
    name: 'editProfileBirthdayLabel',
    desc: 'Label for edit profile birthday field',
    locale: localeName
  );

  String get editProfilePublicLabel => Intl.message(
    'Make profile info public?',
    name: 'editProfilePublicLabel',
    desc: 'Label for edit profile public field',
    locale: localeName
  );

  String get editProfileSearchableLabel => Intl.message(
    'Allow to be searched for?',
    name: 'editProfileSearchableLabel',
    desc: 'Label for edit profile searchable field',
    locale: localeName
  );

  String get editProfileNsfwLabel => Intl.message(
    'Mark profile as #nsfw?',
    name: 'editProfileNsfwLabel',
    desc: 'Label for edit profile NSFW field',
    locale: localeName
  );

  String get editProfileTagsLabel => Intl.message(
    'Tags',
    name: 'editProfileTagsLabel',
    desc: 'Label for edit profile tags field',
    locale: localeName
  );

  String get editProfileSubmit => Intl.message(
    'Update profile',
    name: 'editProfileSubmit',
    desc: 'Label for edit profile submit button',
    locale: localeName
  );

  String get duplicateProfileTag => Intl.message(
    'Tag already added',
    name: 'duplicateProfileTag',
    desc: 'Error message after trying to add a duplicate profile tag',
    locale: localeName
  );

  String get updatedProfile => Intl.message(
    'Profile updated.',
    name: 'updatedProfile',
    desc: 'Success message after the profile was updated',
    locale: localeName
  );

  String get failedToUpdateProfile => Intl.message(
    'Failed to update profile',
    name: 'failedToUpdateProfile',
    desc: 'Error message after updating the profile failed',
    locale: localeName
  );

  String get newConversationTitle => Intl.message(
    'Start a new conversation',
    name: 'newConversationTitle',
    desc: 'Title for new conversation page',
    locale: localeName
  );

  String get newConversationRecipientsLabel => Intl.message(
    'Recipients',
    name: 'newConversationRecipientsLabel',
    desc: 'Label for new conversation recipients field',
    locale: localeName
  );

  String get newConversationSubjectLabel => Intl.message(
    'Subject',
    name: 'newConversationSubjectLabel',
    desc: 'Label for new conversation subject field',
    locale: localeName
  );

  String get newConversationMessageLabel => Intl.message(
    'Message',
    name: 'newConversationMessageLabel',
    desc: 'Label for new conversation message field',
    locale: localeName
  );

  String get sendNewConversation => Intl.message(
    'Send',
    name: 'sendNewConversation',
    desc: 'Label for new conversation send button',
    locale: localeName
  );

  String failedToAddConversationParticipantNotSharingWith(String name) => Intl.message(
    "You're not sharing with $name, cannot add them as a recipient!",
    name: 'failedToAddConversationParticipantNotSharingWith',
    args: [name],
    desc: 'Error message after adding a conversation participant failed due to the user not sharing with them',
    examples: const {'name': 'Stranger'},
    locale: localeName
  );

  String failedToAddConversationParticipantNotSharing(String name) => Intl.message(
    '$name is not sharing with you, cannot add them as a recipient!',
    name: 'failedToAddConversationParticipantNotSharing',
    args: [name],
    desc: 'Error message after adding a conversation participant failed due to them not sharing with the user',
    examples: const {'name' : 'Charlotte Idol'},
    locale: localeName
  );

  String failedToAddConversationParticipantDuplicate(String name) => Intl.message(
    '$name already is a recipient, cannot add them twice.',
    name: 'failedToAddConversationParticipantDuplicate',
    args: [name],
    desc: 'Error message after adding a conversation participant failed due to them already being part of the participants',
    examples: const {'name': 'Alice McBoss'},
    locale: localeName
  );

  String get failedToAddConversationParticipant => Intl.message(
    'Failed to add recipient',
    name: 'failedToAddConversationParticipant',
    desc: 'Error message after adding a conversation participant failed for a general reason',
    locale: localeName
  );

  String get failedToCreateConversation => Intl.message(
    'Failed to create conversation',
    name: 'failedToCreateConversation',
    desc: 'Error message after sending a conversation failed',
    locale: localeName
  );

  String get notificationTargetPost => Intl.message(
    'post',
    name: 'notificationTargetPost',
    desc: 'Target part of a notification message for a post',
    locale: localeName
  );

  String get notificationTargetDeletedPost => Intl.message(
    'deleted post',
    name: 'notificationTargetDeletedPost',
    desc: 'Target part of a notification message for a deleted post',
    locale: localeName
  );

  String notificationActorsForTwoPeople(String first, String second) => Intl.message(
    '$first and $second',
    name: 'notificationActorsForTwoPeople',
    args: [first, second],
    desc: 'Actors part of a notification message with exactly two actors',
    examples: const {'first': 'Alice', 'second': 'Bob'},
    locale: localeName
  );

  String notificationActorsForThreePeople(String first, String second, String third) => Intl.message(
    '$first, $second and $third',
    name: 'notificationActorsForThreePeople',
    args: [first, second, third],
    desc: 'Actors part of a notification message with exactly three actors',
    examples: const {'first': 'Alice', 'second': 'Bob', 'third': 'Charlotte'},
    locale: localeName
  );

  String notificationActorsForMoreThanThreePeople(String first, String second, int othersCount) => Intl.plural(
    othersCount,
    zero: '$first, $second and no others',
    one: '$first, $second and one more',
    other: '$first, $second and $othersCount others',
    name: 'notificationActorsForMoreThanThreePeople',
    args: [first, second, othersCount],
    desc: 'Actors part of a notification message with more than three actors. The first two are given, the count is the count of how many more (at least two) there are. So the zero and one cases never come into use',
    examples: const {'first': 'Alice', 'second': 'Bob', 'othersCount': '2, 3, 4, ...'},
    locale: localeName
  );

  String notificationAlsoCommented(int actorCount, String actors, String target) => Intl.plural(
    actorCount,
    zero: 'Nobody also commented on a $target.',
    one: '$actors also commented on $target.',
    other: '$actors also commented on $target.',
    name: 'notificationAlsoCommented',
    args: [actorCount, actors, target],
    desc: 'Notification message for when some people also commented on a post. The zero case is never used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
      'target': 'Either the result of notificationTargetPost or notificationTargetDeletedPost'
    },
    locale: localeName
  );

  String notificationCommented(int actorCount, String actors, String target) => Intl.plural(
    actorCount,
    zero: 'Nobody commented on your $target.',
    one: '$actors commented your $target.',
    other: '$actors commented your $target.',
    name: 'notificationCommented',
    args: [actorCount, actors, target],
    desc: 'Notification message for when some people commented on the users post. The zero case is never used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
      'target': 'Either the result of notificationTargetPost or notificationTargetDeletedPost'
    },
    locale: localeName
  );

  String notificationBirthday(int actorCount, String actors) => Intl.plural(
    actorCount,
    zero: 'Nobody has their birthday today.',
    one: '$actors has their birthday today.',
    other: '$actors have their birthday your today.',
    name: 'notificationBirthday',
    args: [actorCount, actors],
    desc: 'Notification message for when a contact of the user has their birthday. Currently only the one case is used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
    },
    locale: localeName
  );

  String notificationLiked(int actorCount, String actors, String target) => Intl.plural(
    actorCount,
    zero: 'Nobody liked your $target.',
    one: '$actors liked your $target.',
    other: '$actors liked your $target.',
    name: 'notificationLiked',
    args: [actorCount, actors, target],
    desc: 'Notification message for when some people liked the users post. The zero case is never used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
      'target': 'Either the result of notificationTargetPost or notificationTargetDeletedPost'
    },
    locale: localeName
  );

  String notificationMentionedInPost(int actorCount, String actors, String target) => Intl.plural(
    actorCount,
    zero: 'Nobody mentioned you in a $target.',
    one: '$actors mentioned you in a $target.',
    other: '$actors mentioned you in a $target.',
    name: 'notificationMentionedInPost',
    args: [actorCount, actors, target],
    desc: 'Notification message for when somebody mentioned the user in a post. Currently only the one case is used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
      'target': 'Either the result of notificationTargetPost or notificationTargetDeletedPost'
    },
    locale: localeName
  );

  String notificationMentionedInComment(int actorCount, String actors) => Intl.plural(
    actorCount,
    zero: 'Nobody mentioned you in a comment.',
    one: '$actors mentioned you in a comment.',
    other: '$actors mentioned you in a comment.',
    name: 'notificationMentionedInComment',
    args: [actorCount, actors],
    desc: 'Notification message for when somebody mentioned the user in a comment. Currently only the one case is used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
    },
    locale: localeName
  );

  String notificationMentionedInCommentOnDeletedPost(int actorCount, String actors) => Intl.plural(
    actorCount,
    zero: 'Nobody mentioned you in a comment on a deleted post.',
    one: '$actors mentioned you in a comment on a deleted post.',
    other: '$actors mentioned you in a comment on a deleted post.',
    name: 'notificationMentionedInCommentOnDeletedPost',
    args: [actorCount, actors],
    desc: 'Notification message for when somebody mentioned the user in in comment on a deleted post. Currently only the one case is used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
    },
    locale: localeName
  );


  String notificationReshared(int actorCount, String actors, String target) => Intl.plural(
    actorCount,
    zero: 'Nobody reshared your $target.',
    one: '$actors reshared your $target.',
    other: '$actors reshared your $target.',
    name: 'notificationReshared',
    args: [actorCount, actors, target],
    desc: 'Notification message for when some people reshared the users post. The zero case is never used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
      'target': 'Either the result of notificationTargetPost or notificationTargetDeletedPost'
    },
    locale: localeName
  );

  String notificationStartedSharing(int actorCount, String actors) => Intl.plural(
    actorCount,
    zero: 'Nobody started sharing with you.',
    one: '$actors started sharing with you.',
    other: '$actors started sharing with you.',
    name: 'notificationStartedSharing',
    args: [actorCount, actors],
    desc: 'Notification message for when some people started sharing  with the user. The zero case is never used',
    examples: const {
      'actorCount': '1, 2, 3, ...',
      'actors': 'With actorCount being 1 a name such as Alice, being 2 the result of notificationActorsForTwoPeople, being 3 the result of notificationActorsForThreePeople or being 4 or higher the result of notificationActorsForMoreThanThreePeople',
    },
    locale: localeName
  );

  String get failedToMarkNotificationAsRead => Intl.message(
    'Failed to mark notification as read',
    name: 'failedToMarkNotificationAsRead',
    desc: 'Error message after marking a notification as read failed',
    locale: localeName
  );

  String get failedToMarkNotificationAsUnread => Intl.message(
    'Failed to mark notification as unread',
    name: 'failedToMarkNotificationAsUnread',
    desc: 'Error message after marking a notification  as unread failed',
    locale: localeName
  );

  String get profileInfoHeader => Intl.message(
    'Info',
    name: 'profileInfoHeader',
    desc: 'Header for info section on the profile page',
    locale: localeName
  );

  String get profilePostsHeader => Intl.message(
    'Posts',
    name: 'profilePostsHeader',
    desc: 'Header for posts section on the profile page',
    locale: localeName
  );

  String get editProfile => Intl.message(
    'Edit profile',
    name: 'editProfile',
    desc: 'Label for the edit profile button',
    locale: localeName
  );

  String get mentionUser => Intl.message(
    'Mention user',
    name: 'mentionUser',
    desc: 'Tooltip for the mention user button',
    locale: localeName
  );

  String get messageUser => Intl.message(
    'Message',
    name: 'messageUser',
    desc: 'Tooltip for the message user button',
    locale: localeName
  );

  String get blockUser => Intl.message(
    'Block',
    name: 'blockUser',
    desc: 'Tooltip for the block user button',
    locale: localeName
  );

  String get unblockUser => Intl.message(
    'Unblock',
    name: 'unblockUser',
    desc: 'Tooltip for the unblock user button',
    locale: localeName
  );

  String failedToBlockUser(String name) => Intl.message(
    'Failed to block $name',
    name: 'failedToBlockUser',
    args: [name],
    desc: 'Error message after blocking a user failed',
    examples: const {"name": "Alice, alice@pod.example.org"},
    locale: localeName
  );

  String failedToUnblockUser(String name) => Intl.message(
    'Failed to unblock $name',
    name: 'failedToUnblockUser',
    args: [name],
    desc: 'Error message after unblocking a user failed',
    examples: const {"name": "Alice, alice@pod.example.org"},
    locale: localeName
  );

  String get addContact => Intl.message(
    'Add contact',
    name: 'addContact',
    desc: 'Label for add contact button',
    locale: localeName
  );

  String manageContact(int count) => Intl.plural(
    count,
    zero: 'In no aspects',
    one: 'In one aspect',
    other: 'In $count aspects',
    name: 'manageContact',
    args: [count],
    desc: 'Label for manage contact button. The zero case and one is never used',
    examples: const {'count': '2, 3, 4, ...'},
    locale: localeName
  );

  String get contactStatusBlocked => Intl.message(
    'You blocked them',
    name: 'contactStatusBlocked',
    desc: 'Contact status message for a blocked user',
    locale: localeName
  );

  String get contactStatusMutual => Intl.message(
    'You are sharing with each other',
    name: 'contactStatusMutual',
    desc: 'Contact status message for a contact that is sharing with the user and that the user is sharing with',
    locale: localeName
  );

  String get contactStatusReceiving => Intl.message(
    'They are sharing with you.',
    name: 'contactStatusReceiving',
    desc: 'Contact status message for a contact that is sharing with the user, but the user is not sharing with the contact',
    locale: localeName
  );

  String get contactStatusSharing => Intl.message(
    'You are sharing with them.',
    name: 'contactStatusSharing',
    desc: 'Contact status message for a contact that the user is sharing with, but the contact is not sharing with the user',
    locale: localeName
  );

  String get contactStatusNotSharing => Intl.message(
    'You are not sharing with each other.',
    name: 'contactStatusNotSharing',
    desc: 'Contact status message for somebody that is not sharing with the user nor the user is sharing with',
    locale: localeName
  );

  String contactAspectsPrompt(String name) => Intl.message(
    'Select aspects for $name',
    name: 'contactAspectsPrompt',
    args: [name],
    desc: 'Title for the contact aspects prompt dialog',
    examples: const {'name': 'Alice'},
    locale: localeName
  );

  String startedSharing(String name) => Intl.message(
    'Started sharing with $name.',
    name: 'startedSharing',
    args: [name],
    desc: 'Success message after the user started sharing with somebody',
    examples: const {'name': 'Alice'},
    locale: localeName
  );

  String stoppedSharing(String name) => Intl.message(
    'Stopped sharing with $name.',
    name: 'stoppedSharing',
    args: [name],
    desc: 'Success message after the user stopped sharing with somebody',
    examples: const {'name': 'Alice'},
    locale: localeName
  );

  String get contactAspectsUpdated => Intl.message(
    'Aspects updated.',
    name: 'contactAspectsUpdated',
    desc: "Success message after the user updated a contact's aspects",
    locale: localeName
  );

  String get failedToUpdateContactAspects => Intl.message(
    'Failed to update aspects',
    name: 'failedToUpdateContactAspects',
    desc: "Error message after updating a contact's aspects failed",
    locale: localeName
  );

  String get publisherTitle => Intl.message(
    'Write a new post',
    name: 'publisherTitle',
    desc: 'Title for the publisher page',
    locale: localeName
  );

  String get takePhoto => Intl.message(
    'Take a photo',
    name: 'takePhoto',
    desc: 'Tooltip for the take a photo button',
    locale: localeName
  );

  String get uploadPhoto => Intl.message(
    'Upload a photo',
    name: 'uploadPhoto',
    desc: 'Tooltip for the upload a photo button',
    locale: localeName
  );

  String get addPoll => Intl.message(
    'Add a poll',
    name: 'addPoll',
    desc: 'Tooltip for the add poll button',
    locale: localeName
  );

  String get addLocation => Intl.message(
    'Add your location',
    name: 'addLocation',
    desc: 'Tooltip for the add location button',
    locale: localeName
  );

  String get publishPost => Intl.message(
    'Publish post',
    name: 'publishPost',
    desc: 'Label for the publish post button',
    locale: localeName
  );

  String get publishTargetPublic => Intl.message(
    'Public',
    name: 'publishTargetPublic',
    desc: 'Publish target label for a public post',
    locale: localeName
  );

  String get publishTargetAllAspects => Intl.message(
    'All aspects',
    name: 'publishTargetAllAspects',
    desc: 'Publish target label for a post to all aspects',
    locale: localeName
  );

  String publishTargetAspects(int count) => Intl.plural(
    count,
    zero: 'No aspects',
    one: 'One aspect',
    other: '$count aspects',
    name: 'publishTargetAspects',
    args: [count],
    desc: 'Publish target label for a post to a list of aspects. The zero and one cases are never used',
    examples: const {'count': '2, 3, 4, ...'},
    locale: localeName
  );

  String get publishTargetPrompt => Intl.message(
    'Select post visibility',
    name: 'publishTargetPrompt',
    desc: 'Title for the publish target selection prompt dialog',
    locale: localeName
  );

  String get failedToUploadPhoto => Intl.message(
    'Failed to upload photo',
    name: 'failedToUploadPhoto',
    desc: 'Error message after uploading a photo failed',
    locale: localeName
  );

  String get pollQuestionHint => Intl.message(
    'Enter a question',
    name: 'pollQuestionHint',
    desc: 'Hint text for the poll question field',
    locale: localeName
  );

  String get pollAnswerHint => Intl.message(
    'Enter an answer',
    name: 'pollAnswerHint',
    desc: 'Hint text for a poll answer field',
    locale: localeName
  );

  String get createPoll => Intl.message(
    'Create poll',
    name: 'createPoll',
    desc: 'Label for the create poll button',
    locale: localeName
  );

  String get editPoll => Intl.message(
    'Edit poll',
    name: 'editPoll',
    desc: 'Label for the edit poll button',
    locale: localeName
  );

  String get enterAddressHint => Intl.message(
    'Enter an address',
    name: 'enterAddressHint',
    desc: 'Hint text for an address field',
    locale: localeName
  );

  String get failedToSearchForAddresses => Intl.message(
    'Failed to search for addresses',
    name: 'failedToSearchForAddresses',
    desc: 'Error message after searching for the entered address failed',
    locale: localeName
  );

  String get searchTypePeople => Intl.message(
    'People',
    name: 'searchTypePeople',
    desc: 'Label for search type selector for the people search',
    locale: localeName
  );

  String get searchTypePeopleByTag => Intl.message(
    'People by tag',
    name: 'searchTypePeopleByTag',
    desc: 'Label for search type selector for the people by tag search',
    locale: localeName
  );

  String get searchTypeTags => Intl.message(
    'Tags',
    name: 'searchTypeTags',
    desc: 'Label for search type selector for the tags search',
    locale: localeName
  );

  String get searchPeopleHint => Intl.message(
    'Start typing a name or diaspora* ID',
    name: 'searchPeopleHint',
    desc: 'Hint text for the people search field',
    locale: localeName
  );

  String get searchPeopleByTagHint => Intl.message(
    'Enter a tag',
    name: 'searchPeopleByTagHint',
    desc: 'Hint text for the the people by tag search field',
    locale: localeName
  );

  String get searchTagsHint => Intl.message(
    'Start typing tag',
    name: 'searchTagsHint',
    desc: 'Hint text for the tags search field',
    locale: localeName
  );

  String get aspectStreamSelectorAllAspects => Intl.message(
    'All aspects',
    name: 'aspectStreamSelectorAllAspects',
    desc: 'Aspect stream selector label for all aspects',
    locale: localeName
  );

  String aspectStreamSelectorAspects(int count) => Intl.plural(
    count,
    zero: 'No aspects',
    one: 'One aspect',
    other: '$count aspects',
    name: 'aspectStreamSelectorAspects',
    args: [count],
    desc: 'Aspect stream selector label for a list of aspects. The zero and one cases are never used',
    examples: const {'count': '2, 3, 4, ...'},
    locale: localeName
  );

  String get manageFollowedTags => Intl.message(
    'Manage followed tags',
    name: 'manageFollowedTags',
    desc: 'Label for the manage followed tags button',
    locale: localeName
  );

  String get followedTagsPageTitle => Intl.message(
    'Followed tags',
    name: 'followedTagsPageTitle',
    desc: 'Title for the followed tags page',
    locale: localeName
  );

  String failedToFollowTag(String tag) => Intl.message(
    'Failed to follow #$tag',
    name: 'failedToFollowTag',
    args: [tag],
    desc: 'Error message after following a tag failed',
    examples: const {'tag': 'newhere'},
    locale: localeName
  );

  String failedToUnfollowTag(String tag) => Intl.message(
    'Failed to unfollow #$tag',
    name: 'failedToUnfollowTag',
    args: [tag],
    desc: 'Error message after unfollowing a tag failed',
    examples: const {'tag': 'nsfw'},
    locale: localeName
  );
}

mixin StateLocalizationHelpers<T extends StatefulWidget> on State<T> {
  InsporationLocalizations get l => InsporationLocalizations.of(context);

  MaterialLocalizations get ml => MaterialLocalizations.of(context);
}

class _InsporationLocalizationsDelegate extends LocalizationsDelegate<InsporationLocalizations> {
  const _InsporationLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);

  @override
  Future<InsporationLocalizations> load(Locale locale) {
    Timeago.loadLocale(locale);
    return InsporationLocalizations.load(locale);
  }

  @override
  bool shouldReload(_InsporationLocalizationsDelegate old) => false;
}

class CatcherLocalization implements LocalizationOptions {
  final String languageCode;
  final LocalizationOptions defaults;

  CatcherLocalization(this.languageCode, {LocalizationOptions defaults}) :
    this.defaults = defaults ?? LocalizationOptions.buildDefaultEnglishOptions();

  @override
  String get dialogReportModeTitle => Intl.message(
    'insporation* crashed :(',
    name: 'CatcherLocalization_dialogReportModeTitle',
    desc: 'Title for crash report dialog',
    locale: languageCode
  );

  @override
  String get dialogReportModeDescription => Intl.message(
    'An unexpected error occurred, an error report is ready to be send to the developers.',
    name: 'CatcherLocalization_dialogReportModeDescription',
    desc: 'Description for crash report page',
    locale: languageCode
  );

  @override
  String get dialogReportModeAccept => Intl.message(
    'Send report',
    name: 'CatcherLocalization_dialogReportModeAccept',
    desc: 'Button label for accepting to send a crash report',
    locale: languageCode
  );

  @override
  String get dialogReportModeCancel => Intl.message(
    'Dismiss',
    name: 'CatcherLocalization_dialogReportModeCancel',
    desc: 'Button label for dismissing a crash report',
    locale: languageCode
  );

  @override
  String get notificationReportModeTitle => defaults.notificationReportModeTitle;

  @override
  String get notificationReportModeContent => defaults.notificationReportModeContent;

  @override
  String get pageReportModeTitle => defaults.pageReportModeTitle;

  @override
  String get pageReportModeDescription => defaults.pageReportModeDescription;

  @override
  String get pageReportModeAccept => defaults.pageReportModeAccept;

  @override
  String get pageReportModeCancel => defaults.pageReportModeCancel;
}
