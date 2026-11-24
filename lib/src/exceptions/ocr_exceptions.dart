class OcrException implements Exception {
  final String code;
  final String message;
  final dynamic details;
  final bool isRecoverable;

  const OcrException({
    required this.code,
    required this.message,
    this.details,
    this.isRecoverable = false,
  });

  @override
  String toString() => 'OcrException[$code]: $message';
}

class EngineNotInitializedException extends OcrException {
  const EngineNotInitializedException([String message = 'OCR Engine has not been initialized.'])
      : super(code: 'ENGINE_NOT_INITIALIZED', message: message, isRecoverable: true);
}

class EngineDisposedException extends OcrException {
  const EngineDisposedException([String message = 'OCR Engine has already been disposed.'])
      : super(code: 'ENGINE_DISPOSED', message: message);
}

class InvalidImageException extends OcrException {
  const InvalidImageException(String message, [dynamic details])
      : super(code: 'INVALID_IMAGE', message: message, details: details);
}

class ModelNotFoundException extends OcrException {
  const ModelNotFoundException(String message, [dynamic details])
      : super(code: 'MODEL_NOT_FOUND', message: message, details: details);
}

class InferenceException extends OcrException {
  const InferenceException(String message, [dynamic details])
      : super(code: 'INFERENCE_ERROR', message: message, details: details, isRecoverable: true);
}

class UnsupportedPlatformException extends OcrException {
  const UnsupportedPlatformException(String message)
      : super(code: 'UNSUPPORTED_PLATFORM', message: message);
}

class ProcessingCancelledException extends OcrException {
  const ProcessingCancelledException([String message = 'OCR operation was cancelled.'])
      : super(code: 'PROCESSING_CANCELLED', message: message);
}
