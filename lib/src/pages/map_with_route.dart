import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'map_googleService.dart';

//// DATOS PREVIOS /////
LatLng _origin;
LatLng _destination;
String _waypoints = "";
String _rutaPuntos = "";
bool _waypointsObtenidos = false;
Map<double, LatLng> distanceAndCoordinates;
List<double> distancias = [];
Set<Polyline> _polyLines = {};
Set<Polyline> get polyLines => _polyLines;
GoogleMapsServices _googleMapsServices = GoogleMapsServices();
bool _validate = true;
int _bucle = 0;

/// FIN DATOS PREVIOS ////

class MapRoutePage extends StatefulWidget {
  final List<ClientCredit> cliente;

  MapRoutePage({Key key, @required this.cliente}) : super(key: key);

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  final Set<Marker> _markers = Set();
  Set<Polyline> _polyline = {};
  Set<Polyline> get polyLines => _polyline;

  CameraPosition _initialPosition;
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    getCoordinates(widget.cliente);

    return Scaffold(
        appBar: AppBar(
          title: Text('Visualizar rutas'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.directions_car), onPressed: (){
              print("Origen: $_origin");
              print("WAY: $_waypoints");
              print("Destino: $_destination");
              sendRequest(_origin, _destination, _waypoints);
              setState(() {
                
              });
            },)
          ],
        ),        
        body: FutureBuilder<Position>(
            future: _getLoc(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Cargando mapa...')
                    ],
                  ),
                );
              } else {
                _origin =
                    LatLng(snapshot.data.latitude, snapshot.data.longitude);
                _initialPosition = CameraPosition(
                    target: LatLng(_origin.latitude, _origin.longitude),
                    zoom: 15.5);

                _markers.add(Marker(
                    draggable: true,
                    markerId: MarkerId('$_origin'),                    
                    position: LatLng(_origin.latitude, _origin.longitude),
                    infoWindow: InfoWindow(title: 'Tu ubicacion' )));

                for (int i = 0; i < widget.cliente.length; i++) {
                  _markers.add(
                    Marker(
                        draggable: true,
                        markerId: MarkerId('${widget.cliente[i].toString()}'),
                        position: LatLng(
                            double.parse(widget.cliente[i].lat.toString()),
                            double.parse(widget.cliente[i].lng.toString())),
                        infoWindow: InfoWindow(
                            title: '${widget.cliente[i].name}',
                            snippet:
                                '${widget.cliente[i].address} - ${widget.cliente[i].zone}')),
                  );
                }
                return _map();
              }
            }));
  }

  _map() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialPosition,
          rotateGesturesEnabled: false,
          markers: Set<Marker>.of(_markers),
          polylines: _polyLines,
        ),
      ],
    );
  }

  Future<Position> _getLoc() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

// obtener la ultima posicion de la lista
  Future<bool> getCoordinates(List<ClientCredit> values) async{
    //Si la lista es mayor a cero ejecuto el metodo
    if (values.length > 0) {
      //Obtener el ultimo valor de la lista
      _destination = new LatLng(double.parse(values[values.length - 1].lat),
          double.parse(values[values.length - 1].lng));
      //Eliminar el ultimo valor de la lista
      values.removeAt(values.length - 1);
      //Si quedan elementos en la lista, obtengo los puntos del camino de la ruta
      if (values.length > 0) {
        _waypointsObtenidos = false;
         await getWaypoints(values);
      } else {
        _waypointsObtenidos = true;
      }
    }
    return true;
  }

  //Obtener los puntos medios para la consulta con el API de google
  Future<bool> getWaypoints(List<ClientCredit> valuesClient) async {
    _waypoints = "";
    for (int i = 0; i < valuesClient.length; i++) {
      _waypoints =
          _waypoints + "${valuesClient[i].lat},${valuesClient[i].lng}|";
    }
    _waypointsObtenidos = true;
    print("WP: $_waypoints");
    return true;
  }

  Future addDistancias(List<ClientCredit> valuesClient) async {
    double distanceInMeters;
    for (int x = 1; x < valuesClient.length; x++) {
      distanceInMeters = await Geolocator().distanceBetween(
          _origin.latitude,
          _origin.longitude,
          double.parse(valuesClient[x].lat),
          double.parse(valuesClient[x].lng));
      valuesClient[x].distancia = distanceInMeters;
    }
    return valuesClient;
  }

  List<ClientCredit> ordenarPorDistancia(List<ClientCredit> c) {
    int size = c.length;
    for (int i = 0; i < size - 1; i++) {
      for (int j = 0; j < size - 1; j++) {
        if (c[j].distancia < c[j + 1].distancia) {
          ClientCredit tmp = c[j + 1];
          c[1 + j] = c[j];
          c[j] = tmp;
        }
      }
    }
    return c;
  }

  /////////////////////// INICIO TALLARIN //////////////////////////
  // ! SEND REQUEST
  void sendRequest(LatLng origen, LatLng destino, String puntos) async {
    print("Graficando... $_origin ");
    String route = await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
    createRoute(route);
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.clear();
    print("Pintar linea azul");
    _polyLines.add(Polyline(
        polylineId: PolylineId(_origin.toString()),
        width: 8,
        geodesic: true,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.blue));
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  // !DECODE POLY
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    //repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    /*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    //print(lList.toString() + "\n");
    return lList;
  }
  ///////////////////////  FIN TALLARIN  //////////////////////////

}
