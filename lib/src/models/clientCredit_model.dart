
class DataClient {
  //--Informacion basica
  String lat;
  String lng;
  String name;
  String address;

  //-- Informacion adicional
  String zone;
  // Para pagos
  int idPayment;
  int idCredit;
  bool payment;
  String cobro;
  int status;
  // Para asignar una distancia en el mapa
  double distancia;

  DataClient(String lat, String lng, String name, String address,
      {String zone, double distancia, bool payment, String cobro, int status, int idPayment, int idCredit}) {
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
    this.idPayment = idPayment;
    this.idCredit = idCredit;
  }
}
