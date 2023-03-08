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

import 'hooks/use_async.dart';

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

typedef FromTo<From, To> = To Function(From from);
typedef Handler<T> = T Function(T? data);
typedef OnEvent<T> = void Function(T data);
typedef OnBuild<T> = Widget Function(T data);
typedef Json<T> = Map<String, T>;
typedef Strings = List<String>;

typedef Setter<T> = void Function(T value);
typedef Getter<T> = T Function();

///Schedule a callback for the end of this frame.
void postFrame(VoidCallback? callback) =>
    engine.addPostFrameCallback((_) => callback?.call());

///The current [WidgetsBinding].
WidgetsBinding get engine => WidgetsFlutterBinding.ensureInitialized();

extension ListExt<F> on Iterable<F> {
  List<T> list<T>(FromTo<F, T> toElement) => map<T>(toElement).toList();
}
