// ignore_for_file: avoid_dynamic_calls, deprecated_member_use_from_same_package

part of '/branvier.dart';

///An [_IBoxBase] used for secure storage.
abstract class ISafeBox implements _IBoxBase {}

///An [_IBoxBase] used for accessible asynchronous storage.
abstract class IAsyncBox implements _IBoxBase {}

@Deprecated('Use just IBox for synchronous storage. for async use IAsyncBox')
abstract class IOpenBox implements _IBoxBase {}

///An [_IBoxBase] used for accessible synchronous storage.
abstract class IBox implements _IBoxBase {
  @override
  T? read<T>(String key, {T? or});
  @override
  Json readAll();
}

///A storage interface for key/value databases. Use [ISafeBox] or [IBox]
@protected
abstract class _IBoxBase {
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
extension StorageExtension on _IBoxBase {
  ///Gets current data and sets with [update].
  Future<void> update<T>(String key, T update(T? data)) async {
    final newData = update(await read(key));
    await write(key, newData);
  }
} // tested

///Simple fake key/value storage.
class FakeBox extends Mock implements IBox, ISafeBox, IAsyncBox, _IBoxBase {
  ///Functional FakeBox. You can start with [initialData] content.
  FakeBox([this.initialData = const {}]) {
    storage.addAll(initialData);
  }

  ///Fake storage.
  final Json storage = {};
  final Json initialData;

  @override
  T? read<T>(key, {or}) {
    final data = storage[key];
    if (data != null && or != null) write(key, or);
    return data ?? or;
  }

  @override
  Json readAll() => storage;

  @override
  Future<void> delete(key) async => storage.remove(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<void> write(key, data) async => storage[key] = data;
}
