library branvier;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

part 'extensions/context.dart';
part 'extensions/json.dart';
part 'extensions/notifier.dart';
part 'extensions/numbers.dart';
part 'extensions/shimmer.dart';
part 'extensions/texts.dart';
part 'extensions/time.dart';
part 'extensions/widget.dart';
part 'extensions/translation.dart';
part 'extensions/validators.dart';
part 'extensions/api_interface.dart';
part 'extensions/storage_interface.dart';
part 'widgets/formx.dart';
part 'widgets/async_builder.dart';
part 'widgets/nest_builder.dart';
part 'widgets/page_builder.dart';
part 'hooks/use_animate.dart';
part 'hooks/use_async.dart';
part 'hooks/use_lifecycle.dart';
part 'hooks/use_size.dart';

typedef InOut<In, Out> = Out Function(In value);
typedef Input<T> = void Function(T value);
typedef Output<T> = T Function();
typedef Echo<T> = T Function(T value);

typedef Handler<T> = T Function(T? data);
typedef OnEvent<T> = void Function(T data);
typedef OnBuild<T> = Widget Function(T data);
typedef OnAsync<T> = Future Function(T data);

typedef Then<T, R> = FutureOr<R> Function(T value);
typedef Json<T> = Map<String, T>;

///Schedule a callback for the end of this frame.
void postFrame(VoidCallback? callback) =>
    engine.addPostFrameCallback((_) => callback?.call());

///The current [WidgetsBinding].
WidgetsBinding get engine => WidgetsFlutterBinding.ensureInitialized();

extension ListExt<F> on Iterable<F> {
  List<T> list<T>(InOut<F, T> toElement) => map<T>(toElement).toList();
}
