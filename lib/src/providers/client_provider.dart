
import 'package:dio/dio.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';

class ClientProvider {

  final _http = HttpClient().dio;

  //list client
  
  Future<dynamic> listOrSearch({bool search = false, String textToSearch = "null" }) async {
    
    String url = "/client/";
    
    if(search && textToSearch != "null"){
      url = url + "/search?q=" + textToSearch;
      Response res = await _http.get(url);
      return Responser.fromJson(res.data);
    }else{
      Response res = await _http.get(url);
      return Responser.fromJson(res.data);
    }
  }


  // store client 
  Future<Responser> store(Person client) async {
    try {
      Response response = await _http.post('/client', data: client.toJson());
      print(response.data.toString());
      return Responser.fromJson(response.data);      
    }  on DioError catch(e) {
        print(e.message);             
        if(e.response != null) {
          return Responser.fromJson(e.response.data);                    
        } else{
          return new Responser(ok: false, message: 'Upps, parece que el servidor no ha respondido');
        }
    }  
  }

  Future<Responser> search(String data) async {    
      Response res = await _http.get("/client/search?q=$data");
      return Responser.fromJson(res.data);       
  }

  Future<Responser> list({int page: 1, limit: 10}) async {
    Response res = await _http.get("/client?page=$page&limit=$limit}");
    return Responser.fromJson(res.data);
  }

}