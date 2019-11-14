
import 'package:dio/dio.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';

class ClientProvider {

  final _http = HttpClient().dio;

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

}