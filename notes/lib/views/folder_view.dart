import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FolderView {
  // Create a folder
  static Future<String> createFolder(String folderName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/$folderName';
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
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = directory.path;
      final folder = Directory(folderPath);

      if (await folder.exists()) {
        // Get all directories (folders) in the path
        final items = folder.listSync().whereType<Directory>();
        return items.map((dir) => dir.path.split('/').last).toList();
      } else {
        return [];
      }
    } catch (e) {
      return ['Error listing folders: $e'];
    }
  }
}
