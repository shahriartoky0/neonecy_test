import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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

  /// for saving the image path ===================>
  Future<String?> saveImage(String key, File imageFile) async {
    try {
      // Get the app's document directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create an images subdirectory if it doesn't exist
      final Directory imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename (you can customize this)
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final String newPath = '${imagesDir.path}/$fileName';

      // Copy the image to the new location
      final File savedImage = await imageFile.copy(newPath);

      // Store the path in GetStorage
      await _storage.write(key, savedImage.path);

      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Retrieve image file path
  String? getImagePath(String key) {
    return _storage.read(key);
  }

  // Retrieve image as File object
  File? getImageFile(String key) {
    final String? imagePath = _storage.read(key);
    if (imagePath != null && File(imagePath).existsSync()) {
      return File(imagePath);
    }
    return null;
  }

  // Delete image file and its reference
  Future<bool> deleteImage(String key) async {
    try {
      final String? imagePath = _storage.read(key);
      if (imagePath != null) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
        await _storage.remove(key);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
