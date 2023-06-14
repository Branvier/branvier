library state;

import 'package:flutter/material.dart';
import 'branvier.dart';


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

