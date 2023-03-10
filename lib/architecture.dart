import 'package:flutter/material.dart';
import 'branvier.dart';

abstract class PageWidget<T> extends StatelessWidget {
  //ignore: prefer_const_constructors_in_immutables
  PageWidget({super.key});
  late final T controller;

}

class PageBinder<T> {
  PageBinder(this.widget, this.controller);

  final PageWidget<T> widget;
  final T controller;

  PageWidget<T> _page() {
    widget.controller = controller;
    return widget;
  }

  get page => _page;
}











class HomePage extends PageWidget<HomeController> {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return const Placeholder();
  }
}

class HomeController {
  late final CountService count; // get<CountService>();

  void onPlusTap() => count.increase();

  void onMinusTap() => count.decrease();
}

class RxState {
  get value => throw 'implement';
  set value(value) => throw 'implement';
}

class CountService {
  CountService(this.repository);

  final CountRepository repository;
  late final RxState state;

  Future<void> init() => repository.loadOne('1');

  Stream<int> streamOne() async* {
    // final data = await repository.loadOne('1');
  }

  void increase() {
    final value = state.value + 1;
    repository.saveOne('1', value);
    
    state.value = value;
  }

  void decrease() {
    final value = state.value + 1;
    repository.saveOne('1', value);
    state.value = value;
  }
}

class CountRepository with MyApi, MyStorage {
  final key = 'count';

  Future<int?> loadOne(String id) async {
    final map = await readAs(key);
    return map?[id] != null ? int.tryParse(map[id]) : null;
  }

  Future<void> saveOne(String id, int data) async {
    subkey(key, id, data.toString());
  }
}

class MyApi implements IApi {
  @override
  get(String path) => throw UnimplementedError();

  @override
  post(String path, [data]) => throw UnimplementedError();

  @override
  String baseUrl = '';

  @override
  String contentType = '';

  @override
  Map<String, String> headers = {};
}

class MyStorage implements IStorage {
  @override
  Future<String?> read(String key) => throw UnimplementedError();

  @override
  Future<void> write(String key, String json) => throw UnimplementedError();

  @override
  Future<void> delete(String key) => throw UnimplementedError();

  @override
  Future<void> deleteAll() => throw UnimplementedError();

  @override
  Future<Json> readAll() => throw UnimplementedError();
}
