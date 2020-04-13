import 'package:dio/dio.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';
import 'package:paycapp/src/utils/utils.dart' show processError;
//Other
import 'package:paycapp/src/models/credit_new_model.dart';
import 'dart:convert';

class CreditProvider {
  final _http = HttpClient().dio;

  Future<Responser> store(Credit c) async {
    FormData formData = FormData.fromMap({
      "monto": c.monto,
      "plazo": c.plazo,
      "utilidad": c.utilidad,
      "cobro": c.cobro,
      "person_id": c.personId,
      "geo_lat": c.geoLat,
      "geo_lon": c.geoLon,
      "ruta_id": c.rutaId,
      "address": c.address,
      "ref_detail": c.refDetail,
      "ref_img" : c.refImg == null ? null : await MultipartFile.fromFile(c.refImg.path),
      "prenda_detail": c.prendaDetail,
      "prenda_img": c.prendaImg == null ? null : await MultipartFile.fromFile(c.prendaImg.path)
    });
    try {
      Response res = await _http.post('/credit', data: formData);
      return Responser.fromJson(res.data);
    } catch(e) {
      return Responser.fromJson(processError(e));
    }
  }

  Future<Responser> cancel(int id, String razon ) async {
    try {
      Response res = await _http.put('/credit/cancel/$id', data: {"description" : razon });
      return Responser.fromJson(res.data);
    } catch (e) {
      return Responser.fromJson(processError(e));
    }
  }

  Future<Responser> end(int id) async {
    try {
      Response res = await _http.put('/credit/end/$id');
      return Responser.fromJson(res.data);
    } catch (e) {
      return Responser.fromJson(processError(e));
    }
  }

  Future<dynamic> list({int page: 1, String ruta: "null", String plazo: "null", String cobros: "null", String search = "null"}) async {
    if(search == "null"){

    String url = "/credit?page=$page";
    
    url = (ruta !="null") ? url + "&ruta=$ruta" : url;
    url = (plazo !="null") ? url + "&plazo=$plazo" : url;
    url = (cobros !="null") ? url + "&cobro=$cobros" : url;

    Response res = await _http.get(url);
    return Responser.fromJson(res.data);
    }else{
    
      String url = "/credit/search?q=$search";
      Response res = await _http.get(url);
      return Responser.fromJson(res.data);
    }

  }

  //Listar el historial de pagos
  Future<dynamic> listPayments(id) async {
    Response res = await _http.get("/payment/$id");
    return Responser.fromJson(res.data);
  }
  
  //Listar pagos por dia
  Future<dynamic> listPaymentsForDay(String date) async {
    print("Listando pagos...");
    String url = "/payment?&date="+date;
    Response res = await _http.get(url);
    return Responser.fromJson(res.data);
  }

  //Supuestamente esto anula el pago
  Future<dynamic> deletePayments(id, description) async {
    try {
    Response res = await _http.delete("/payment/$id", data: {"description": description});
    return Responser.fromJson(res.data);
    } catch (e) {
      return Responser.fromJson(processError(e));
    }
  }


  //Actualizar a mora
  Future<Responser> updatePayment(int id, int status) async {
    // status = -1 -> mora
    // status = 2 -> pagado    
    try {
      Response res = await _http.put('/payment/$id', data: {"status": status});
      return Responser.fromJson(res.data);
    } catch (e) {
      return Responser.fromJson(processError(e));
    }
  }


  // Obtener un crédito por el id
  Future<dynamic> getById(int id) async {
    Response res = await _http.get('/credit/$id');
    return Responser.fromJson(res.data);
  }

  //Nuevo provider 31/03/2020
  Future<List<CreditNew>> getlist({int page: 1, String ruta: "null", String plazo: "null", String cobros: "null"}) async {

    String url = "/credit?page=$page";
    
    url = (ruta !="null") ? url + "&ruta=$ruta" : url;
    url = (plazo !="null") ? url + "&plazo=$plazo" : url;
    url = (cobros !="null") ? url + "&cobro=$cobros" : url;

    final resp = await _http.get(url);
    final decodedData = json.decode(resp.data.toString());

    Response res = await _http.get(url);
    //return Responser.fromJson(res.data);



    // final creditNews = CreditNews.fromJsonList(decodedData);
    // print("DATA: $creditNews");
    print("JSON");
     print(res);

    return [];
    }
}