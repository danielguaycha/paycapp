import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';

class RouteProvider {
  final _http = HttpClient().dio;

  Future<dynamic> getRoutes() async { 
      Response res = await _http.get('/route', options: buildCacheOptions(Duration(hours: 8)));
      return Responser.fromJson(res.data);          
  }
}