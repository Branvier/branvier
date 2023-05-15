library branvier;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

// import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mocktail/mocktail.dart';

import 'widgets/list_builder/list_builder.dart';
import 'widgets/types/widget_types.dart';

export 'package:dartx/dartx.dart';
export 'package:flutter_animate/flutter_animate.dart';

export 'widgets/animations/index.dart';

part 'extensions/api_interface.dart';
part 'extensions/box_interface.dart';
part 'extensions/context.dart';
part 'extensions/json.dart';
part 'extensions/list.dart';
part 'extensions/navigation.dart';
part 'extensions/notifier.dart';
part 'extensions/numbers.dart';
part 'extensions/shimmer.dart';
part 'extensions/string.dart';
part 'extensions/texts.dart';
part 'extensions/time.dart';
part 'extensions/translation.dart';
part 'extensions/validators.dart';
part 'extensions/widget.dart';
part 'hooks/use_animate.dart';
part 'hooks/use_async.dart';
part 'hooks/use_lifecycle.dart';
part 'hooks/use_size.dart';
part 'utils/transparent_image.dart';
part 'widgets/async_builder.dart';
part 'widgets/async_button.dart';
part 'widgets/formx.dart';
part 'widgets/list_builder.dart';
part 'widgets/modular.dart';
part 'widgets/nest_builder.dart';
part 'widgets/page_builder.dart';

///Package configuration.
mixin Branvier {
  static GlobalKey<NavigatorState>? _navigatorKey;

  ///Set this on [MaterialApp]. No need if you use [ModularApp].
  ///
  ///This will be used for:
  /// - [Translation] change language updates.
  /// - [Messenger] dialogs, snackbars and bottomsheets.
  static GlobalKey<NavigatorState> get navigatorKey {
    return _navigatorKey ??= GlobalKey<NavigatorState>();
  }

  //Internal
  static GlobalKey<NavigatorState> get _key {
    final key = _navigatorKey ?? Modular.routerDelegate.navigatorKey;
    if (key.currentState == null) {
      dev.log(
        '[Branvier] key not attached. '
        'Put Branvier.navigatorKey on [MaterialApp] navigatorKey parameter '
        'Obs: You must wait [MaterialApp] to be built',
      );
    }
    return key;
  }

  ///Get the current navigator context.
  static BuildContext? get context => _key.currentContext;

  ///Get the current navigator state.
  static NavigatorState? get state => _key.currentState;

  ///Get the topmost overlay context.
  static BuildContext? get overlay {
    var overlay = state?.overlay?.context;
    overlay?.visitChildElements((el) => overlay = el);
    return overlay;
  }
}

///Schedule a callback for the end of this frame.
void postFrame(VoidCallback? callback) =>
    engine.addPostFrameCallback((_) => callback?.call());

///The current [WidgetsBinding].
WidgetsBinding get engine => WidgetsFlutterBinding.ensureInitialized();

///Tells if the *system* [Theme] is dark. Not the app theme.
bool get kIsDark =>
    engine.platformDispatcher.platformBrightness == Brightness.dark;

/// A dart:ui access point. Obs: It's immutable! For adaptativeness use context [MediaQuery].
mixin Ui {
  /// The window to which this binding is bound.
  static ui.FlutterView get window => ui.window;

  ///System's [Locale].
  static Locale? get deviceLocale => ui.window.locale;

  ///The number of device pixels for each logical pixel.
  static double get pixelRatio => ui.window.devicePixelRatio;

  ///The [Size] of this device in logical pixels.
  static Size get size => ui.window.physicalSize / pixelRatio;

  ///The horizontal extent of this size.
  static double get width => size.width;

  ///The vertical extent of this size
  static double get height => size.height;

  ///The distance from the top edge to the first unpadded pixel,
  ///in physical pixels.
  static double get statusBarHeight => ui.window.padding.top;

  ///The distance from the bottom edge to the first unpadded pixel,
  ///in physical pixels.
  static double get bottomBarHeight => ui.window.padding.bottom;

  ///The system-reported text scale.
  static double get textScaleFactor => ui.window.textScaleFactor;
}

extension UriExtension on Uri {
  ///Returns a parsed and decoded parameters from the Url.
  Json get args {
    var uri = this;
    if (queryParameters.isEmpty) uri = Uri.parse(uri.fragment);

    final map = <String, dynamic>{};
    uri.queryParameters.forEach((key, value) => map[key] = jsonDecode(value));

    return map;
  }
}
