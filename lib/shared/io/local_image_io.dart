import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

String normalizeLocalImagePath(String path) {
  final trimmed = path.trim();
  if (trimmed.startsWith('file://')) {
    return Uri.parse(trimmed).toFilePath();
  }
  return trimmed;
}

bool localFileExists(String path) {
  final normalized = normalizeLocalImagePath(path);
  if (normalized.isEmpty) return false;
  return File(normalized).existsSync();
}

/// Copies a picked image into app documents so it survives cache cleanup.
Future<String?> persistPickedImage(String sourcePath) async {
  final normalized = normalizeLocalImagePath(sourcePath);
  if (normalized.isEmpty) return null;

  final source = File(normalized);
  if (!await source.exists()) return null;

  final dir = await getApplicationDocumentsDirectory();
  final photosDir = Directory(p.join(dir.path, 'animal_photos'));
  if (!await photosDir.exists()) {
    await photosDir.create(recursive: true);
  }

  final ext = p.extension(normalized);
  final destPath = p.join(
    photosDir.path,
    '${DateTime.now().millisecondsSinceEpoch}${ext.isEmpty ? '.jpg' : ext}',
  );
  await source.copy(destPath);
  return destPath;
}

bool productImageResolvable(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final normalized = normalizeLocalImagePath(path);
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return true;
  }
  if (normalized.startsWith('assets/')) return true;
  return localFileExists(normalized);
}

/// User-uploaded inventory photo takes precedence over catalogue image URL.
String? resolveProductImagePath({
  String? userPhotoPath,
  String? catalogImageUrl,
}) {
  final user = userPhotoPath?.trim();
  if (user != null && user.isNotEmpty && productImageResolvable(user)) {
    return user;
  }
  final catalog = catalogImageUrl?.trim();
  if (catalog != null && catalog.isNotEmpty && productImageResolvable(catalog)) {
    return catalog;
  }
  return null;
}

Widget buildProductImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  final normalized = normalizeLocalImagePath(path.trim());
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return Image.network(
      normalized,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
  if (normalized.startsWith('assets/')) {
    return Image.asset(
      normalized,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
  return buildLocalFileImage(
    path: normalized,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

Widget buildLocalFileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(normalizeLocalImagePath(path)),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
