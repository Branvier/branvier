part of '/branvier.dart';

abstract class IStorage {
  ///Reads the data, gets the [def] value if null.
  Future<String?> read(String key);

  ///Writes the data.
  Future<void> write(String key, String value);

  ///Removes the data.
  Future<void> delete(String key);

  ///Clear all data.
  Future<void> deleteAll();

  ///Gets all data.
  Future<Json> readAll();
}

typedef JMap = Map<String, String>;
typedef JList = List<String>;

extension StorageExt on IStorage {
  ///Read and decodes as [T].
  Future<T?> readAs<T>(String key) async {
    final json = await read(key);
    return json != null ? jsonDecode(json) : null;
  }

  ///Writes in a [subkey] inside this [key].
  Future<void> subkey(String key, String subkey, String json) async =>
      modifyAs<JMap>(key, (map) => (map ?? {})..[subkey] = json);

  ///Merges the old json with this [map].
  Future<void> merge(String key, Json map) async =>
      modifyAs<Json>(key, (from) => map..addAll(from ?? {}));

  ///Adds [json] to cache list without overwriting.
  Future<void> append(
    String key,
    String json, {
    bool duplicates = false,
  }) async =>
      modifyAs<JList>(key, (data) {
        final list = data ?? [];
        if (!duplicates) list.toSet().toList();
        return list..add(json);
      });

  ///Returns the current cached json and sets after [modifier].
  Future<void> modify(String key, Handler<String> modifier) async {
    final modified = modifier(await read(key));
    await write(key, modified);
  }

  ///Returns the current decoded json and sets after [modifier].
  Future<void> modifyAs<T>(String key, Handler<T> modifier) async {
    final source = await read(key);
    final data = source != null ? jsonDecode(source) : null;
    final modified = modifier(data);
    await write(key, jsonEncode(modified));
  }
}
