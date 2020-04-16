import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClientCredit {
  String lat;
  String lng;
  String name;
  String address;
  String zone;

  bool payment;
  double distancia;
  String cobro;
  int status;
  BitmapDescriptor bitmapDescriptor;

  ClientCredit(String lat, String lng, String name, String address, String zone,
      {double distancia, bool payment, String cobro, int status, BitmapDescriptor bitmapDescriptor}) {
    this.lat = lat;
    this.lng = lng;
    this.name = name;
    this.address = address;
    this.zone = zone;
    this.distancia = distancia;
    this.payment = payment;
    this.distancia = distancia;
    this.cobro = cobro;
    this.status = status;
    this.bitmapDescriptor = bitmapDescriptor;
  }
}
