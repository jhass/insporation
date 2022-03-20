import 'package:catcher/catcher.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'src/localizations.dart';

const _skipableErrors = <String>[
  // Non fatal and nothing we can handle in any way
  'Invalid image data',
  // Not much we can do about the server returning us an URL without a host
  'Invalid argument(s): No host specified in URI '
  // Probably just a failed image load or so. Critical API errors should have been catched or at least rewrapped.
  'HttpException',
  'HTTP request failed, statusCode: 4',
  // Probably the video player didn't like a broken URL in the poster attribute some platforms send us,
  // or the image proxy didn't like to proxy us that video
  'PlatformException(VideoError',
  // System was probably switching networks or so, nothing we can do anything about
  'SocketException',
  'Connection closed before full header was received',
  'Connection closed while receiving data',
  // Suppress non-fatal framework bug. Should be fixed with https://github.com/flutter/flutter/pull/70638
  "NoSuchMethodError: The getter 'status' was called on null",
  // Not much we can do about bad setups
  'CERTIFICATE_VERIFY_FAILED',
  'HandshakeException'
];

bool _shouldReportError(Report report) {
  if (report.error == null) {
    return true;
  }

  final skip = _skipableErrors.any((message) => report.error.toString().toLowerCase().contains(message.toLowerCase()));

  return !skip;
}

void main() => Catcher(
  rootWidget: MultiProvider(
    providers: globalProviders,
    child: Insporation(),
  ),
  debugConfig: CatcherOptions(
    SilentReportMode(),
    [ConsoleHandler()],
    localizationOptions: catcherLocalizationOptions,
    filterFunction: _shouldReportError
  ),
  releaseConfig: CatcherOptions(
    DialogReportMode(),
    [EmailManualHandler(['insporation-bugs@jhass.eu'], emailTitle: "insporation* crash report")],
    localizationOptions: catcherLocalizationOptions,
    filterFunction: _shouldReportError,
    handleSilentError: false
  ),
  navigatorKey: navigator
);