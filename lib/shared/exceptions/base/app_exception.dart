abstract class AppException implements Exception {
  const AppException(this.appExceptionType);

  final AppExceptionType appExceptionType;

  String? get errorMessage => null;
}

enum AppExceptionType {
  remote,
  remoteConfig,
  custom,
  uncaught,
}
