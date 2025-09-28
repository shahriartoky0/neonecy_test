import 'package:get_storage/get_storage.dart';

class GetStorageModel {
  final GetStorage _storage = GetStorage();

  // Method to save an object (string, int, bool, etc.)
  Future<void> save(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  // Method to read an object
  dynamic read(String key) {
    return _storage.read(key);
  }

  // Method to update an object
  Future<void> update(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  // Method to delete an object
  Future<void> delete(String key) async {
    await _storage.remove(key);
  }

  // Method to check if a key exists
  bool exists(String key) {
    return _storage.hasData(key);
  }
}
