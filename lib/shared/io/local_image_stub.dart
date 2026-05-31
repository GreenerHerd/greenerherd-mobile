import 'package:flutter/material.dart';

bool localFileExists(String path) => false;

Widget buildLocalFileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return const SizedBox.shrink();
}
