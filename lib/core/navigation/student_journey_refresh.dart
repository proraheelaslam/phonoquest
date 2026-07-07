import 'package:flutter/foundation.dart';

/// Notifies [JourneyScreen] to reload learning-adventures after module activity.
class StudentJourneyRefresh {
  StudentJourneyRefresh._();

  static final ValueNotifier<int> tick = ValueNotifier(0);

  static void notify() {
    tick.value++;
  }
}
