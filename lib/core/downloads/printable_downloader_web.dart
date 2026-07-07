// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Triggers a browser download for a printable PDF (Flutter web).
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
  final blob = html.Blob(
    <Uint8List>[response.bodyBytes],
    'application/pdf',
  );
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: blobUrl)
    ..setAttribute('download', safeName)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(blobUrl);
  return safeName;
}

class PrintableDownloadException implements Exception {
  PrintableDownloadException(this.message);
  final String message;

  @override
  String toString() => message;
}
