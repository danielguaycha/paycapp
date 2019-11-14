import 'package:dio/dio.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';

class RouteProvider {
  final _http = HttpClient().dio;

  Future<dynamic> getRoutes() async {
 
      Response res = await _http.get('/route');
      return Responser.fromJson(res.data);    
  }
}