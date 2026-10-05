sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message, this.statusCode);

  final int statusCode;
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class DecodingException extends ApiException {
  const DecodingException(super.message);
}
