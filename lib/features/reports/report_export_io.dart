import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/services/report_generator_service.dart';

Future<void> shareReportCsv(BuildContext context, GeneratedReport report) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${report.title.replaceAll(' ', '_')}.csv');
  await file.writeAsString(report.csv);
  await Share.shareXFiles([XFile(file.path)], subject: report.title);
}

Future<void> shareReportPdf(BuildContext context, GeneratedReport report) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${report.title.replaceAll(' ', '_')}.pdf');
  await file.writeAsBytes(report.pdfBytes);
  await Share.shareXFiles([XFile(file.path)], subject: report.title);
}
