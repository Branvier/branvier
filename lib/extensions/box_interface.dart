// ignore_for_file: avoid_dynamic_calls, deprecated_member_use_from_same_package

part of '/branvier.dart';

///An [IBox] used for secure storage.
abstract class ISafeBox implements IBox {
  @override
  Future<T?> read<T>(String key, {T? or});
  @override
  Future<Json> readAll();
}

///An [IBox] used for accessible storage.
abstract class IOpenBox implements IBox {
  @override
  T? read<T>(String key, {T? or});
  @override
  Json readAll();
}

///A storage interface for key/value databases.
abstract class IBox {
  ///Reads [key], if null, sets and gets [or].
  FutureOr<T?> read<T>(String key, {T? or});

  ///Writes [data] in [key].
  Future<void> write(String key, data);

  ///Removes data in [key].
  Future<void> delete(String key);

  ///Clear all data.
  Future<void> deleteAll();

  ///Gets all data.
  FutureOr<Json> readAll();
}

///Storage extension.
extension StorageExtension on IBox {
  ///Gets current data and sets with [update].
  Future<void> update<T>(String key, T update(T? data)) async {
    final newData = update(await read(key));
    await write(key, newData);
  }
} // tested

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
  FutureOr<T?> read<T>(key, {or}) =>
      storage[key] ?? write(key, or).then((_) => or);

  @override
  FutureOr<Json> readAll() => storage;

  @override
  Future<void> delete(key) => storage.remove(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<void> write(key, data) => storage[key] = data;
}
