class PaymentModel{

  String lat;
  String lon;
  String name;
  String address;
  String cobro;
  int status;
  

  PaymentModel(String lat, String lon, String name, String address, String cobro, int status){
    this.lat = lat;
    this.lon = lon;
    this.name = name;
    this.address = address;
    this.cobro = cobro;
    this.status = status;
  }
}