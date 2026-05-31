import 'package:flutter/material.dart';

import '../../data/services/report_generator_service.dart';

Future<void> shareReportCsv(BuildContext context, GeneratedReport report) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export is not available on web')),
  );
}

Future<void> shareReportPdf(BuildContext context, GeneratedReport report) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Export is not available on web')),
  );
}
