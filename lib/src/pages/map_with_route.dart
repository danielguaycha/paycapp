import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';

class MapRoutePage extends StatefulWidget {
  final List<ClientCredit> cliente;

  MapRoutePage({Key key, @required this.cliente}) : super(key: key);

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

bool loadData = true;
List<ClientCredit> f = new List<ClientCredit>();
//Datos del cliente
String name = "";
String addres = "";

class _MapRoutePageState extends State<MapRoutePage> {
  @override
  void initState() {
    // TODO: implement initState
     if (loadData) {
      f = widget.cliente;
      loadData = false;
    }
    print("TEXTO");
   super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loadData) {
      f = widget.cliente;
      loadData = false;
    }

    widget.cliente.clear();
    return Scaffold(
      appBar: AppBar(
          title: Text('Visualizar rutas'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.directions_car),
              onPressed: () {
                // print("Origen: $_origin");
                // print("WAY: $_waypoints");
                // print("Destino: $_destination");
                // sendRequest(_origin, _destination, _waypoints);
                _retry();
              },
            )
          ]),
      body: FutureBuilder<Position>(
        future: _getPosition(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Si no tiene datos, mostrar un loading
          if (!snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Cargando mapa...')
              ],
            );
          }

          return _map(snapshot.data, widget.cliente, context);
        },
      ),
    );
  }

  // Retorna un Future con  la posicion actual del dispositivo
  Future<Position> _getPosition() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  LatLng _currentCoridinates;
  CameraPosition _initialCameraPosition;
  double _zoomForMap = 15.0;
  Set<Marker> _markers = Set();
  double _position = -100;

  Widget _map(data, List<ClientCredit> listaClientes, context) {
    LatLng _locationClient;

    _currentCoridinates = LatLng(data.latitude, data.longitude);
    
    _initialCameraPosition = CameraPosition(
        target:
            LatLng(_currentCoridinates.latitude, _currentCoridinates.longitude),
        zoom: _zoomForMap);
    
    _markers.add(new Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      position: _currentCoridinates,
      markerId: MarkerId('$_currentCoridinates'),
      infoWindow: InfoWindow(title: "Tu ubicación"),
    ));
    
    print("${listaClientes.length}");
    
    for (var item in listaClientes) {
      print("HOLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      _locationClient = LatLng(double.parse(item.lat), double.parse(item.lng));
      _markers.add(new Marker(
        onTap: () {
          // Cuando se hace clic en un pin se cargan los datos que la tarjeta va a tener
          _position = double.minPositive;
          name = item.name;
          addres = item.address;
          _retry();
        },
        icon: _getBitmapDescriptor(item.status),
        draggable: false,
        position: LatLng(_locationClient.latitude, _locationClient.longitude),
        markerId: MarkerId('$_locationClient'),
        // infoWindow: InfoWindow(title: "${item.name}", snippet: "${item.address}"),
      ));
    }
    // esta solucion temporal es para recargar la vista porque da problemas
    if (loadData) {
      _retry();
    }
    return Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (v) {
            //Con esta opcion oculto la tarjeta cuando se aplaste fuera del pin
            _position = -100;
            _retry();
          },
          compassEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          rotateGesturesEnabled: true,
          markers: Set<Marker>.of(_markers),
          // polylines: _polyLines,
        ),
        _tarjetaFlotante(),
      ],
    );
  }

  void _retry() {
    setState(() {});
  }

  // Este metodo retorna el color del pin dependiendo su estatus
  BitmapDescriptor _getBitmapDescriptor(int status) {
    print("STATUS: $status");
    switch (status) {
      case 1:
        return BitmapDescriptor.defaultMarkerWithHue(55.0);
        break;
      case 2:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        break;
      case -1:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        break;
      default:
        return BitmapDescriptor.defaultMarkerWithHue(55.0);
        break;
    }
  }

  // Este widget se posiciona por la parte superior y al cambiar sus dimensiones desaparece con una animacion
  // Los valores que carga son name y addres declarados al inicio y cambian sus botones en base al pin seleccionado
  Widget _tarjetaFlotante(){
    return AnimatedPositioned(
            top: _position,
            right: 0,
            left: 0,
            duration: Duration(milliseconds: 200),
            child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                    margin: EdgeInsets.all(20),
                    height: 70,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 20,
                              offset: Offset.zero,
                              color: Colors.grey.withOpacity(0.5))
                        ]),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(left: 10),
                              width: 50,
                              height: 50,
                              child: ClipOval(
                                child: Icon(Icons.person_pin),
                              )),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(addres,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ]))));
      
  }

  // _verNombre(context, String name){
  // showAlertDialog(BuildContext context, String name) {
  //   // set up the button
  //   Widget okButton = FlatButton(
  //     child: Text("OK"),
  //     onPressed: () {},
  //   );
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("$name"),
  //     content: Text("Aqui pondre la direccion"),
  //     actions: [
  //       okButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  // void _callModalBotonsheet(context, {String name}) {
  //   showModalBottomSheet(
  //       // shape: StadiumBorder(),
  //       // elevation: 0.0,
  //       // barrierColor: Colors.black12,
  //       // enableDrag: false,
  //       // isDismissible: true,
  //       // isScrollControlled: false,
  //       // useRootNavigator: false,
  //       // clipBehavior: Clip.antiAlias,
  //       // backgroundColor: Colors.transparent,
  //       context: context,
  //       builder: (context) {
  //         return Container(
  //           child: Text(name.toUpperCase()),
  //         );
  //       });
  // }
}
// showDialog(context){
//   AlertDialog f = AlertDialog(
//   title: Text("name"),
// );
// return f;
// }

// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:paycapp/src/models/clientCredit_model.dart';
// import 'map_googleService.dart';

// //// DATOS PREVIOS /////
// LatLng _origin;
// LatLng _destination;
// String _waypoints = "";
// String _rutaPuntos = "";
// bool _waypointsObtenidos = false;
// Map<double, LatLng> distanceAndCoordinates;
// List<double> distancias = [];
// Set<Polyline> _polyLines = {};
// Set<Polyline> get polyLines => _polyLines;
// GoogleMapsServices _googleMapsServices = GoogleMapsServices();
// bool _validate = true;
// int _bucle = 0;
// BitmapDescriptor _bitmapDescriptor;

// /// FIN DATOS PREVIOS ////
// List<RegistrosBit> _listNX = [];
// var _nuevaLista;
// class RegistrosBit {
//   String cobro;
//   int status;
//   BitmapDescriptor bit;
//   RegistrosBit(String cobro, int status, BitmapDescriptor bit) {
//     this.cobro = cobro;

//     this.status = status;

//     this.bit = bit;
//   }
// }

// class MapRoutePage extends StatefulWidget {
//   final List<ClientCredit> cliente;

//   MapRoutePage({Key key, @required this.cliente}) : super(key: key);

//   @override
//   _MapRoutePageState createState() => _MapRoutePageState();
// }

// class _MapRoutePageState extends State<MapRoutePage> {
//   final Set<Marker> _markers = Set();
//   Set<Polyline> _polyline = {};
//   Set<Polyline> get polyLines => _polyline;
//   List<ClientCredit> clienteForMap;

//   CameraPosition _initialPosition;
//   Completer<GoogleMapController> _controller = Completer();

//   void _onMapCreated(GoogleMapController controller) {
//     _controller.complete(controller);
//   }

//   @override
//   void initState() {
//     clienteForMap = widget.cliente;
//     widget.cliente.clear();

//     getCoordinates(clienteForMap);

//     _getBitmapDescriptor(clienteForMap);

//     //lista de bit
//     _nuevaLista = [
//       [
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/diario/cobrado.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/diario/mora.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/diario/pendiente.png'),

//       ],
//       [
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/mensual/cobrado.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/mensual/mora.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/mensual/pendiente.png'),

//       ],
//       [
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/quincenal/cobrado.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/quincenal/mora.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/quincenal/pendiente.png'),

//       ],
//       [
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/semanal/cobrado.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/semanal/mora.png'),
//         BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/semanal/pendiente.png'),
//       ],
//     ];

//     super.initState();
//     // _getBitmapDescriptor("diario", 1);
//   }

//   @override
//   void dispose() {
//     clienteForMap.clear();
//     // this.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Visualizar rutas'),
//           centerTitle: true,
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.directions_car),
//               onPressed: () {
//                 print("Origen: $_origin");
//                 print("WAY: $_waypoints");
//                 print("Destino: $_destination");
//                 sendRequest(_origin, _destination, _waypoints);
//                 setState(() {});
//               },
//             )
//           ],
//         ),
//         body: FutureBuilder<Position>(
//             future: _getLoc(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return Container(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     mainAxisSize: MainAxisSize.max,
//                     children: <Widget>[
//                       CircularProgressIndicator(),
//                       SizedBox(height: 10),
//                       Text('Cargando mapa...')
//                     ],
//                   ),
//                 );
//               }
//               else {
//               _origin = LatLng(snapshot.data.latitude, snapshot.data.longitude);
//               _initialPosition = CameraPosition(
//                   target: LatLng(_origin.latitude, _origin.longitude),
//                   zoom: 15.5);

//               _markers.add(Marker(

//                   draggable: true,
//                   markerId: MarkerId('$_origin'),
//                   position: LatLng(_origin.latitude, _origin.longitude),
//                   infoWindow: InfoWindow(
//                     title: 'Tu ubicacion')));

//               for (int i = 0; i < clienteForMap.length; i++) {
//                 // print("FOR : $i < ${clienteForMap.length}");

//                 // //_bitmapDescriptor = _getBitmapDescriptor(clienteForMap[i].cobro, clienteForMap[i].status);
//                 // print("Bit: ${clienteForMap[i].bitmapDescriptor.toString()}");
//                 // print("NAME: ${clienteForMap[i].lat.toString()}");
//                 // BitmapDescriptor.fromBytes()

//                 _markers.add(
//                   Marker(
//                       icon:  clienteForMap[i].payment
//                           ? _bitmapDescriptor(clienteForMap[i].cobro, clienteForMap[i].status)
//                           : BitmapDescriptor.defaultMarker,
//                       draggable: true,
//                       markerId: MarkerId('${clienteForMap[i].toString()}'),
//                       position: LatLng(
//                           double.parse(clienteForMap[i].lat.toString()),
//                           double.parse(clienteForMap[i].lng.toString())),
//                       infoWindow: InfoWindow(
//                           title: '${clienteForMap[i].name}',
//                           snippet: clienteForMap[i].payment
//                               ? '${clienteForMap[i].address}'
//                               : '${clienteForMap[i].address} - ${clienteForMap[i].zone}')),
//                 );
//               }
//               }
//               return _map();
//             }));
//   }

//   String _getStatus(int status) {
//     String st = 'pendiente';
//     switch (status) {
//       case 1:
//         st = 'pendiente';
//         break;

//       case 2:
//         st = 'cobrado';
//         break;

//       case -1:
//         st = 'mora';
//         break;

//       default:
//         st = 'pendiente';
//         break;
//     }
//     return st;
//   }

//   BitmapDescriptor _bitmapDescriptor(String x, int y){
//     print("BITMAT");
//     switch (x) {
//       case "diario":
//         switch (y) {
//           case 1:
//             return _nuevaLista[0][0];
//           break;
//           case 2:
//             return _nuevaLista[0][1];
//           break;
//           case -1:
//             return _nuevaLista[0][2];
//           break;
//           default:
//             return _nuevaLista[0][0];
//           break;
//         }
//         break;
//       case "semanal":
//         switch (y) {
//           case 1:
//             return _nuevaLista[1][0];
//           break;
//           case 2:
//             return _nuevaLista[1][1];
//           break;
//           case -1:
//             return _nuevaLista[1][2];
//           break;
//           default:
//             return _nuevaLista[1][0];
//           break;
//         }
//         break;
//       case "quincenal":
//         switch (y) {
//           case 1:
//             return _nuevaLista[2][0];
//           break;
//           case 2:
//             return _nuevaLista[2][1];
//           break;
//           case -1:
//             return _nuevaLista[2][2];
//           break;
//           default:
//             return _nuevaLista[2][0];
//           break;
//         }
//         break;
//       case "mensual":
//         switch (y) {
//           case 1:
//             return _nuevaLista[3][0];
//           break;
//           case 2:
//             return _nuevaLista[3][1];
//           break;
//           case -1:
//             return _nuevaLista[3][2];
//           break;
//           default:
//             return _nuevaLista[3][0];
//           break;
//         }
//         break;
//       default:
//         return _nuevaLista[0][0];
//       break;
//     }
//     // BitmapDescriptor f;
//     // for (var item in _listNX) {
//     //   if(x == item.cobro && y == item.status){
//     //     return item.bit;
//     //   }
//     // }
//     // return f;
//   }

//   _getBitmapDescriptor(List<ClientCredit> clienteForMap) async {
//     for (var item in clienteForMap) {
//       // print("URL: assets/img/pin/${item.cobro.toLowerCase()}/${_getStatus(item.status)}.png");
//       // print("FOR_BIT 1: ${item.bitmapDescriptor}");
//       _listNX.add(new RegistrosBit(
//           item.cobro,
//           item.status,
//           await BitmapDescriptor.fromAssetImage(
//               ImageConfiguration(devicePixelRatio: 2.5),
//               'assets/img/pin/${item.cobro.toLowerCase()}/${_getStatus(item.status)}.png')
//           // print("FOR_BIT 2: ${item.bitmapDescriptor}")
//           ));
//       //  await BitmapDescriptor.fromAssetImage(
//       //   ImageConfiguration(devicePixelRatio: 2.5),
//       //   'assets/img/pin/${item.cobro.toLowerCase()}/${_getStatus(item.status)}.png');
//       //   print("FOR_BIT 2: ${item.bitmapDescriptor}");
//     }
//   }

//   _map() {
//     return Stack(
//       children: <Widget>[
//         GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: _initialPosition,
//           rotateGesturesEnabled: true,
//           markers: Set<Marker>.of(_markers),
//           polylines: _polyLines,
//         ),
//       ],
//     );
//   }

//   Future<Position> _getLoc() async {
//     return await Geolocator()
//         .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//   }

// // obtener la ultima posicion de la lista
//   Future<bool> getCoordinates(List<ClientCredit> values) async {
//     //Si la lista es mayor a cero ejecuto el metodo
//     if (values.length > 0) {
//       //Obtener el ultimo valor de la lista
//       _destination = new LatLng(double.parse(values[values.length - 1].lat),
//           double.parse(values[values.length - 1].lng));
//       //Eliminar el ultimo valor de la lista
//       values.removeAt(values.length - 1);
//       //Si quedan elementos en la lista, obtengo los puntos del camino de la ruta
//       if (values.length > 0) {
//         _waypointsObtenidos = false;
//         await getWaypoints(values);
//       } else {
//         _waypointsObtenidos = true;
//       }
//     }
//     return true;
//   }

//   //Obtener los puntos medios para la consulta con el API de google
//   Future<bool> getWaypoints(List<ClientCredit> valuesClient) async {
//     _waypoints = "";
//     for (int i = 0; i < valuesClient.length; i++) {
//       _waypoints =
//           _waypoints + "${valuesClient[i].lat},${valuesClient[i].lng}|";
//     }
//     _waypointsObtenidos = true;
//     print("WP: $_waypoints");
//     return true;
//   }

//   Future addDistancias(List<ClientCredit> valuesClient) async {
//     double distanceInMeters;
//     for (int x = 1; x < valuesClient.length; x++) {
//       distanceInMeters = await Geolocator().distanceBetween(
//           _origin.latitude,
//           _origin.longitude,
//           double.parse(valuesClient[x].lat),
//           double.parse(valuesClient[x].lng));
//       valuesClient[x].distancia = distanceInMeters;
//     }
//     return valuesClient;
//   }

//   List<ClientCredit> ordenarPorDistancia(List<ClientCredit> c) {
//     int size = c.length;
//     for (int i = 0; i < size - 1; i++) {
//       for (int j = 0; j < size - 1; j++) {
//         if (c[j].distancia < c[j + 1].distancia) {
//           ClientCredit tmp = c[j + 1];
//           c[1 + j] = c[j];
//           c[j] = tmp;
//         }
//       }
//     }
//     return c;
//   }

//   /////////////////////// INICIO TALLARIN //////////////////////////
//   // ! SEND REQUEST
//   void sendRequest(LatLng origen, LatLng destino, String puntos) async {
//     print("Graficando... $_origin ");
//     String route =
//         await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
//     createRoute(route);
//   }

//   // ! TO CREATE ROUTE
//   void createRoute(String encondedPoly) {
//     _polyLines.clear();
//     print("Pintar linea azul");
//     _polyLines.add(Polyline(
//         polylineId: PolylineId(_origin.toString()),
//         width: 8,
//         geodesic: true,
//         points: _convertToLatLng(_decodePoly(encondedPoly)),
//         color: Colors.blue));
//   }

//   List<LatLng> _convertToLatLng(List points) {
//     List<LatLng> result = <LatLng>[];
//     for (int i = 0; i < points.length; i++) {
//       if (i % 2 != 0) {
//         result.add(LatLng(points[i - 1], points[i]));
//       }
//     }
//     return result;
//   }

//   // !DECODE POLY
//   List _decodePoly(String poly) {
//     var list = poly.codeUnits;
//     var lList = new List();
//     int index = 0;
//     int len = poly.length;
//     int c = 0;
//     //repeating until all attributes are decoded
//     do {
//       var shift = 0;
//       int result = 0;

//       // for decoding value of one attribute
//       do {
//         c = list[index] - 63;
//         result |= (c & 0x1F) << (shift * 5);
//         index++;
//         shift++;
//       } while (c >= 32);
//       /* if value is negetive then bitwise not the value */
//       if (result & 1 == 1) {
//         result = ~result;
//       }
//       var result1 = (result >> 1) * 0.00001;
//       lList.add(result1);
//     } while (index < len);

//     /*adding to previous value as done in encoding */
//     for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

//     //print(lList.toString() + "\n");
//     return lList;
//   }
//   ///////////////////////  FIN TALLARIN  //////////////////////////

// }
