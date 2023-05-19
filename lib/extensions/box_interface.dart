// ignore_for_file: avoid_dynamic_calls, deprecated_member_use_from_same_package

part of '/branvier.dart';

///An [IBoxBase] used for secure storage.
abstract class ISafeBox implements IBoxBase {}

@Deprecated('Use just IBox')
abstract class IOpenBox implements IBoxBase {}

///An [IBoxBase] used for accessible storage.
abstract class IBox implements IBoxBase {
  @override
  T? read<T>(String key, {T? or});
  @override
  Json readAll();
}

///A storage interface for key/value databases. Use [ISafeBox] or [IBox]
@protected
abstract class IBoxBase {
  ///Reads [key], if null, sets and gets [or].
  FutureOr<T?> read<T>(String key, {T? or});

  ///Gets all data.
  FutureOr<Json> readAll();

  ///Writes [data] in [key].
  Future<void> write(String key, data);

  ///Removes data in [key].
  Future<void> delete(String key);

  ///Clear all data.
  Future<void> deleteAll();
}

///Storage extension.
extension StorageExtension on IBoxBase {
  ///Gets current data and sets with [update].
  Future<void> update<T>(String key, T update(T? data)) async {
    final newData = update(await read(key));
    await write(key, newData);
  }
} // tested

///Simple fake key/value storage.
class FakeBox extends Mock implements IBox, ISafeBox, IBoxBase {
  ///Functional FakeBox. You can start with [initialData] content.
  FakeBox([this.initialData = const {}]) {
    storage.addAll(initialData);
  }

  ///Fake storage.
  final Json storage = {};
  final Json initialData;

  @override
  T? read<T>(key, {or}) =>
      storage[key] ?? write(key, or).then((_) => or);

  @override
  Json readAll() => storage;

  @override
  Future<void> delete(key) async => storage.remove(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<void> write(key, data) async => storage[key] = data;
}
