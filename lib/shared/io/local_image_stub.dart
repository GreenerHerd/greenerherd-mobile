import 'package:flutter/material.dart';

String normalizeLocalImagePath(String path) => path.trim();

bool localFileExists(String path) => false;

Future<String?> persistPickedImage(String sourcePath) async => sourcePath;

bool productImageResolvable(String? path) {
  if (path == null || path.trim().isEmpty) return false;
  final normalized = normalizeLocalImagePath(path);
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return true;
  }
  if (normalized.startsWith('assets/')) return true;
  return false;
}

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
  return const SizedBox.shrink();
}

Widget buildLocalFileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return const SizedBox.shrink();
}
