part of '/branvier.dart';

abstract class IBox {
  ///Reads the json data.
  Future<String?> read(String key);

  ///Writes the json data.
  Future<void> write(String key, String json);

  ///Removes the json data.
  Future<void> delete(String key);

  ///Clear all data.
  Future<void> deleteAll();

  ///Gets all data.
  Future<Json> readAll();
}

///Simple key/value storage Mocker.
///
///It does save data, but temporarily (app session).
class MockBox implements IBox {
  ///Functional MockBox. You can start with [initial] content.
  MockBox([this.initial = const {}]) {
    storage.addAll(initial);
  }

  ///Fake storage.
  final StringMap storage = {};
  final StringMap initial;

  ///Set up back to [initial].
  void reset() {
    storage.clear();
    storage.addAll(initial);
  }

  @override
  Future<void> delete(String key) async => storage.remove(key);

  @override
  Future<void> deleteAll() async => storage.clear();

  @override
  Future<String?> read(String key) async => storage[key];

  @override
  Future<Json> readAll() async => storage;

  @override
  Future<void> write(String key, String value) async => storage[key] = value;
}

///Storage extension.
///
///Test: 'storage' in storage_test. All tested.
extension StorageExt on IBox {
  ///Read and decodes as [T].
  Future<T?> readAs<T>(String key) async => (await read(key))?.parse<T>();

  ///Read in a [subkey] inside this [key].
  Future<T?> readSubAs<T>(String key, String subkey) async {
    final map = await readAs<Json>(key);
    final json = jsonEncode(map?[subkey]);
    return json.parse<T>();
  }

  ///Read in a [subkey] inside this [key].
  Future<String?> readSub(String key, String subkey) =>
      readSubAs<String>(key, subkey);

  ///Writes in a [subkey] inside this [key].
  Future<void> writeSub(String key, String subkey, String json) async {
    return modifyAs<Json>(key, (map) {
      return (map ?? {})..[subkey] = json.parse();
    });
  }

  ///Merges the old json with this [map].
  Future<void> merge(String key, Json map) async =>
      modifyAs<Json>(key, (from) => map..addAll(from ?? {}));

  ///Adds [json] to cache list without overwriting.
  Future<void> append(
    String key,
    String json, {
    bool duplicates = false,
  }) async =>
      modifyAs<Strings>(key, (data) {
        final list = [...?data, json];
        if (duplicates) return list;
        return list.toSet().toList();
      });

  ///Returns the current cached json and sets after [modifier].
  Future<void> modify(String key, EchoGet<String> modifier) async {
    final modified = modifier(await read(key));
    await write(key, modified);
  }

  ///Returns the current decoded json and sets after [modifier].
  Future<void> modifyAs<T>(String key, EchoGet<T> modifier) async {
    final modified = modifier(await readAs<T>(key));
    await write(key, jsonEncode(modified));
  }
}
