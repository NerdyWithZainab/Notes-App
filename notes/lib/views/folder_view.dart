import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class FolderView {
  // Create a folder
  static Future<String> createFolder(String folderName) async {
    try {
      if (kIsWeb) {
        return _createFolderWeb(folderName);
      }
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = path.join(directory.path, folderName);
      final folder = Directory(folderPath);

      if (!await folder.exists()) {
        await folder.create(recursive: true);
        return 'Folder created: $folderPath';
      } else {
        return 'Folder already exists: $folderPath';
      }
    } catch (e) {
      return 'Error creating folder: $e';
    }
  }

  // List all folders
  static Future<List<String>> listFolders() async {
    try {
      if (kIsWeb) {
        return _listFoldersWeb(); // ✅ Handle web case
      }

      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory(directory.path);

      if (await folder.exists()) {
        return folder
            .listSync()
            .whereType<Directory>()
            .map((dir) => path.basename(dir.path))
            .toList();
      }
      return [];
    } catch (e) {
      return ['Error listing folders: $e'];
    }
  }

  // Web alternative for creating a folder (stores metadata in SharedPreferences)
  static Future<String> _createFolderWeb(String folderName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> folders = prefs.getStringList('folders') ?? [];

    if (!folders.contains(folderName)) {
      folders.add(folderName);
      await prefs.setStringList('folders', folders);
      return 'Folder created: $folderName (Web)';
    }
    return 'Folder already exists: $folderName (Web)';
  }

  // Web alternative for listing folders
  static Future<List<String>> _listFoldersWeb() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('folders') ?? [];
  }
}
