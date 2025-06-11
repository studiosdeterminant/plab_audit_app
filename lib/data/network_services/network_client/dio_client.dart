import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surveyapp/helpers/strings.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';

//const _defaultConnectTimeout = Duration.millisecondsPerMinute;
const _defaultConnectTimeout = Duration(
    days: 0, hours: 0, minutes: 0, seconds: 0, milliseconds: 60 * 1000);
//const _defaultReceiveTimeout = Duration.millisecondsPerMinute;
const _defaultReceiveTimeout = Duration(
    days: 0, hours: 0, minutes: 0, seconds: 0, milliseconds: 60 * 1000);

class DioClient {
  static final Future<Dio> _dio = _getDioClient();
  static final String baseUrl = BASE_URL;

  static Future<Dio> get dio => _dio;

  static Future<Dio> _getDioClient() async {
    Dio dio = Dio();
    dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = _defaultConnectTimeout
      ..options.receiveTimeout = _defaultReceiveTimeout
      ..httpClientAdapter
      ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

    dio.interceptors.addAll(await getInterceptors());

    return dio;
  }

  static Future<List<Interceptor>> getInterceptors() async {
    List<Interceptor> interceptors = [];
    interceptors.add(CookieManager(PersistCookieJar(
        storage: FileStorage((await getTemporaryDirectory()).path))));
    interceptors.add(
      InterceptorsWrapper(
        onError: (error, errorInterceptorHandler) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          if (error.response?.statusCode == 403 ||
              error.response?.statusCode == 401) {
            String refreshToken = prefs.getString(REFRESH_TOKEN) ?? "";

            try {
              var dio = await _dio;
              await dio.post("/auth/refreshToken",
                  data: {"refreshToken": refreshToken});

              var response = await dio.request(error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                      method: error.response!.requestOptions.method,
                      headers: error.response!.requestOptions.headers));
              errorInterceptorHandler.resolve(response);
            } catch (e) {
              prefs.clear();
              SystemNavigator.pop();
            }
          } else {
            errorInterceptorHandler.reject(error);
          }
        },
      ),
    );
    interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
            hitCacheOnErrorExcept: [401, 403],
            policy: CachePolicy.refresh,
            store: FileCacheStore(
                (await getApplicationDocumentsDirectory()).path)),
      ),
    );

    return interceptors;
  }
}
