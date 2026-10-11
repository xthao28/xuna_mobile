class ServerError {
  final String? code;
  final String? errorMessage;

  const ServerError({
    this.code,
    this.errorMessage,
  });

  factory ServerError.fromJson(Map<String, dynamic> json) {
    return ServerError(
      code: json['code'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  String toString() {
    return 'ServerError{code: $code, errorMessage: $errorMessage}';
  }
}
