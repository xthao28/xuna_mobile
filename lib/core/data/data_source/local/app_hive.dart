abstract class AppHive {
  Future<void> put(String key, dynamic value);

  T? get<T>(String key);

  Future<void> delete(String key);

  Future<int> deleteAll();

  Future<void> deleteKeys(List<String> keys);
}
