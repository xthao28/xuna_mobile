import 'package:dio/dio.dart';
import 'package:xuna_mobile/core/data/data_source/network/dio_builder.dart';
import 'package:xuna_mobile/core/data/data_source/network/middleware/access_token_intercepter.dart';
import 'package:xuna_mobile/core/data/data_source/network/middleware/header_intercepter.dart';
import 'package:xuna_mobile/core/data/data_source/network/rest_api_client.dart';

class AuthAppServerApiClient extends RestApiClient {
  AuthAppServerApiClient(HeaderInterceptor headerInterceptor,
      AccessTokenInterceptor accessTokenInterceptor,
      {required String baseUrl})
      : super(
          dio: DioBuilder.createDio(
            options: BaseOptions(baseUrl: baseUrl),
            interceptors: [
              headerInterceptor,
              accessTokenInterceptor,
            ],
          ),
        );
}
