import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'map_googleService.dart';

//// DATOS PREVIOS /////
LatLng _origin = new LatLng(-3.272077, -79.942040);
LatLng _destination = new LatLng(-3.259853, -79.961172);
String _waypoints =
    "-3.270454,-79.944385|-3.268788,-79.947184|-3.263662,-79.952993|-3.257820,-79.956172|-3.260767,-79.959707";
List<double> distancias = [];
Set<Polyline> _polyLines = {};
Set<Polyline> get polyLines => _polyLines;
GoogleMapsServices _googleMapsServices = GoogleMapsServices();

/// FIN DATOS PREVIOS ////

class MapRoutePage extends StatefulWidget {
  MapRoutePage({Key key}) : super(key: key);

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

class _MapRoutePageState extends State<MapRoutePage> {
  final Set<Marker> _markers = Set();
  Set<Polyline> _polyline = {};
  Set<Polyline> get polyLines => _polyline;

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(-3.272077, -79.942040), zoom: 30.0);
  Completer<GoogleMapController> _controller = Completer();

  LatLng _lastPosition = LatLng(-3.270454, -79.944385);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sendRequest(_origin, _destination, _waypoints);
    List<LatLng> coordenadas = [
      new LatLng(-3.260767, -79.959707),
      new LatLng(-3.259853, -79.961172),
      new LatLng(-3.272077, -79.942040),
      new LatLng(-3.270454, -79.944385),
      new LatLng(-3.268788, -79.947184),
      new LatLng(-3.263662, -79.952993),
      new LatLng(-3.257820, -79.956172)
    ];

    List<String> titulos = ["Inicio", "A", "B", "C", "D", "E", "Fin"];
    double totalDistance = 0;
    for (var i = 0; i < coordenadas.length - 1; i++) {
      totalDistance = calculateDistance(
          coordenadas[0].latitude,
          coordenadas[0].longitude,
          coordenadas[i + 1].latitude,
          coordenadas[i + 1].longitude);
      print("Distancia: $totalDistance");
      distancias.add(totalDistance);
    }
    print("Total D: ${distancias.length}");
    print("Total coor: ${coordenadas.length}");

    return Scaffold(
        appBar: AppBar(
          title: Text('Visualizar rutas'),
          centerTitle: true,
        ),
        body: FutureBuilder<Position>(
            future: _getLoc(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
//                print("Puntos condicion: ${_polyLines.toString()}");
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
                _initialPosition = CameraPosition(
                    target:
                        LatLng(snapshot.data.latitude, snapshot.data.longitude),
                    zoom: 15.5);

                for (int i = 0; i < coordenadas.length; i++) {
                  _markers.add(
                    Marker(
                        draggable: true,
                        markerId: MarkerId('$i'),
                        position: coordenadas[i],
                        infoWindow: InfoWindow(
                            title: '${titulos[i]}',
                            snippet: 'Casa de Daniel Guaycha')),
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
          onTap: (v) {
            setState(() {
              print("Coordenadas: ${v.longitude} - ${v.latitude}");
              _markers.clear();
              _markers.add(
                Marker(
                    draggable: true,
                    markerId: MarkerId('$v'),
                    position: new LatLng(v.latitude, v.longitude),
                    infoWindow: InfoWindow(
                      title: 'Ubicacion Cliente',
                    )),
              );
            });
          },
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

  void cocktail_sort(List<LatLng> puntos){
// PROCEDIMIENTO bubble_sort ( vector a[1:n])
  int iteracion = 0;
    bool permut = false;
  // iteración ← 0
  do {
    permut = false;
// REPETIR
//     permut ← FALSO
    for (var i = 0; i < puntos.length - 1 ; i++) {
//     PARA i VARIANDO DE 1 HASTA n - 1 - iteración HACER
      if (puntos[i].latitude > puntos[i+1].latitude) {
//         SI a[i] > a[i+1] ENTONCES
//             intercambiar a[i] Y a[i+1]
        permut = true;
//             permut ← VERDADERO
//         FIN SI
//     FIN PARA        
      }
      
    }
//     iteración ← iteración + 1
    
  } while (permut);
// MIENTRAS QUE permut = VERDADERO



  }





  //Obtener los puntos para la consulta con el API de google
  void getWaypoints(List<LatLng> coordinates) {
    for (int i = 1; i < coordinates.length - 1; i++) {
      _waypoints = "${coordinates[i]}|";
    }
  }

  //obtener las distancias
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /////////////////////// INICIO TALLARIN //////////////////////////
  // ! SEND REQUEST
  void sendRequest(LatLng origen, LatLng destino, String puntos) async {
    String route =
        await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
    createRoute(route);
    //notifyListeners();
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
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
