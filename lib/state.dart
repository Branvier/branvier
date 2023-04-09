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

class ObxBuilder<T> extends ObxWidget {
  ///Reactive builder that handles loading, empty, error and sucess states.
  const ObxBuilder({
    required this.obx,
    required this.builder,
    this.async,
    this.states = const AsyncStates(),
    super.key,
  });

  ///Reactive list builder that handles loading, empty, error and sucess states.
  static Widget list<T extends Object>({
    required List<T>? Function() obx,
    required Widget Function(T item, int i) builder,
    Async<void>? async,
    AsyncStates states = const AsyncStates(),
    ListConfig config = const ListConfig(),
  }) {
    return ObxBuilder(
      obx: obx,
      async: async,
      states: states,
      builder: (items) {
        return ListBuilder<T>(
          list: items,
          builder: builder,
          config: config,
        );
      },
    );
  }

  ///Reactive rebuilder just like Obx(()=>).
  final T? Function() obx;
  final Widget Function(T data) builder; //sucess

  //Async
  final Async<void>? async;
  final AsyncStates states;

  @override
  Widget build() {
    final data = obx();

    return AsyncBuilder(
      async: async?.stream != null
          ? Async.stream(
              initialData: data,
              controller: async?.controller,
              interval: async?.interval,
              () async* {
                await for (final _ in async!.stream!()) {}
                yield data;
              },
            )
          : Async.future(
              initialData: data,
              controller: async?.controller,
              interval: async?.interval,
              () async {
                await async?.future?.call();
                return data;
              },
            ),
      builder: (_) {
        if (data == null) return states.onNull;
        if (['', [], {}].contains(data)) return states.onEmpty;
        return builder(data);
      },
      states: states,
    );
  }
}
