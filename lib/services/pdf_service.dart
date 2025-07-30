import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/todo.dart';


class PdfService {
  static Future<void> generateMonthlyReport(List<Todo> allTodos, DateTime month) async {
    final pdf = pw.Document();

    //Filter dan Proses Data
    final monthlyTasks = allTodos.where((task) {
      return task.createdAt.year == month.year && task.createdAt.month == month.month;
    }).toList();
    
    monthlyTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final totalTasks = monthlyTasks.length;
    final completedTasks = monthlyTasks.where((task) => task.isCompleted).length;
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
    
    // Memuat font kustom dan gambar logo
    final font = await _loadNunitoRegularFont();
    final fontBold = await _loadNunitoBoldFont();
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    // Bangun Halaman PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => _buildHeader(context, month, fontBold, logoImage),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildSummary(totalTasks, completedTasks, completionRate, font, fontBold),
          pw.SizedBox(height: 20),
          _buildTaskList(monthlyTasks, font, fontBold),
        ],
      ),
    );

    // Simpan dan Buka File
    await _saveAndLaunchFile(pdf, 'Laporan_Moodo_${DateFormat('MMMM_yyyy').format(month)}.pdf');
  }

  static pw.Widget _buildHeader(pw.Context context, DateTime month, pw.Font fontBold, pw.ImageProvider logo) {
    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Laporan Produktivitas Bulanan',
                style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.indigo),
              ),
              pw.Text(
                DateFormat('MMMM yyyy').format(month),
                style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(
            height: 50,
            width: 50,
            child: pw.Image(logo),
          ),
        ]
      )
    );
  }
  
  static pw.Widget _buildFooter(pw.Context context, pw.Font font) {
     return pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 10.0),
        child: pw.Text(
          'Halaman ${context.pageNumber} dari ${context.pagesCount}',
          style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey),
        ),
      );
  }

  static pw.Widget _buildSummary(int total, int completed, double rate, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("Total Tugas", '$total', font, fontBold),
          _summaryItem("Selesai", '$completed', font, fontBold),
          _summaryItem("Tingkat Penyelesaian", '${rate.toStringAsFixed(1)}%', font, fontBold),
        ],
      ),
    );
  }
  
  static pw.Widget _summaryItem(String title, String value, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 18, color: PdfColors.indigo)),
      ]
    );
  }

  static pw.Widget _buildTaskList(List<Todo> tasks, pw.Font font, pw.Font fontBold) {
    final headers = ['Tanggal', 'Tugas', 'Kategori', 'Status'];
    
    final data = tasks.map((task) {
      return [
        DateFormat('dd/MM/yy').format(task.createdAt),
        task.title,
        task.category ?? '-',
        task.isCompleted ? 'Selesai' : 'Belum',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
      },
      cellStyle: pw.TextStyle(font: font),
    );
  }
  
  static Future<pw.Font> _loadNunitoRegularFont() async {
    final fontData = await rootBundle.load("assets/fonts/Nunito-Regular.ttf");
    return pw.Font.ttf(fontData);
  }
  
  static Future<pw.Font> _loadNunitoBoldFont() async {
    final fontData = await rootBundle.load("assets/fonts/Nunito-Bold.ttf");
    return pw.Font.ttf(fontData);
  }

  static Future<void> _saveAndLaunchFile(pw.Document pdf, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }
}