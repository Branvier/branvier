library state;

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import 'branvier.dart';

export 'package:get/get_rx/src/rx_types/rx_types.dart';
export 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

extension RxnT<T> on T {
  /// Returns a `Rx<T?>` instance with `null` as initial value.
  Rx<T?> get obn => Rx<T?>(null);
}

class ObxListBuilder<T extends Object> extends ObxWidget {
  ///Reactive list builder that handles loading, empty, error and sucess states.
  const ObxListBuilder({
    required this.obx,
    required this.builder,
    this.future,
    this.controller,
    this.states = const AsyncStates(),
    this.config = const ListConfig(),
    super.key,
  });

  ///Reactive rebuilder just like Obx(()=>).
  final List<T> Function() obx;
  final Widget Function(T item, int i) builder; //sucess

  //Async
  final Future<void> Function()? future;
  final AsyncController<T>? controller;
  final AsyncStates states;
  final ListConfig<T> config;

  @override
  Widget build(BuildContext context) {
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
    super.key,
  });

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
    return AsyncBuilder(
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
    super.key,
  });

  ///Reactive rebuilder just like Obx(()=>).
  final T? Function() obx;
  final Widget Function(T data) builder; //sucess

  //Async
  final AsyncController<T>? controller;
  final Future<void> Function()? future;
  final AsyncStates states;

  @override
  Widget build(BuildContext context) {
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
