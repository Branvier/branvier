// // ignore_for_file: only_throw_errors, avoid_dynamic_calls

// import 'package:flutter/material.dart';
// import 'branvier.dart';

// abstract class PageWidget<T> extends StatelessWidget {
//   //ignore: prefer_const_constructors_in_immutables
//   PageWidget({super.key});
//   late final T controller;
// }

// class PageBinder<T> {
//   PageBinder(this.widget, this.controller);

//   final PageWidget<T> widget;
//   final T controller;

//   PageWidget<T> _page() {
//     widget.controller = controller;
//     return widget;
//   }

//   PageWidget<T> Function() get page => _page;
// }

// class HomePage extends PageWidget<HomeController> {
//   HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// class HomeController {
//   late final CountService count; // get<CountService>();

//   Future<void> onPlusTap() async => count.increase();

//   Future<void> onMinusTap() async => count.decrease();
// }

// class RxState {
//   dynamic get value => throw 'implement';
//   set value(value) => throw 'implement';
// }

// class CountService {
//   CountService(this.repository);

//   final CountRepository repository;
//   late final RxState state;

//   Future<void> init() => repository.loadOne('1');

//   Stream<int> streamOne() async* {
//     // final data = await repository.loadOne('1');
//   }

//   Future<void> increase() async {
//     final value = state.value + 1;
//     await repository.saveOne('1', value as int);

//     state.value = value;
//   }

//   Future<void> decrease() async {
//     final value = state.value + 1;
//     await repository.saveOne('1', value as int);
//     state.value = value;
//   }
// }

// // ignore: prefer_mixin
// class CountRepository with MyApi, MyStorage {
//   final key = 'count';

//   Future<int?> loadOne(String id) async {
//     final map = await readAs(key);
//     return map?[id] != null ? int.tryParse(map[id] as String) : null;
//   }

//   Future<void> saveOne(String id, int data) async {
//     await writeSub(key, id, data.toString());
//   }
// }

// class MyApi implements IApi {
//   @override
//   Never get<T>(String path) => throw UnimplementedError();

//   @override
//   Never post<T>(String path, [data]) => throw UnimplementedError();

//   @override
//   String baseUrl = '';

//   @override
//   Map<String, String> headers = {};
// }

// class MyStorage implements IBox {
//   @override
//   Future<String?> read(String key) => throw UnimplementedError();

//   @override
//   Future<void> write(String key, String json) => throw UnimplementedError();

//   @override
//   Future<void> delete(String key) => throw UnimplementedError();

//   @override
//   Future<void> deleteAll() => throw UnimplementedError();

//   @override
//   Future<Json> readAll() => throw UnimplementedError();
// }
