import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class TimezoneService {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // MVP assumption: Romanian-first app, so we default to Europe/Bucharest.
    //
    // Note: Getting the device IANA timezone reliably requires an additional
    // platform plugin. For v0.1.x we keep this simple and document the risk in QA.
    tz.setLocalLocation(tz.getLocation('Europe/Bucharest'));
    _initialized = true;
  }
}

