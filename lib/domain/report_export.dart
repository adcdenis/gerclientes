import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as ex;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportRow {
  final String nome;
  final String descricao;
  final DateTime dataHora;
  final String categoria;
  final String tempoFormatado; // "7 dias, 7 horas, 52 minutos, 52 segundos" ou "–"
  final String preco; // "R$ 0,00" ou "-"
  final String distancia; // "10,0 km" ou "-"
  final String tempoConclusao; // "HH:mm:ss" ou "-"
  final String pace; // "mm:ss min/km" ou "-"
  const ReportRow({
    required this.nome,
    required this.descricao,
    required this.dataHora,
    required this.categoria,
    required this.tempoFormatado,
    required this.preco,
    required this.distancia,
    required this.tempoConclusao,
    required this.pace,
  });
}

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

Future<File> generateXlsxReport(List<ReportRow> rows) async {
  final excel = ex.Excel.createExcel();
  final sheetName = 'Relatorio';
  final sheet = excel[sheetName];
  // Define a planilha padrão e remove a planilha vazia inicial, se existir
  excel.setDefaultSheet(sheetName);
  try { excel.delete('Sheet1'); } catch (_) {}
  // Cabeçalho como texto simples (compatível com versões anteriores)
  sheet.appendRow([
    'Nome da corrida',
    'Descrição',
    'Data (DD/MM/AAAA)',
    'Hora (HH:MM)',
    'Tempo decorrido ou restante',
    'Categoria',
    'Preço',
    'Distância',
    'Tempo de conclusão',
    'Pace',
  ]);

  final df = DateFormat('dd/MM/yyyy');
  final tf = DateFormat('HH:mm');
  for (final r in rows) {
    sheet.appendRow([
      r.nome,
      r.descricao,
      df.format(r.dataHora),
      tf.format(r.dataHora),
      r.tempoFormatado,
      r.categoria,
      r.preco,
      r.distancia,
      r.tempoConclusao,
      r.pace,
    ]);
  }

  final bytes = excel.encode()!;
  final f = await _createTempFile('relatorio');
  final xlsx = File('${f.path}.xlsx');
  await xlsx.writeAsBytes(bytes, flush: true);
  return xlsx;
}

Future<File> generatePdfReport(List<ReportRow> rows) async {
  final doc = pw.Document();
  final df = DateFormat('dd/MM/yyyy');
  final tf = DateFormat('HH:mm');
  final headerStyle = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
  final cellStyle = const pw.TextStyle(fontSize: 9);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Row(children: [
            pw.Text('Relatório de Corridas', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ]),
          pw.SizedBox(height: 8),
          pw.Text('Gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(width: 0.3, color: PdfColors.grey),
            tableWidth: pw.TableWidth.max,
            columnWidths: {
              // Larguras ajustadas para evitar quebra dentro das palavras
              0: const pw.FixedColumnWidth(70),  // nome
              1: const pw.FixedColumnWidth(95),  // descrição
              2: const pw.FixedColumnWidth(80),  // data
              3: const pw.FixedColumnWidth(50),  // hora
              4: const pw.FixedColumnWidth(110), // tempo
              5: const pw.FixedColumnWidth(65),  // categoria
              6: const pw.FixedColumnWidth(60),  // preço
              7: const pw.FixedColumnWidth(60),  // distância
              8: const pw.FixedColumnWidth(70),  // tempo de conclusão
              9: const pw.FixedColumnWidth(60),  // pace
            },
            children: [
              pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Nome da corrida', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Descrição', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Data (DD/MM/AAAA)', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Hora (HH:MM)', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Tempo decorrido ou restante', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Categoria', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Preço', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Distância', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Tempo de conclusão', style: headerStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Pace', style: headerStyle)),
              ]),
              ...rows.map((r) => pw.TableRow(children: [
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.nome, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.descricao, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(df.format(r.dataHora), style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(tf.format(r.dataHora), style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.tempoFormatado, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.categoria, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.preco, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.distancia, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.tempoConclusao, style: cellStyle)),
                pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(r.pace, style: cellStyle)),
              ]))
            ],
          ),
        ];
      },
    ),
  );

  final bytes = await doc.save();
  final f = await _createTempFile('relatorio');
  final pdfFile = File('${f.path}.pdf');
  await pdfFile.writeAsBytes(bytes, flush: true);
  return pdfFile;
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