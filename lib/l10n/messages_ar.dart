// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static m0(count) => "${Intl.plural(count, zero: 'بدون فئة', one: 'فئة واحدة ', other: '${count} فئة')}";

  static m1(name) => "حدد فئات ل ${name}";

  static m2(name) => "هل تريد حذف الفئة ${name}؟";

  static m3(name) => "لا يمكنك إضافة ${name} لأنه مستلم بالفعل.";

  static m4(name) => "لا يمكنك اضافة ${name} كمستلم لأنه لا يشارك معك!";

  static m5(name) => "لا يمكنك اضافة ${name} كمستلم لأنك لا تشارك معه!";

  static m6(name) => "فشل حظر ${name}";

  static m7(name) => "فشلت إزالة الفئة ${name}";

  static m8(tag) => "فشلت متابعة #${tag}";

  static m9(oldName, newName) => "فشلت تسمية الفئة ${oldName} باسم ${newName}";

  static m10(name) => "فشل إلغاء حظر ${name}";

  static m11(tag) => "فشل إلغاء متابعة #${tag}";

  static m12(count) => "${Intl.plural(count, zero: 'بدون فئة', one: 'في فئة واحدة', other: 'في ${count} فئة')}";

  static m13(first, second, othersCount) => "${Intl.plural(othersCount, zero: '${first}, ${second} فقط', one: '${first}, ${second} وواحد إضافي', other: '${first}, ${second} و ${othersCount} آخرون')}";

  static m14(first, second, third) => "${first}, ${second} و ${third}";

  static m15(first, second) => "${first} و ${second}";

  static m16(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'لا أحد علق على ${target}.', one: '${actors} علق على ${target}.', other: '${actors} علقوا على ${target}.')}";

  static m17(actorCount, actors) => "${Intl.plural(actorCount, zero: 'لا عيد ميلاد اليوم.', one: 'عيد ميلاد ${actors}اليوم.', other: 'عيد ميلاد ${actors} اليوم.')}";

  static m18(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'لا أحد علق على ${target}.', one: '${actors} علق على ${target}.', other: '${actors} علقوا على ${target}.')}";

  static m19(actorCount, actors, target) => "${Intl.plural(actorCount, zero: '${target} لم يعجب أحدا', one: '${actors} أعجبه ${target}.', other: '${actors} أعجبهم ${target}.')}";

  static m20(actorCount, actors) => "${Intl.plural(actorCount, zero: 'لم يشر إليك أحد في رد.', one: '${actors} أشار إليك في رد', other: '${actors} أشاروا إليك في رد.')}";

  static m21(actorCount, actors) => "${Intl.plural(actorCount, zero: 'لم يشر إليك أحد في رد على مشاركة محذوفة.', one: '${actors} أشار إليك في رد على مشاركة محذوفة', other: '${actors} أشاروا إليك في رد على مشاركة محذوف.')}";

  static m22(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'لم يشر إليك في ${target}.', one: '${actors} أشار إليك في ${target}.', other: '${actors} أشاروا إليك في ${target}.')}";

  static m23(actorCount, actors, target) => "${Intl.plural(actorCount, zero: 'لم يعد أحد نشر ${target}.', one: '${actors} أعاد نشر ${target}.', other: '${actors} أعادوا نشر ${target}.')}";

  static m24(actorCount, actors) => "${Intl.plural(actorCount, zero: 'لم يشارك أحد.', one: '${actors} بدأ المشاركة معك.', other: '${actors} بدأوا المشاركة معك.')}";

  static m25(author) => "مشاركة غير مناسبة لمكان العمل بوسطة ${author}";

  static m26(author) => "بواسطة ${author}";

  static m27(author, provider) => "${author} على ${provider}:";

  static m28(count) => "${Intl.plural(count, zero: 'بدون فئة', one: 'فئة واحدة ', other: '${count} فئة')}";

  static m29(name) => "بدأت تشارك مع ${name}.";

  static m30(name) => "أوقفت التشارك مع ${name}.";

  static m31(count) => "${Intl.plural(count, zero: 'لم يصوت أحد', one: 'صوت واحد', other: 'صوت ${count}')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "addContact" : MessageLookupByLibrary.simpleMessage("أضف كجهة اتصال"),
    "addLocation" : MessageLookupByLibrary.simpleMessage("أضف موقعك"),
    "addPoll" : MessageLookupByLibrary.simpleMessage("أضف استطلاعا"),
    "aspectNameHint" : MessageLookupByLibrary.simpleMessage("أدخل الاسم"),
    "aspectStreamSelectorAllAspects" : MessageLookupByLibrary.simpleMessage("كل الفئات"),
    "aspectStreamSelectorAspects" : m0,
    "aspectsListTitle" : MessageLookupByLibrary.simpleMessage("الفئات"),
    "aspectsPrompt" : MessageLookupByLibrary.simpleMessage("حدد الفئات"),
    "blockUser" : MessageLookupByLibrary.simpleMessage("أُحظر"),
    "cancelPostSubscription" : MessageLookupByLibrary.simpleMessage("أوقف الاشعارات"),
    "commentsHeader" : MessageLookupByLibrary.simpleMessage("التعليقات"),
    "confirmDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("أكد الحذف"),
    "confirmReshare" : MessageLookupByLibrary.simpleMessage("أعد النشر"),
    "contactAspectsPrompt" : m1,
    "contactAspectsUpdated" : MessageLookupByLibrary.simpleMessage("حُدثت الفئات."),
    "contactStatusBlocked" : MessageLookupByLibrary.simpleMessage("حظَرتهم"),
    "contactStatusMutual" : MessageLookupByLibrary.simpleMessage("أنتما تتشركان مع بعضكما"),
    "contactStatusNotSharing" : MessageLookupByLibrary.simpleMessage("أنتما لا تتشركان معا."),
    "contactStatusReceiving" : MessageLookupByLibrary.simpleMessage("هم يشاركون معك."),
    "contactStatusSharing" : MessageLookupByLibrary.simpleMessage("انت تشارك معهم."),
    "createAspectPrompt" : MessageLookupByLibrary.simpleMessage("أنشئ فئة"),
    "createButtonLabel" : MessageLookupByLibrary.simpleMessage("أنشئ"),
    "createComment" : MessageLookupByLibrary.simpleMessage("علق"),
    "createPoll" : MessageLookupByLibrary.simpleMessage("أنشئ استطلاعا"),
    "deleteAspectPrompt" : m2,
    "deleteCommentPrompt" : MessageLookupByLibrary.simpleMessage("حذف التعليق؟"),
    "deletePostPrompt" : MessageLookupByLibrary.simpleMessage("حذف المشاركة؟"),
    "deletedPostReshareHint" : MessageLookupByLibrary.simpleMessage("إعادة نشر لمشاركة محذوفة"),
    "deselectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("الغ تحديد الكل"),
    "duplicateProfileTag" : MessageLookupByLibrary.simpleMessage("الوسم مضاف من قبل"),
    "editAspectPrompt" : MessageLookupByLibrary.simpleMessage("حرر الفئة"),
    "editPoll" : MessageLookupByLibrary.simpleMessage("حرر الاستطلاع"),
    "editProfile" : MessageLookupByLibrary.simpleMessage("حرر الملف الشخصي"),
    "editProfileBirthdayLabel" : MessageLookupByLibrary.simpleMessage("تاريخ المولد"),
    "editProfileGenderLabel" : MessageLookupByLibrary.simpleMessage("الجنس"),
    "editProfileHeader" : MessageLookupByLibrary.simpleMessage("حرر الملف الشخصي"),
    "editProfileLocationLabel" : MessageLookupByLibrary.simpleMessage("الموقع"),
    "editProfileNameLabel" : MessageLookupByLibrary.simpleMessage("الاسم"),
    "editProfileNsfwLabel" : MessageLookupByLibrary.simpleMessage("جعل الملف الشخصي غير مناسب للعمل؟"),
    "editProfilePublicLabel" : MessageLookupByLibrary.simpleMessage("جعل معلومات الملف الشخصي عامة؟"),
    "editProfileSearchableLabel" : MessageLookupByLibrary.simpleMessage("السماح بالبحث عنك؟"),
    "editProfileSubmit" : MessageLookupByLibrary.simpleMessage("حدِّث الملف الشخصي"),
    "editProfileTagsLabel" : MessageLookupByLibrary.simpleMessage("الوسوم"),
    "editProfileTitle" : MessageLookupByLibrary.simpleMessage("حرر الملف الشخصي"),
    "enterAddressHint" : MessageLookupByLibrary.simpleMessage("أدرج عنوانا"),
    "errorSignInTimeout" : MessageLookupByLibrary.simpleMessage("انتهت مهلة الاستيثاق، أمتأكد من دعم خادمك لل API ؟"),
    "failedToAddConversationParticipant" : MessageLookupByLibrary.simpleMessage("فشلت إضافة مستلم"),
    "failedToAddConversationParticipantDuplicate" : m3,
    "failedToAddConversationParticipantNotSharing" : m4,
    "failedToAddConversationParticipantNotSharingWith" : m5,
    "failedToBlockUser" : m6,
    "failedToCommentOnPost" : MessageLookupByLibrary.simpleMessage("فشل إنشاء التعليق"),
    "failedToCreateAspect" : MessageLookupByLibrary.simpleMessage("فشل إنشاء فئة"),
    "failedToCreateConversation" : MessageLookupByLibrary.simpleMessage("فشل إنشاء محادثة"),
    "failedToDeleteAspect" : m7,
    "failedToDeleteComment" : MessageLookupByLibrary.simpleMessage("فشل حذف التعليق"),
    "failedToDeletePost" : MessageLookupByLibrary.simpleMessage("فشل حذف المشاركة"),
    "failedToFollowTag" : m8,
    "failedToHideConversation" : MessageLookupByLibrary.simpleMessage("فشل إخفاء المحادثة"),
    "failedToHidePost" : MessageLookupByLibrary.simpleMessage("فشل إخفاء المشاركة"),
    "failedToLikePost" : MessageLookupByLibrary.simpleMessage("فشل الاعجاب بالمشاركة"),
    "failedToMarkNotificationAsRead" : MessageLookupByLibrary.simpleMessage("فشل جعل الإشعار مقروءا"),
    "failedToMarkNotificationAsUnread" : MessageLookupByLibrary.simpleMessage("فشل جعل الإشعار غير مقروء"),
    "failedToRenameAspect" : m9,
    "failedToReplyToConversation" : MessageLookupByLibrary.simpleMessage("فشل الرد على المحادثة"),
    "failedToReportComment" : MessageLookupByLibrary.simpleMessage("فشل إنشاء التبليغ"),
    "failedToReportPost" : MessageLookupByLibrary.simpleMessage("فشل إنشاء التبليغ"),
    "failedToResharePost" : MessageLookupByLibrary.simpleMessage("فشلت اعادة نشر المشاركة"),
    "failedToSearchForAddresses" : MessageLookupByLibrary.simpleMessage("فشل البحث عن العنوان"),
    "failedToSubscribeToPost" : MessageLookupByLibrary.simpleMessage("فشل الاشتراك في المشاركة"),
    "failedToUnblockUser" : m10,
    "failedToUnfollowTag" : m11,
    "failedToUnlikePost" : MessageLookupByLibrary.simpleMessage("فشل الغاء الإعجاب بالمشاركة"),
    "failedToUnsubscribeFromPost" : MessageLookupByLibrary.simpleMessage("فشل إلغاء الاشتراك في المشاركة"),
    "failedToUpdateContactAspects" : MessageLookupByLibrary.simpleMessage("فشل تحديث الفئات"),
    "failedToUpdateProfile" : MessageLookupByLibrary.simpleMessage("فشل تحديث الملف الشخصي"),
    "failedToUploadPhoto" : MessageLookupByLibrary.simpleMessage("فشل رفع الصورة"),
    "failedToUploadProfilePicture" : MessageLookupByLibrary.simpleMessage("فشل تحميل صورة الملف الشخصي"),
    "failedToVote" : MessageLookupByLibrary.simpleMessage("فشل التصويت"),
    "followedTagsPageTitle" : MessageLookupByLibrary.simpleMessage("الوسوم المتبعة"),
    "formatBold" : MessageLookupByLibrary.simpleMessage("عريض"),
    "formatItalic" : MessageLookupByLibrary.simpleMessage("مائل"),
    "formatStrikethrough" : MessageLookupByLibrary.simpleMessage("يتوسطه خط"),
    "hidePost" : MessageLookupByLibrary.simpleMessage("إخف"),
    "insertBulletedList" : MessageLookupByLibrary.simpleMessage("قائمة نقطية"),
    "insertButtonLabel" : MessageLookupByLibrary.simpleMessage("أدرج"),
    "insertCode" : MessageLookupByLibrary.simpleMessage("رمز"),
    "insertCodeBlock" : MessageLookupByLibrary.simpleMessage("كتلة نص برمجي"),
    "insertHashtag" : MessageLookupByLibrary.simpleMessage("وسم"),
    "insertHeading" : MessageLookupByLibrary.simpleMessage("عنوان"),
    "insertImageURL" : MessageLookupByLibrary.simpleMessage("رابط صورة"),
    "insertImageURLPrompt" : MessageLookupByLibrary.simpleMessage("ضمَّن صورة"),
    "insertLink" : MessageLookupByLibrary.simpleMessage("رابط"),
    "insertLinkDescriptionHint" : MessageLookupByLibrary.simpleMessage("وصف (اختياري)"),
    "insertLinkPrompt" : MessageLookupByLibrary.simpleMessage("أدرج رابط"),
    "insertLinkURLHint" : MessageLookupByLibrary.simpleMessage("عنوان رابط"),
    "insertMention" : MessageLookupByLibrary.simpleMessage("أشر"),
    "insertNumberedList" : MessageLookupByLibrary.simpleMessage("قائمة مُرقمة"),
    "insertQuote" : MessageLookupByLibrary.simpleMessage("اقتبس"),
    "invalidDiasporaId" : MessageLookupByLibrary.simpleMessage("أدخل معرف داياسبورا كاملا"),
    "likesHeader" : MessageLookupByLibrary.simpleMessage("الإعجابات"),
    "manageContact" : m12,
    "manageFollowedTags" : MessageLookupByLibrary.simpleMessage("أدر الوسوم المتبعة"),
    "mentionUser" : MessageLookupByLibrary.simpleMessage("أشر إلى مستخدم"),
    "messageUser" : MessageLookupByLibrary.simpleMessage("الرسائل"),
    "navigationItemTitleContacts" : MessageLookupByLibrary.simpleMessage("جهات الاتصال"),
    "navigationItemTitleConversations" : MessageLookupByLibrary.simpleMessage("المحادثات"),
    "navigationItemTitleEditProfile" : MessageLookupByLibrary.simpleMessage("عدل الحساب"),
    "navigationItemTitleNotifications" : MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "navigationItemTitleSearch" : MessageLookupByLibrary.simpleMessage("البحث"),
    "navigationItemTitleStream" : MessageLookupByLibrary.simpleMessage("ساحة المشاركات"),
    "navigationItemTitleSwitchUser" : MessageLookupByLibrary.simpleMessage("غيِّر المستخدم"),
    "newConversationMessageLabel" : MessageLookupByLibrary.simpleMessage("الرسالة"),
    "newConversationRecipientsLabel" : MessageLookupByLibrary.simpleMessage("المستلمون"),
    "newConversationSubjectLabel" : MessageLookupByLibrary.simpleMessage("الموضوع"),
    "newConversationTitle" : MessageLookupByLibrary.simpleMessage("ابدأ محادثة جديدة"),
    "noButtonLabel" : MessageLookupByLibrary.simpleMessage("لا"),
    "noItems" : MessageLookupByLibrary.simpleMessage("لا شيء لعرضه!"),
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
    "notificationTargetDeletedPost" : MessageLookupByLibrary.simpleMessage("مشاركة محذوفة"),
    "notificationTargetPost" : MessageLookupByLibrary.simpleMessage("مشاركة"),
    "nsfwShieldTitle" : m25,
    "oEmbedAuthor" : m26,
    "oEmbedHeader" : m27,
    "peopleSearchDialogHint" : MessageLookupByLibrary.simpleMessage("ابحث عن شخص"),
    "pollAnswerHint" : MessageLookupByLibrary.simpleMessage("أدرج جوابا"),
    "pollQuestionHint" : MessageLookupByLibrary.simpleMessage("أدرج سؤال"),
    "pollResultsButtonLabel" : MessageLookupByLibrary.simpleMessage("اعرض النتائج"),
    "profileInfoHeader" : MessageLookupByLibrary.simpleMessage("معلومات"),
    "profilePostsHeader" : MessageLookupByLibrary.simpleMessage("المنشورات"),
    "publishPost" : MessageLookupByLibrary.simpleMessage("انشر المشاركة"),
    "publishTargetAllAspects" : MessageLookupByLibrary.simpleMessage("كل الفئات"),
    "publishTargetAspects" : m28,
    "publishTargetPrompt" : MessageLookupByLibrary.simpleMessage("حدد مرئية المشاركة"),
    "publishTargetPublic" : MessageLookupByLibrary.simpleMessage("عام"),
    "publisherTitle" : MessageLookupByLibrary.simpleMessage("اكتب مشاركة جديدة"),
    "removeButtonLabel" : MessageLookupByLibrary.simpleMessage("أزل"),
    "replyToConversation" : MessageLookupByLibrary.simpleMessage("رُد"),
    "reportComment" : MessageLookupByLibrary.simpleMessage("أبلغ عن"),
    "reportCommentHint" : MessageLookupByLibrary.simpleMessage("يرجى اعطاء وصف للمشكلة"),
    "reportCommentPrompt" : MessageLookupByLibrary.simpleMessage("الإبلاغ عن تعليق"),
    "reportPost" : MessageLookupByLibrary.simpleMessage("بلغ عن"),
    "reportPostHint" : MessageLookupByLibrary.simpleMessage("يرجى اعطاء وصف للمشكلة"),
    "reportPostPrompt" : MessageLookupByLibrary.simpleMessage("التبليغ عن مشاركة"),
    "resharePrompt" : MessageLookupByLibrary.simpleMessage("إعادة نشر المشاركة؟"),
    "resharesHeader" : MessageLookupByLibrary.simpleMessage("إعادة النشر"),
    "saveButtonLabel" : MessageLookupByLibrary.simpleMessage("احفظ"),
    "searchDialogHint" : MessageLookupByLibrary.simpleMessage("ابحث"),
    "searchPeopleByTagHint" : MessageLookupByLibrary.simpleMessage("أدرج وسما"),
    "searchPeopleHint" : MessageLookupByLibrary.simpleMessage("أكتب اسم أو معرف داياسبورا*"),
    "searchTagsHint" : MessageLookupByLibrary.simpleMessage("اكتب الوسم"),
    "searchTypePeople" : MessageLookupByLibrary.simpleMessage("أشخاص"),
    "searchTypePeopleByTag" : MessageLookupByLibrary.simpleMessage("أشخاص بوسوم"),
    "searchTypeTags" : MessageLookupByLibrary.simpleMessage("وسوم"),
    "selectAllButtonLabel" : MessageLookupByLibrary.simpleMessage("حدد الكل"),
    "selectButtonLabel" : MessageLookupByLibrary.simpleMessage("اختر"),
    "sendNewConversation" : MessageLookupByLibrary.simpleMessage("أرسل"),
    "sentCommentReport" : MessageLookupByLibrary.simpleMessage("تم التبليغ."),
    "sentPostReport" : MessageLookupByLibrary.simpleMessage("تم التبليغ."),
    "showAllNsfwPostsButtonLabel" : MessageLookupByLibrary.simpleMessage("اعرض المشاركات ذات المحتوى الحساس"),
    "showOriginalPost" : MessageLookupByLibrary.simpleMessage("اعرض المشاركة الاصلية لاعادة النشر"),
    "showThisNsfwPostButtonLabel" : MessageLookupByLibrary.simpleMessage("اعرض هذه المشاركة"),
    "signInAction" : MessageLookupByLibrary.simpleMessage("لِج"),
    "signInHint" : MessageLookupByLibrary.simpleMessage("username@diaspora.pod"),
    "signInLabel" : MessageLookupByLibrary.simpleMessage("معرف داياسبورا*"),
    "startPostSubscription" : MessageLookupByLibrary.simpleMessage("مكن الاشعارات"),
    "startedSharing" : m29,
    "stoppedSharing" : m30,
    "streamNameActivity" : MessageLookupByLibrary.simpleMessage("النشاطات"),
    "streamNameAspects" : MessageLookupByLibrary.simpleMessage("الفئات"),
    "streamNameCommented" : MessageLookupByLibrary.simpleMessage("مُعلِق عليها"),
    "streamNameFollowedTags" : MessageLookupByLibrary.simpleMessage("الوسوم المتّبعة"),
    "streamNameLiked" : MessageLookupByLibrary.simpleMessage("الإعجابات"),
    "streamNameMain" : MessageLookupByLibrary.simpleMessage("ساحة المشاركات"),
    "streamNameMentions" : MessageLookupByLibrary.simpleMessage("الإشارات"),
    "streamNameTag" : MessageLookupByLibrary.simpleMessage("وسم"),
    "submitButtonLabel" : MessageLookupByLibrary.simpleMessage("أرسل"),
    "tagSearchDialogHint" : MessageLookupByLibrary.simpleMessage("ابحث عن وسم"),
    "takeNewPicture" : MessageLookupByLibrary.simpleMessage("إلتقط صورة جديدة"),
    "takePhoto" : MessageLookupByLibrary.simpleMessage("التقط صورة"),
    "unblockUser" : MessageLookupByLibrary.simpleMessage("ألغ الحظر"),
    "updatedProfile" : MessageLookupByLibrary.simpleMessage("حُدث الملف الشخصي."),
    "uploadNewPicture" : MessageLookupByLibrary.simpleMessage("ارفع صورة جديدة"),
    "uploadPhoto" : MessageLookupByLibrary.simpleMessage("ارفع صورة"),
    "uploadProfilePictureHeader" : MessageLookupByLibrary.simpleMessage("حدث صورة الملف الشخصي"),
    "voteButtonLabel" : MessageLookupByLibrary.simpleMessage("صوَّت"),
    "voteCount" : m31,
    "yesButtonLabel" : MessageLookupByLibrary.simpleMessage("نعم")
  };
}
