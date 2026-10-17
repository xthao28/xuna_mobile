import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:xuna_mobile/core/data/data_source/network/dio_builder.dart';
import 'package:xuna_mobile/features/account/data/codec/sse_codec.dart';
import 'package:xuna_mobile/features/account/data/model/sse_event_model.dart';

/// XUNA backend over HTTPS (HTTP only in debug builds for a local backend).
///
/// Every call carries the Firebase ID token. Mutations take the caller's
/// `Idempotency-Key`. Failures are [DioException]s (problem+json in
/// `response.data`), [TimeoutException] or [FormatException]; the
/// repository translates them.
abstract interface class CloudRemoteDataSource {
  bool get configured;

  /// `GET /v1/me` → `{"userId": "<uuid>"}`.
  Future<Map<String, dynamic>> getMe(String idToken);

  Future<Map<String, dynamic>> postChallenge(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> postPet(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  });

  Future<Map<String, dynamic>> getPets(String idToken);

  Future<Map<String, dynamic>> getConsents(String idToken);

  Future<Map<String, dynamic>> putConsents(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  });

  /// `POST /v1/conversations/{petId}/turns` as Server-Sent Events.
  Stream<SseEventModel> postTurn(
    String idToken, {
    required String petId,
    required Map<String, dynamic> body,
  });
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

  /// Longest silence between two events of a reply; the backend's own
  /// provider timeout is 30 s.
  static const _turnGapTimeout = Duration(seconds: 35);

  final String _baseUrl;
  final Dio _dio;

  @override
  bool get configured => _baseUrl.isNotEmpty;

  @override
  Future<Map<String, dynamic>> getMe(String idToken) =>
      _json('GET', '/v1/me', idToken);

  @override
  Future<Map<String, dynamic>> postChallenge(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) =>
      _json('POST', '/v1/devices/challenges', idToken,
          body: body, idempotencyKey: idempotencyKey);

  @override
  Future<Map<String, dynamic>> postPet(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) =>
      _json('POST', '/v1/pets', idToken,
          body: body, idempotencyKey: idempotencyKey);

  @override
  Future<Map<String, dynamic>> getPets(String idToken) =>
      _json('GET', '/v1/pets', idToken);

  @override
  Future<Map<String, dynamic>> getConsents(String idToken) =>
      _json('GET', '/v1/consents', idToken);

  @override
  Future<Map<String, dynamic>> putConsents(
    String idToken, {
    required String idempotencyKey,
    required Map<String, dynamic> body,
  }) =>
      _json('PUT', '/v1/consents', idToken,
          body: body, idempotencyKey: idempotencyKey);

  @override
  Stream<SseEventModel> postTurn(
    String idToken, {
    required String petId,
    required Map<String, dynamic> body,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/v1/conversations/$petId/turns',
      data: body,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
        validateStatus: (_) => true,
      ),
    );
    final stream = response.data?.stream;
    if (stream == null) throw const FormatException('Empty turn response');
    final status = response.statusCode ?? 0;
    if (status != 200) {
      // Problem details arrive as a byte stream here; decode them so the
      // repository sees the same `code` as for JSON calls.
      final text = await utf8.decodeStream(stream);
      Object? problem;
      try {
        problem = jsonDecode(text);
      } on FormatException {
        problem = null;
      }
      throw DioException.badResponse(
        statusCode: status,
        requestOptions: response.requestOptions,
        response: Response(
          requestOptions: response.requestOptions,
          statusCode: status,
          data: problem,
        ),
      );
    }
    yield* SseCodec.decode(stream).timeout(_turnGapTimeout);
  }

  Future<Map<String, dynamic>> _json(
    String method,
    String path,
    String idToken, {
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) async {
    final response = await _dio.request<Map<String, dynamic>>(
      path,
      data: body,
      options: Options(
        method: method,
        headers: {
          'Authorization': 'Bearer $idToken',
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        },
      ),
    );
    final data = response.data;
    if (data == null) throw FormatException('Empty $path response');
    return data;
  }
}
