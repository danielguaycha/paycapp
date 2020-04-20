class CreditNews{
  List<CreditNew> items = new List();
  CreditNews();
  CreditNews.fromJsonList(List<dynamic> jsonList){
    if( jsonList == null ) return;

    for(var item in jsonList){ //? TODO: Para que se usa esto
      final creditNew = new CreditNew.fromJsonMap(item);
    }
  }
}

class CreditNew {
  String monto;
  String utilidad;
  String plazo;
  String cobro;
  int status;
  String geoLat;
  String geoLon;
  String personId;
  int userId;
  String rutaId;
  String address;
  String refImg;
  String refDetail;
  String fInicio;
  String fFin;
  int totalUtilidad;
  int total;
  int pagosDe;
  int pagosDeLast;
  String description;
  int nPagos;
  int id;

  CreditNew({
    this.monto,
    this.utilidad,
    this.plazo,
    this.cobro,
    this.status,
    this.geoLat,
    this.geoLon,
    this.personId,
    this.userId,
    this.rutaId,
    this.address,
    this.refImg,
    this.refDetail,
    this.fInicio,
    this.fFin,
    this.totalUtilidad,
    this.total,
    this.pagosDe,
    this.pagosDeLast,
    this.description,
    this.nPagos,
    this.id,
  });

CreditNew.fromJsonMap(Map<String, dynamic> json) {
  monto         = json['monto'];
  utilidad      = json['utilidad'];
  plazo         = json['plazo'];
  cobro         = json['cobro'];
  status        = json['status'];
  geoLat        = json['geo_lat'];
  geoLon        = json['geo_lon'];
  personId      = json['person_id'];
  userId        = json['user_id'];
  rutaId        = json['ruta_id'];
  address       = json['address'];
  refImg        = json['ref_img'];
  refDetail     = json['ref_detail'];
  fInicio       = json['f_inicio'];
  fFin          = json['f_fin'];
  totalUtilidad = json['total_utilidad'];
  total         = json['total'];
  pagosDe       = json['pagos_de'];
  pagosDeLast   = json['pagos_de_last'];
  description   = json['description'];
  nPagos        = json['n_pagos'];
  id            = json['id'];
  }
}