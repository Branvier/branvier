library state;

import 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
extension RxnT<T> on T {
  /// Returns a `Rx<T?>` instance with `null` as initial value.
  Rx<T?> get obn => Rx<T?>(null);
}
