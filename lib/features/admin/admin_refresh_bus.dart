import 'package:flutter/foundation.dart';

class AdminRefreshBus {
  AdminRefreshBus._();

  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static void notifyUpdated() {
    tick.value = tick.value + 1;
  }
}
