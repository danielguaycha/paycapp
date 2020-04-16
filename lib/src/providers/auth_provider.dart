import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/models/user_model.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/plugins/http.dart';
import 'package:paycapp/src/utils/utils.dart' show processError;

class AuthProvider {
  final prefs = LocalStorage();
  final _http = HttpClient().dio;
  Future<Responser> login(String email, String password) async {
    final authData = {
      'username': email,
      'password': password,
    };
    try {
      Response response = await _http.post('/login',  data: authData);
      prefs.token = response.data['access_token'].toString();
      return Responser.fromJson({'data': response.data});
    } on DioError catch (e) {
      return Responser.fromJson(processError(e));
    }
  }

  Future<Responser> getAuth() async {
    Response response = await _http.get('/user');

    if(response.data != null && response.data['data'] != null){
      final u = User.fromJson(response.data['data']);
      prefs.user = u;
    }

    return Responser.fromJson(response.data);
  }


  Future<Auth> getCompleteAuth() async {
      Response response = await _http.get('/user', options: buildCacheOptions(Duration(days: 1)));
      return Auth.fromJson(json.encode(response.data['data']));
  }

  Future<Responser> changePassword(String oldPass, String newPass) async {
    final authData = {
      'password': newPass,
      'password_now': oldPass,
    };

    try {
      Response response = await _http.post('/user/password', data: authData);
      return Responser.fromJson({'data': response.data});
    } on DioError catch (e) {
      return Responser.fromJson(processError(e));
    }
  }


}