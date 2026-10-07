class FileSizeFormat {
  const FileSizeFormat._();

  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes o';
    }
    final kib = bytes / 1024;
    if (kib < 1024) {
      return '${kib.toStringAsFixed(1)} Ko';
    }
    return '${(kib / 1024).toStringAsFixed(1)} Mo';
  }
}
