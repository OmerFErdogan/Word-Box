import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:my_words/models/word.dart';

class PDFService {
  static Future<void> createAndSharePDF(
      String category, List<Word> words) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text(category)),
              pw.SizedBox(height: 20),
              ...words
                  .map((word) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('${word.english} - ${word.turkish.first}',
                              style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Example: ${word.example}',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 10),
                        ],
                      ))
                  .toList(),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$category.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareFiles([file.path], text: '$category words');
  }
}
