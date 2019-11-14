// To parse this JSON data, do
//
//     final credit = creditFromJson(jsonString);

import 'dart:convert';

import 'dart:io';

Credit creditFromJson(String str) => Credit.fromJson(json.decode(str));

String creditToJson(Credit data) => json.encode(data.toJson());


class Credit {
  int id;
  double monto;
  int utilidad;
  String plazo;
  String cobro;
  int status;
  double geoLat;
  double geoLon;
  int personId;
  int rutaId;
  String address;
  File refImg;
  String refDetail;
  DateTime fInicio;
  DateTime fFin;
  double totalUtilidad;
  double total;
  double pagosDe;
  String description;
  String prendaDetail;
  File prendaImg;

  int npagos;

  Credit({
    this.id = 0,
    this.monto = 0,
    this.utilidad,
    this.plazo,
    this.cobro,
    this.status,
    this.geoLat,
    this.geoLon,
    this.personId,
    this.rutaId,
    this.address,
    this.refImg,
    this.refDetail,
    this.fInicio,
    this.fFin,
    this.totalUtilidad = 0,
    this.total = 0,
    this.pagosDe = 0,
    this.description,
    this.npagos = 0,
    this.prendaDetail,
    this.prendaImg,
  });

  factory Credit.fromJson(Map<String, dynamic> json) => Credit(
    monto: json["monto"],
    utilidad: json["utilidad"],
    plazo: json["plazo"],
    cobro: json["cobro"],
    status: json["status"],
    geoLat: json["geo_lat"],
    geoLon: json["geo_lon"],
    personId: json["person_id"],
    fInicio: DateTime.parse(json["f_inicio"]),
    fFin: DateTime.parse(json["f_fin"]),
    totalUtilidad: json["total_utilidad"].toDouble(),
    total: json["total"].toDouble(),
    pagosDe: json["pagos_de"].toDouble(),
    description: json["description"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "monto": monto,
    "utilidad": utilidad,
    "plazo": plazo,
    "cobro": cobro,
    "status": status,
    "geo_lat": geoLat,
    "geo_lon": geoLon,
    "person_id": personId,
    "ruta_id": rutaId,
    "address": address,
    "ref_detail": refDetail,
    "total_utilidad": totalUtilidad,
    "total": total,
    "pagos_de": pagosDe,
    "description": description,
    "prenda_detail": prendaDetail,
    "id": id,
  };


  diasPlazo() {
    if(plazo == null) return 0;
    switch (plazo) {
      case 'SEMANAL':
        return 7;
      case 'QUINCENAL':
        return 15;
      case 'MENSUAL':
        return 30;
      case 'MES_Y_MEDIO':
        return 45;
      case 'DOS_MESES':
        return 60;
    }
  }

  diasCobro() {
    if(cobro == null ) return 0;
    switch (cobro) {
      case 'DIARIO':
        return 1;
      case 'SEMANAL':
        return 7;
      case 'QUINCENAL' :
        return 15;
      case 'MENSUAL':
        return 30;
    }
  }

  calcular() {
    if(monto <= 0 )
      return;

    totalUtilidad = monto * (utilidad/100);
    total = monto + totalUtilidad;

    if(plazo == null || cobro == null )
      return;

    npagos = (diasPlazo() / diasCobro()).toInt();
    pagosDe = (total / npagos);

  }
}
