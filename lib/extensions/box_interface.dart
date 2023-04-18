// ignore_for_file: avoid_dynamic_calls, deprecated_member_use_from_same_package

part of '/branvier.dart';

abstract class IBox {
  ///Reads the json data.
  FutureOr<T?> read<T>(String key);

  ///Writes the json data.
  FutureOr<void> write(String key, data);

  ///Removes the json data.
  FutureOr<void> delete(String key);

  ///Clear all data.
  FutureOr<void> deleteAll();

  ///Gets all data.
  FutureOr<Json> readAll();
}

///Simple fake key/value storage.
class FakeBox extends Mock implements IBox {
  ///Functional FakeBox. You can start with [initialData] content.
  FakeBox([this.initialData = const {}]) {
    storage.addAll(initialData);
  }

  ///Fake storage.
  final Json storage = {};
  final Json initialData;

  @override
  Future<void> delete(key) async => storage.remove(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<T?> read<T>(key) async => storage[key] as T?;

  @override
  Future<Json> readAll() async => storage;

  @override
  Future<void> write(key, data) async => storage[key] = data;
}

///Storage extension.
extension StorageExtension on IBox {
  ///Gets current data and sets with [update].
  Future<void> update<T>(String key, T update(T? data)) async {
    final newData = update(await read(key));
    await write(key, newData);
  }
} // tested
