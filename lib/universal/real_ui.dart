import 'dart:ui' as ui;

// ignore: camel_case_types
mixin platformViewRegistry {
  static dynamic registerViewFactory(String viewId, cb) {
    // ignore:undefined_prefixed_name, avoid_dynamic_calls
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}
