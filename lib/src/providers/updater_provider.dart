import 'package:dio/dio.dart';
import 'package:paycapp/src/config.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';
//import 'package:paycapp/src/utils/local_storage.dart';

class UpdaterProvider {
  final _http = HttpClient().dio;
  //final _prefs = LocalStorage();

  Future<Responser> comprobate() async {
      Response res = await _http.post("/updates", data: {'build': buildVersion });
      return Responser.fromJson(res.data);
  }
}