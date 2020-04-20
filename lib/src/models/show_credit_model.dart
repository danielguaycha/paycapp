// To parse this JSON data, do
//
//     final showCredit = showCreditFromJson(jsonString);

import 'dart:convert';
import 'package:paycapp/src/models/prenda_model.dart';
import 'package:paycapp/src/utils/utils.dart' show parseDouble, parseInt;

class ShowCredit {
    int id;
    double utilidad;
    String plazo;
    String cobro;
    int status;
    String description;
    String address;
    String refImg;
    String refDetail;
    String monto;
    double totalUtilidad;
    double total;
    double pagosDe;
    double pagosDeLast;
    int nPagos;
    String geoLat;
    String geoLon;
    int rutaId;
    int personId;
    int userId;
    DateTime fInicio;
    DateTime fFin;
    DateTime createdAt;
    String ruta;
    String clientName;
    String clientSurname;
    String clientAddress;
    List<Prenda> prenda;

    ShowCredit({
        this.id,
        this.utilidad,
        this.plazo,
        this.cobro,
        this.status,
        this.description,
        this.address,
        this.refImg,
        this.refDetail,
        this.monto,
        this.totalUtilidad,
        this.total,
        this.pagosDe,
        this.pagosDeLast,
        this.nPagos,
        this.geoLat,
        this.geoLon,
        this.rutaId,
        this.personId,
        this.userId,
        this.fInicio,
        this.fFin,
        this.createdAt,
        this.ruta,
        this.clientName,
        this.clientSurname,
        this.clientAddress,
        this.prenda,
    });

    factory ShowCredit.fromJson(String str) => ShowCredit.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory ShowCredit.fromMap(Map<String, dynamic> json) => ShowCredit(
        id: json["id"],
        utilidad: parseDouble(json["utilidad"]),
        plazo: json["plazo"],
        cobro: json["cobro"],
        status: json["status"],
        description: json["description"],
        address: json["address"],
        refImg: json["ref_img"],
        refDetail: json["ref_detail"],
        monto: json["monto"],
        totalUtilidad: parseDouble("${json["total_utilidad"]}"),
        total: parseDouble("${json["total"]}"),
        pagosDe: parseDouble(json["pagos_de"]),
        pagosDeLast: parseDouble(json["pagos_de_last"]),
        nPagos: parseInt(json["n_pagos"]),
        geoLat: json["geo_lat"],
        geoLon: json["geo_lon"],
        rutaId: json["ruta_id"],
        personId: json["person_id"],
        userId: json["user_id"],
        fInicio: DateTime.parse(json["f_inicio"]),
        fFin: DateTime.parse(json["f_fin"]),
        createdAt: DateTime.parse(json["created_at"]),
        ruta: json["ruta"],
        clientName: json["client_name"],
        clientSurname: json["client_surname"],
        clientAddress: json["client_address"],
        prenda: List<Prenda>.from(json["prenda"].map((x) => Prenda.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "utilidad": utilidad,
        "plazo": plazo,
        "cobro": cobro,
        "status": status,
        "description": description,
        "address": address,
        "ref_img": refImg,
        "ref_detail": refDetail,
        "monto": monto,
        "total_utilidad": totalUtilidad,
        "total": total,
        "pagos_de": pagosDe,
        "pagos_de_last": pagosDeLast,
        "n_pagos": nPagos,
        "geo_lat": geoLat,
        "geo_lon": geoLon,
        "ruta_id": rutaId,
        "person_id": personId,
        "user_id": userId,
        "f_inicio": "${fInicio.year.toString().padLeft(4, '0')}-${fInicio.month.toString().padLeft(2, '0')}-${fInicio.day.toString().padLeft(2, '0')}",
        "f_fin": "${fFin.year.toString().padLeft(4, '0')}-${fFin.month.toString().padLeft(2, '0')}-${fFin.day.toString().padLeft(2, '0')}",
        "created_at": createdAt.toIso8601String(),
        "ruta": ruta,
        "client_name": clientName,
        "client_surname": clientSurname,
        "client_address": clientAddress,
        "prenda": List<dynamic>.from(prenda.map((x) => x.toMap())),
    };

    String getStatus() {
      if(this.status == null) return "";

      switch(this.status) {
        case 0: return "ANULADO";
        case 1: return "ACTIVO";
        case 2: return "FINALIZADO";                
      }

      return "";
    }
}


