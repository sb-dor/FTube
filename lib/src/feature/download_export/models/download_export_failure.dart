/// Why saving a file to the phone failed.
enum DownloadExportFailure { fileMissing, permissionDenied, failed }

final class DownloadExportException implements Exception {
  const DownloadExportException(this.failure, [this.cause]);

  final DownloadExportFailure failure;
  final Object? cause;

  @override
  String toString() => 'DownloadExportException($failure, $cause)';
}
