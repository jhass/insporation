import 'package:app_badge_plus/app_badge_plus.dart';

class BadgeService {
  // Badge updates are best-effort and should not break app flows on unsupported launchers.
  static Future<void> updateCount(int count) async {
    try {
      if (await AppBadgePlus.isSupported()) {
        await AppBadgePlus.updateBadge(count);
      }
    } catch (_) {
      // Ignore badge plugin failures.
    }
  }
}
