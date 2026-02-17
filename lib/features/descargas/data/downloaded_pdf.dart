import 'dart:io';

/// Lightweight model representing a locally downloaded PDF file.
class DownloadedPdf {
  final File file;
  final String name;
  final DateTime modified;

  const DownloadedPdf({
    required this.file,
    required this.name,
    required this.modified,
  });
}
