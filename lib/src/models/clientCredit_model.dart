class ClientCredit{

  String lat;
  String lng;
  String name;
  String address;
  String zone;
  double distancia;

  ClientCredit(String lat, String lng, String name, String address, String zone, {double distancia}){
    this.lat = lat;
    this.lng = lng;
    this.name = name;
    this.address = address;
    this.zone = zone;
    this.distancia = distancia;
  }

}