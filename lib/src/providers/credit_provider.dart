import 'package:dio/dio.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/plugins/http.dart';
import 'package:paycapp/src/utils/utils.dart' show processError;

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

  Future<Responser> cancel(int id) async {
    try {
      Response res = await _http.put('/credit/cancel', data: {"id": id});
      return Responser.fromJson(res.data);
    } catch (e) {
      return Responser.fromJson(processError(e));
    }
  }

  Future<dynamic> list({int page: 1, int ruta}) async {
    Response res = await _http.get("/credit?page=$page" + (ruta != null? "&ruta=$ruta" : ""));
    return Responser.fromJson(res.data);
  }

  //Listar el historial de pagos
  Future<dynamic> listPayments(id) async {
    Response res = await _http.get("/payment/$id");
    return Responser.fromJson(res.data);
  }
  //Supuestamente esto borra el credito
  Future<dynamic> deletePayments(id) async {
    Response res = await _http.delete("/payment/$id");
    return Responser.fromJson(res.data);
  }
  //Actualizar a mora
  Future<Responser> updateToMora(int id) async {
    try {
      Response res = await _http.put('/payment', data: {"status": id});
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
}