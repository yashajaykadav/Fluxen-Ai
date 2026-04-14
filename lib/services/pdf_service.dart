import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  Future<String> extractText(File file) async {
    try {
      final PdfDocument document = PdfDocument(
        inputBytes: await file.readAsBytes(),
      );

      // Extract text from all pages
      String text = PdfTextExtractor(document).extractText();

      document.dispose();
      return text.trim().isEmpty ? "No readable text found in PDF." : text;
    } catch (e) {
      return "Error extracting text: $e";
    }
  }

  List<String> splitIntoChunks(String text, {int chunkSize = 1000}) {
    if (text.isEmpty) return [];
    List<String> chunks = [];
    for (var i = 0; i < text.length; i += chunkSize) {
      int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }
}