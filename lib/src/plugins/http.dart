import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:paycapp/main.dart';
import 'package:paycapp/src/config.dart' show urlApi;
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/utils/navigator.service.dart';

class HttpClient {

  Dio dio;
  DioCacheManager _cacheManager;
  final NavigationService _navigationService = locator<NavigationService>();


  HttpClient() {
    _cacheManager = DioCacheManager(CacheConfig(baseUrl: urlApi, databaseName: 'paycenter.db'));
    dio = new Dio(new BaseOptions(
        baseUrl: urlApi,
        connectTimeout: 120000,
        receiveTimeout: 120000,
        headers: {
          "Accept": 'application/json'
        },
        responseType: ResponseType.json
    ));
    final prefs = LocalStorage();
    dio.interceptors.add(InterceptorsWrapper(
        onRequest:(RequestOptions options) async {
          if( prefs.token != null ) {
            options.headers["Authorization"] = "Bearer ${prefs.token}";
          }
          return options; //continue
        },
        onResponse:(Response response) async {
          return response; // continue
        },
        onError: (DioError e) async {
          if (e.response!=null && e.response.statusCode == 401 && prefs.token != null) {
              prefs.token = null;
              _navigationService.navigateTo('login');
          }
          return e;//continue
        }
    ));
    dio.interceptors.add(_cacheManager.interceptor);
  }

  clearCachePrimary(path) {
    _cacheManager.deleteByPrimaryKey(urlApi+path);
  }

  clearAllCache() {
    if (_cacheManager != null)
      _cacheManager.clearAll();
  }

  clearExpired() {
    _cacheManager.clearExpired();
  }
}