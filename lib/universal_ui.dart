library universal_ui;

import 'package:flutter/foundation.dart';
import '/universal/fake_ui.dart'
    if (dart.library.html) '/universal/real_ui.dart' as ui_instance;

class PlatformViewRegistryFix {
  dynamic registerViewFactory(x, y) {
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui_instance.platformViewRegistry.registerViewFactory(
        x as String,
        y,
      );
    } else {}
  }
}

class UniversalUI {
  PlatformViewRegistryFix platformViewRegistry = PlatformViewRegistryFix();
}

var ui = UniversalUI();
