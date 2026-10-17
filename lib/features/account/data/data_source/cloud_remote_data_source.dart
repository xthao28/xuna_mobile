import 'package:dio/dio.dart';
import 'package:xuna_mobile/core/data/data_source/network/dio_builder.dart';

/// XUNA backend over HTTPS (HTTP only in debug builds for a local backend).
abstract interface class CloudRemoteDataSource {
  bool get configured;

  /// `GET /v1/me` → `{"userId": "<uuid>"}`.
  Future<Map<String, dynamic>> getMe(String idToken);
}

class CloudRemoteDataSourceImpl implements CloudRemoteDataSource {
  CloudRemoteDataSourceImpl({required String baseUrl, Dio? dio})
      : _baseUrl = baseUrl,
        _dio = dio ??
            DioBuilder.createDio(
              options: BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  final String _baseUrl;
  final Dio _dio;

  @override
  bool get configured => _baseUrl.isNotEmpty;

  @override
  Future<Map<String, dynamic>> getMe(String idToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/me',
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );
    final data = response.data;
    if (data == null) throw const FormatException('Empty /v1/me response');
    return data;
  }
}
