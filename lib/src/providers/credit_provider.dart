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

}