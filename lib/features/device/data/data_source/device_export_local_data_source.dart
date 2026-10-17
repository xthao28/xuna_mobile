import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Writes export files under the app documents directory (`exports/`).
abstract interface class DeviceExportLocalDataSource {
  /// Returns the written file path.
  Future<String> write(String fileName, String content);
}

class DeviceExportLocalDataSourceImpl implements DeviceExportLocalDataSource {
  static const _timeout = Duration(seconds: 10);

  @override
  Future<String> write(String fileName, String content) async {
    final documents =
        await getApplicationDocumentsDirectory().timeout(_timeout);
    final directory = Directory('${documents.path}/exports');
    await directory.create(recursive: true).timeout(_timeout);
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content, flush: true).timeout(_timeout);
    return file.path;
  }
}
