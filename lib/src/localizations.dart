import 'package:catcher/model/localization_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_de.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_fr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_gl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_hr.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_it.dart';

import 'posts.dart';

// Keep timeagoLocaleMessages in timeago.dart in sync!
// Keep catcherLocalizationOptions below in sync!
// Add iOS specific translation files to the project via "Add Files to".
// Keep English at the top, the first entry becomes the fallback locale.
const supportedLocales = [
  const Locale('en'),
  const Locale('ar'),
  const Locale('de'),
  const Locale('fr'),
  const Locale('gl'),
  const Locale('hr'),
  const Locale('it')
];

final catcherLocalizationOptions = [
  AppLocalizationsAr().catcherOptions(),
  AppLocalizationsDe().catcherOptions(defaults: LocalizationOptions.buildDefaultGermanOptions()),
  AppLocalizationsEn().catcherOptions(),
  AppLocalizationsFr().catcherOptions(defaults: LocalizationOptions.buildDefaultFrenchOptions()),
  AppLocalizationsGl().catcherOptions(),
  AppLocalizationsHr().catcherOptions(),
  AppLocalizationsIt().catcherOptions(defaults: LocalizationOptions.buildDefaultItalianOptions())
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

extension CatcherLocalization on AppLocalizations {
  LocalizationOptions catcherOptions({LocalizationOptions? defaults}) {
    defaults = defaults ??  LocalizationOptions.buildDefaultEnglishOptions();
    return defaults.copyWith(
      languageCode: localeName,
      dialogReportModeTitle: catcherLocalizationDialogReportModeTitle,
      dialogReportModeDescription: catcherLocalizationDialogReportModeDescription,
      dialogReportModeAccept: catcherLocalizationDialogReportModeAccept,
      dialogReportModeCancel: catcherLocalizationDialogReportModeCancel
    );
  }
}
