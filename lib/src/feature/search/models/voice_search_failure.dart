/// Why a voice search could not produce a query.
enum VoiceSearchFailure {
  /// Microphone or speech-recognition permission was denied.
  permissionDenied,

  /// The device has no usable speech recognizer.
  unavailable,

  /// Recognition started but failed (network, audio, busy recognizer...).
  failed,
}

/// Thrown by the voice search repository when recognition fails.
final class VoiceSearchException implements Exception {
  const VoiceSearchException(this.failure, [this.message]);

  final VoiceSearchFailure failure;
  final String? message;

  @override
  String toString() =>
      'VoiceSearchException(${failure.name}${message == null ? '' : ': $message'})';
}
