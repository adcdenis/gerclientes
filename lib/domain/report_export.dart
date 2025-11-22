import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as ex;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class ClientReportRow {
  final String nome;
  final String email;
  final String telefone;
  final DateTime vencimento;
  final String servidor;
  final String plano;
  final String valor;
  const ClientReportRow({
    required this.nome,
    required this.email,
    required this.telefone,
    required this.vencimento,
    required this.servidor,
    required this.plano,
    required this.valor,
  });
}

Future<File> _createTempFile(String basename) async {
  final dir = await getTemporaryDirectory();
  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filename = '$basename-$ts';
  return File(p.join(dir.path, filename));
}

 

Future<File> generateXlsxClientsReport(List<ClientReportRow> rows) async {
  final excel = ex.Excel.createExcel();
  final sheetName = 'Clientes';
  final sheet = excel[sheetName];
  excel.setDefaultSheet(sheetName);
  try { excel.delete('Sheet1'); } catch (_) {}
  sheet.appendRow([
    'Nome',
    'Email',
    'Telefone',
    'Vencimento',
    'Servidor',
    'Plano',
    'Valor',
  ]);
  final df = DateFormat('dd/MM/yyyy');
  for (final r in rows) {
    sheet.appendRow([
      r.nome,
      r.email,
      r.telefone,
      df.format(r.vencimento),
      r.servidor,
      r.plano,
      r.valor,
    ]);
  }
  final bytes = excel.encode()!;
  final f = await _createTempFile('relatorio_clientes');
  final xlsx = File('${f.path}.xlsx');
  await xlsx.writeAsBytes(bytes, flush: true);
  return xlsx;
}

Future<File> generatePdfClientsReport(List<ClientReportRow> rows) async {
  final doc = pw.Document();
  final df = DateFormat('dd/MM/yyyy');
  final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
  const cellStyle = pw.TextStyle(fontSize: 9);
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Row(children: [
            pw.Text('Relatório de Clientes', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.SizedBox(height: 8),
          pw.Text('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(width: 0.3, color: PdfColors.grey),
            tableWidth: pw.TableWidth.max,
            columnWidths: {
              0: const pw.FixedColumnWidth(90),
              1: const pw.FixedColumnWidth(110),
              2: const pw.FixedColumnWidth(70),
              3: const pw.FixedColumnWidth(70),
              4: const pw.FixedColumnWidth(80),
              5: const pw.FixedColumnWidth(80),
              6: const pw.FixedColumnWidth(60),
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Nome', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Email', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Telefone', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Vencimento', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Servidor', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Plano', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Valor', style: headerStyle)),
              ]),
              ...rows.map((r) => pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.nome, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.email, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.telefone, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(df.format(r.vencimento), style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.servidor, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.plano, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.valor, style: cellStyle)),
              ]))
            ],
          ),
        ];
      },
    ),
  );
  final bytes = await doc.save();
  final f = await _createTempFile('relatorio_clientes');
  final pdfFile = File('${f.path}.pdf');
  await pdfFile.writeAsBytes(bytes, flush: true);
  return pdfFile;
}

Future<void> shareFile(File file, {required String mimeType}) async {
  final xfile = XFile(file.path, mimeType: mimeType);
  await Share.shareXFiles([xfile]);
}