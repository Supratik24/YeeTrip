import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Persists user-selected images (trip covers, avatars, receipts) into
/// the app's durable documents directory so temporary camera/picker cache
/// eviction never breaks stored file paths.
class LocalImageStore {
  LocalImageStore._();

  static const _uuid = Uuid();

  /// Copies [sourcePath] into `<appDocs>/yeetrip_media/<folder>/` and returns
  /// the durable destination path. Falls back to [sourcePath] if copying fails
  /// or if running in an environment without `path_provider`.
  static Future<String> persistImage(
    String sourcePath, {
    required String folder,
  }) async {
    if (kIsWeb || sourcePath.trim().isEmpty) return sourcePath;

    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return sourcePath;

      final docsDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(p.join(docsDir.path, 'yeetrip_media', folder));
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      // Already persisted inside yeetrip_media
      if (p.isWithin(docsDir.path, sourcePath)) {
        return sourcePath;
      }

      final ext = p.extension(sourcePath).isNotEmpty
          ? p.extension(sourcePath)
          : '.jpg';
      final targetPath = p.join(mediaDir.path, '${_uuid.v4()}$ext');
      await sourceFile.copy(targetPath);
      return targetPath;
    } catch (_) {
      return sourcePath;
    }
  }
}
