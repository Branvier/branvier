library branvier;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'extensions/api_interface.dart';
part 'extensions/context.dart';
part 'extensions/json.dart';
part 'extensions/list.dart';
part 'extensions/map.dart';
part 'extensions/notifier.dart';
part 'extensions/numbers.dart';
part 'extensions/shimmer.dart';
part 'extensions/storage_interface.dart';
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
part 'widgets/formx.dart';
part 'widgets/nest_builder.dart';
part 'widgets/page_builder.dart';

///Schedule a callback for the end of this frame.
void postFrame(VoidCallback? callback) =>
    engine.addPostFrameCallback((_) => callback?.call());

///The current [WidgetsBinding].
WidgetsBinding get engine => WidgetsFlutterBinding.ensureInitialized();
