// ignore_for_file: public_member_api_docs, sort_constructors_first
// library branvier_extensions;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'context.dart';
part 'json.dart';
part 'notifier.dart';
part 'numbers.dart';
part 'shimmer.dart';
part 'texts.dart';
part 'time.dart';
part 'widget.dart';
part 'translation.dart';
part 'api_interface.dart';
part 'storage_interface.dart';

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
