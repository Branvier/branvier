library state;

import 'package:flutter/material.dart';
import 'package:getx_lite/getx_lite.dart';

import 'branvier.dart';

export 'package:getx_lite/getx_lite.dart' hide ListExtension;


class ObxListBuilder<T extends Object> extends ObxWidget {
  ///Reactive list builder that handles loading, empty, error and sucess states.
  const ObxListBuilder({
    required this.obx,
    required this.builder,
    this.future,
    this.controller,
    this.states = const AsyncStates(),
    this.config = const ListConfig(),
    Key? key,
  }) : super(key: key);

  ///Reactive rebuilder just like Obx(()=>).
  final List<T> Function() obx;
  final Widget Function(T item, int i) builder; //sucess

  //Async
  final Future<void> Function()? future;
  final AsyncController<T>? controller;
  final AsyncStates states;
  final ListConfig<T> config;

  @override
  Widget build() {
    return AsyncListBuilder(
      list: obx(),
      builder: builder,
      future: future,
      controller: controller,
      states: states,
      config: config,
    );
  }
}

class AsyncListBuilder<T extends Object> extends StatelessWidget {
  const AsyncListBuilder({
    required this.list,
    required this.builder,
    this.future,
    this.controller,
    this.states = const AsyncStates(),
    this.config = const ListConfig(),
    Key? key,
  }) : super(key: key);

  ///Reactive rebuilder just like Obx(()=>).
  final List<T> list;
  final Widget Function(T item, int i) builder; //sucess

  //Async
  final AsyncController<T>? controller;
  final Future<void> Function()? future;
  final AsyncStates states;
  final ListConfig<T> config;

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<T>>(
      initialData: list,
      controller: controller,
      future: () async {
        await future?.call();
        return list;
      },
      builder: (list) {
        return ListBuilder(list: list, builder: builder, config: config);
      },
    );
  }
}

class ObxBuilder<T> extends ObxWidget {
  ///Reactive builder that handles loading, empty, error and sucess states.
  const ObxBuilder({
    required this.obx,
    required this.builder,
    this.future,
    this.controller,
    this.states = const AsyncStates.min(),
    Key? key,
  }) : super(key: key);

  ///Reactive rebuilder just like Obx(()=>).
  final T? Function() obx;
  final Widget Function(T data) builder; //sucess

  //Async
  final AsyncController<T>? controller;
  final Future<void> Function()? future;
  final AsyncStates states;

  @override
  Widget build() {
    return AsyncBuilder(
      controller: controller,
      initialData: obx(),
      future: () async {
        await future?.call();
        return obx();
      },
      builder: (_) {
        final data = obx();
        if (data == null) return states.onNull;
        if (data is Iterable && data.isEmpty) return states.onEmpty;
        return builder(data);
      },
      states: states,
    );
  }
}

extension GetxListExtension<E> on List<E> {
  RxList<E> get obs => RxList<E>(this);
}
