import 'dart:io';

import 'package:http/http.dart' as http;

/// Saves a printable PDF to the system temp directory (mobile/desktop).
Future<String> downloadPrintablePdf({
  required String url,
  required String filename,
  required Map<String, String> headers,
}) async {
  final response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode != 200) {
    throw PrintableDownloadException(
      'Download failed (${response.statusCode}). Please try again.',
    );
  }

  final safeName = filename.endsWith('.pdf') ? filename : '$filename.pdf';
  final file = File('${Directory.systemTemp.path}/$safeName');
  await file.writeAsBytes(response.bodyBytes);
  return file.path;
}

class PrintableDownloadException implements Exception {
  PrintableDownloadException(this.message);
  final String message;

  @override
  String toString() => message;
}
