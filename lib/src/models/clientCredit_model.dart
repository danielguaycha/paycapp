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
  String ref_detail;
  String ref_img;
  String totalPago;
  int numeroPago;
  String description;
  int client_id;
  String date;

  // Para asignar una distancia en el mapa
  double distancia;

  DataClient(String lat, String lng, String name, String address,
      {String zone,
      double distancia,
      bool payment,
      String cobro,
      int status,
      int idPayment,
      int idCredit,
      String ref_detail,
      String ref_img,
      String totalPago,
      int numeroPago,
      String description,
      int client_id,
      String date}) {
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
    this.ref_detail = ref_detail;
    this.ref_img = ref_img;
    this.totalPago = totalPago;
    this.numeroPago = numeroPago;
    this.description = description;
    this.client_id = client_id;
    this.date = date;
  }
}
