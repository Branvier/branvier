library branvier;

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mocktail/mocktail.dart';

import 'widgets/list_builder/list_builder.dart';
import 'widgets/types/widget_types.dart';

export 'widgets/animations/index.dart';

part 'extensions/api_interface.dart';
part 'extensions/bool.dart';
part 'extensions/box_interface.dart';
part 'extensions/context.dart';
part 'extensions/json.dart';
part 'extensions/list.dart';
part 'extensions/map.dart';
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
part 'utils/typedefs.dart';
part 'widgets/async_builder.dart';
part 'widgets/async_button.dart';
part 'widgets/formx.dart';
part 'widgets/list_builder.dart';
part 'widgets/nest_builder.dart';
part 'widgets/modular.dart';
part 'widgets/page_builder.dart';

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
  ui.SingletonFlutterWindow get window => ui.window;

  ///System's [Locale].
  Locale? get deviceLocale => ui.window.locale;

  ///The number of device pixels for each logical pixel.
  double get pixelRatio => ui.window.devicePixelRatio;

  ///The [Size] of this device in logical pixels.
  Size get size => ui.window.physicalSize / pixelRatio;

  ///The horizontal extent of this size.
  double get width => size.width;

  ///The vertical extent of this size
  double get height => size.height;

  ///The distance from the top edge to the first unpadded pixel,
  ///in physical pixels.
  double get statusBarHeight => ui.window.padding.top;

  ///The distance from the bottom edge to the first unpadded pixel,
  ///in physical pixels.
  double get bottomBarHeight => ui.window.padding.bottom;

  ///The system-reported text scale.
  double get textScaleFactor => ui.window.textScaleFactor;
}
