import 'dart:ui';

import 'package:catcher/model/localization_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'posts.dart';

// Keep timeagoLocaleMessages in timeago.dart in sync!
// Keep catcherLocalizationOptions below in sync!
// Add iOS specific translation files to the project via "Add Files to"
const supportedLocales = [
  const Locale('ar'),
  const Locale('de'),
  const Locale('en'),
  const Locale('fr'),
  const Locale('gl'),
  const Locale('hr'),
  const Locale('it')
];

final catcherLocalizationOptions = [
  CatcherLocalization('ar'),
  CatcherLocalization('de', defaults: LocalizationOptions.buildDefaultGermanOptions()),
  CatcherLocalization('en'),
  CatcherLocalization('fr', defaults: LocalizationOptions.buildDefaultFrenchOptions()),
  CatcherLocalization('gl'),
  CatcherLocalization('hr'),
  CatcherLocalization('it', defaults: LocalizationOptions.buildDefaultItalianOptions())
];

mixin LocalizationHelpers {
  AppLocalizations l(BuildContext context) => AppLocalizations.of(context)!;

  MaterialLocalizations ml(BuildContext context) => MaterialLocalizations.of(context);
}

mixin StateLocalizationHelpers<T extends StatefulWidget> on State<T> {
  AppLocalizations get l => AppLocalizations.of(context)!;

  MaterialLocalizations get ml => MaterialLocalizations.of(context);
}

extension StreamName on AppLocalizations {
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
  }
}

class CatcherLocalization implements LocalizationOptions {
  final String languageCode;
  final LocalizationOptions defaults;
  late final AppLocalizations _localizations;

  CatcherLocalization(this.languageCode, {LocalizationOptions? defaults}) :
    this.defaults = defaults ?? LocalizationOptions.buildDefaultEnglishOptions() {
      AppLocalizations.delegate.load(Locale(languageCode)).then((localizations) => this._localizations = localizations);
    }

  @override
  String get dialogReportModeTitle => _localizations.catcherLocalizationDialogReportModeTitle;

  @override
  String get dialogReportModeDescription => _localizations.catcherLocalizationDialogReportModeDescription;

  @override
  String get dialogReportModeAccept => _localizations.catcherLocalizationDialogReportModeAccept;

  @override
  String get dialogReportModeCancel => _localizations.catcherLocalizationDialogReportModeCancel;

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

  @override
  String get toastHandlerDescription => defaults.toastHandlerDescription;
}
