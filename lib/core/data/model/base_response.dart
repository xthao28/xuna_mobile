import 'package:xuna_mobile/shared/constants/const.dart';

class BaseResponse<T> {
  final String code;
  final String errorMessage;
  final T? result;

  BaseResponse({
    required this.code,
    required this.errorMessage,
    required this.result,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final result = json['result'];
    return BaseResponse<T>(
      code: json['code'] as String,
      errorMessage: json['errorMessage'] as String,
      result: (result is Map<String, dynamic> && fromJson != null)
          ? fromJson(result)
          : result as T?,
    );
  }

  bool get isSuccess => code == responseCodeSuccess;
}
