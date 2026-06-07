import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/enums.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class GeneratedReport {
  const GeneratedReport({
    required this.title,
    required this.csv,
    required this.pdfBytes,
    required this.rowCount,
  });

  final String title;
  final String csv;
  final List<int> pdfBytes;
  final int rowCount;
}

class ReportGeneratorService {
  ReportGeneratorService({
    required AnimalRepository animals,
    required ReportRepository reports,
  })  : _animals = animals,
        _reports = reports;

  final AnimalRepository _animals;
  final ReportRepository _reports;

  Future<ReportDefinition?> definition(String reportId) async {
    final list = await _reports.listReports();
    try {
      return list.firstWhere((r) => r.id == reportId);
    } catch (_) {
      return null;
    }
  }

  Future<GeneratedReport> generate(String reportId) async {
    final def = await definition(reportId);
    final title = def?.name ?? 'Report $reportId';
    switch (reportId) {
      case 'r1':
        return _birthsReport(title);
      case 'r2':
        return _cullReport(title);
      default:
        return _genericReport(title, def?.description ?? 'Farm report');
    }
  }

  Future<GeneratedReport> _birthsReport(String title) async {
    final all = await _animals.listAnimals();
    final rows = all.where((a) {
      return a.tags.contains(AnimalTagType.lactating) ||
          a.tags.contains(AnimalTagType.stillborn) ||
          a.tags.contains(AnimalTagType.miscarriage) ||
          a.tags.contains(AnimalTagType.pregnant);
    }).toList();

    final buffer = StringBuffer('tag,name,species,breed,status_tags\n');
    for (final a in rows) {
      buffer.writeln(
        '${_csv(a.tag)},${_csv(a.name)},${a.species.name},${_csv(a.breed)},${_csv(a.tags.map((t) => t.name).join(';'))}',
      );
    }

    final pdf = await _pdfDocument(
      title: title,
      subtitle: 'Breeding & calving related animals',
      lines: rows
          .map(
            (a) =>
                '#${a.tag} ${a.name.isEmpty ? '' : '· ${a.name}'} — ${a.tags.map((t) => t.name).join(', ')}',
          )
          .toList(),
    );

    return GeneratedReport(
      title: title,
      csv: buffer.toString(),
      pdfBytes: pdf,
      rowCount: rows.length,
    );
  }

  Future<GeneratedReport> _cullReport(String title) async {
    final all = await _animals.listAnimals();
    final rows = all
        .where(
          (a) =>
              a.tags.contains(AnimalTagType.cull) ||
              a.status == AnimalStatus.sold,
        )
        .toList();

    final buffer = StringBuffer('tag,name,breed,status,weight_kg\n');
    for (final a in rows) {
      buffer.writeln(
        '${_csv(a.tag)},${_csv(a.name)},${_csv(a.breed)},${a.status.name},${a.weightKg}',
      );
    }

    final pdf = await _pdfDocument(
      title: title,
      subtitle: 'Cull-flagged and sold animals',
      lines: rows
          .map(
            (a) =>
                '#${a.tag} ${a.name} · ${a.breed} · ${a.status.name}${a.cullFlagged ? ' · CULL' : ''}',
          )
          .toList(),
    );

    return GeneratedReport(
      title: title,
      csv: buffer.toString(),
      pdfBytes: pdf,
      rowCount: rows.length,
    );
  }

  Future<GeneratedReport> _genericReport(String title, String description) async {
    final all = await _animals.listAnimals();
    final buffer = StringBuffer('tag,name,species,group_id\n');
    for (final a in all) {
      buffer.writeln(
        '${_csv(a.tag)},${_csv(a.name)},${a.species.name},${_csv(a.groupId)}',
      );
    }
    final pdf = await _pdfDocument(
      title: title,
      subtitle: description,
      lines: all.map((a) => '#${a.tag} · ${a.name} · ${a.species.name}').toList(),
    );
    return GeneratedReport(
      title: title,
      csv: buffer.toString(),
      pdfBytes: pdf,
      rowCount: all.length,
    );
  }

  Future<List<int>> _pdfDocument({
    required String title,
    required String subtitle,
    required List<String> lines,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: const pw.TextStyle(fontSize: 22)),
          ),
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated ${DateTime.now().toIso8601String().split('T').first}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          if (lines.isEmpty)
            pw.Text('No records in this report.')
          else
            ...lines.map((line) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Text(line, style: const pw.TextStyle(fontSize: 11)),
                )),
        ],
      ),
    );
    return doc.save();
  }

  String _csv(String value) {
    if (value.contains(',') || value.contains('"')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
