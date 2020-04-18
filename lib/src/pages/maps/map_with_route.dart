import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/providers/route_google_provider.dart';
import 'package:paycapp/src/utils/utils.dart';

class MapRoutePage extends StatefulWidget {
  final List<DataClient> cliente;

  MapRoutePage({Key key, @required this.cliente}) : super(key: key);

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

// Constantes para los colores de los estados
final double _yellow = 45.0;
final double _green = 75.0;
final double _reed = BitmapDescriptor.hueRed;
// Variables para graficar la ruta del mapa
Set<Polyline> _polyLines = {};
LatLng _destination;
String _wayPoints = "";
//Datos del cliente
String _name = "";
String _address = "";
DataClient _dataClient = new DataClient("0.0", "0.0", "", "");

class _MapRoutePageState extends State<MapRoutePage> {
  // Para almacenar la posicion actual
  LatLng _currentCoridinates;
  // Para indicar en donde se enfocara la pantalla al inicar el mapa
  CameraPosition _initialCameraPosition;
  double _zoomForMap = 15.0;
  // Para definir los pines en el mapa
  Set<Marker> _markers = Set();
  // Para el widget flotante al hacer clic sobre un pin
  double _position = -100;
  // Para llamar al servicio de consulta de ruta
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _destination = null;
    _wayPoints = "";
    _polyLines = {};
    //Este metodo carga todo lo necesario para cuando el ususario quiera ver una ruta
    // getCoordinates(widget.cliente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Visualizar rutas'),
          centerTitle: true,
          actions: <Widget>[
            // Para ver la ruta en el mapa
            // IconButton(
            //   icon: Icon(Icons.directions_car),
            //   onPressed: () {
            //     print("Origen: $_currentCoridinates");
            //     print("WAY: $_wayPoints");
            //     print("Destino: $_destination");
            //     if (_destination == null) {
            //       _displayText(context,
            //           text: "No hy datos suficientes para mostrar una ruta");
            //     } else {
            //       sendRequest(
            //           destino: _destination,
            //           origen: _currentCoridinates,
            //           puntos: _wayPoints);
            //       _retry();
            //     }
            //   },
            // )
          ]),
      body: FutureBuilder<Position>(
        future: _getPosition(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Si no tiene datos, mostrar un loading
          if (!snapshot.hasData) {
            return loader();
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

  Widget _map(data, List<DataClient> listaClientes, context) {
    LatLng _locationClient;

    _currentCoridinates = LatLng(data.latitude, data.longitude);

    _initialCameraPosition = CameraPosition(
        target:
            LatLng(_currentCoridinates.latitude, _currentCoridinates.longitude),
        zoom: _zoomForMap);

    _markers.add(new Marker(
      onTap: () => _hideCard(),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      position: _currentCoridinates,
      markerId: MarkerId('$_currentCoridinates'),
      infoWindow: InfoWindow(title: "Tu ubicación"),
    ));

    for (var item in listaClientes) {
      _locationClient = LatLng(double.parse(item.lat), double.parse(item.lng));
      _markers.add(new Marker(
        onTap: () {
          // Cuando se hace clic en un pin se cargan los datos que la tarjeta va a tener
          _position = double.minPositive;
          _dataClient = item;
          _retry();
        },
        icon: _getBitmapDescriptor(item.status),
        draggable: false,
        position: LatLng(_locationClient.latitude, _locationClient.longitude),
        markerId: MarkerId('$_locationClient'),
        // infoWindow: InfoWindow(title: "${item.name}", snippet: "${item.address}"),
      ));
    }
    widget.cliente.clear();

    return Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (v) {
            _hideCard();
          },
          compassEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          rotateGesturesEnabled: true,
          markers: Set<Marker>.of(_markers),
          polylines: _polyLines,
        ),
        _tarjetaFlotante(),
      ],
    );
  }

  void _hideCard() {
    //Con esta opcion oculto la tarjeta cuando se aplaste fuera del pin
    _position = -100;
    _retry();
  }

  void _retry() {
    setState(() {});
  }

  // Este metodo retorna el color del pin dependiendo su estatus
  BitmapDescriptor _getBitmapDescriptor(int status) {
    switch (status) {
      case 1:
        return BitmapDescriptor.defaultMarkerWithHue(_yellow);
        break;
      case 2:
        return BitmapDescriptor.defaultMarkerWithHue(_green);
        break;
      case -1:
        return BitmapDescriptor.defaultMarkerWithHue(_reed);
        break;
      default:
        return BitmapDescriptor.defaultMarkerWithHue(_yellow);
        break;
    }
  }

  // Este widget se posiciona por la parte superior y al cambiar sus dimensiones desaparece con una animacion
  // Los valores que carga son name y addres declarados al inicio y cambian sus botones en base al pin seleccionado
  Widget _tarjetaFlotante() {
    return AnimatedPositioned(
        top: _position,
        right: 0,
        left: 0,
        duration: Duration(milliseconds: 200),
        child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: EdgeInsets.all(20),
                // height: 70,
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
                  mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        width: 50,
                        height: 50,
                        child: Icon(Icons.person_pin),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 15, top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _dataClient.name.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_dataClient.address,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              _showStatus(_dataClient.status),
                              _showZone(_dataClient.zone),
                            ],
                          ),
                        ),
                      ),
                    ]))));
  }

  // Muestra la zona del cliente
  Widget _showZone(String zone){
    return Visibility(visible: zone != null, child: Text("Zona: $zone"),);
  }

  // Muestra texto en base al estado de pago
  Widget _showStatus(int status) {
    switch (status) {
      case 1:
        return Visibility(
          visible: status != null,
          child: Text("ESTADO: PENDIENTE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),));
        break;
      case 2:
        return Visibility(
          visible: status != null,
          child: Text("ESTADO: COBRADO",style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),));
        break;
      case -1:
        return Visibility(
          visible: status != null,
          child: Text("ESTADO: MORA",style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),));
        break;
      default:
        return Visibility(
          visible: status != null,
          child: Text("ESTADO: PENDIENTE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),));
        break;
    }
  }

  // BitmapDescriptor _bitmapDescriptor;
  // _getBitmapDescriptorSeconOption(String cobros, int status) async {
  //   String assetPath =
  //       'assets/img/pin/${cobros.toLowerCase()}/${_getStatus(status)}.png';
  //   _bitmapDescriptor = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.5), assetPath);
  // }

  // String _getStatus(int status) {
  //   String st = 'pendiente';
  //   switch (status) {
  //     case 1:
  //       st = 'pendiente';
  //       break;

  //     case 2:
  //       st = 'cobrado';
  //       break;

  //     case -1:
  //       st = 'mora';
  //       break;

  //     default:
  //       st = 'pendiente';
  //       break;
  //   }
  //   return st;
  // }


  // obtener la ultima posicion de la lista
  getCoordinates(List<DataClient> values) {
    //Si la lista es mayor a cero ejecuto el metodo
    if (values.length > 0) {
      //Obtener el ultimo valor de la lista
      _destination = new LatLng(double.parse(values[values.length - 1].lat),
          double.parse(values[values.length - 1].lng));
      //Eliminar el ultimo valor de la lista
      // values.removeLast();
      //Si quedan elementos en la lista, obtengo los puntos del camino de la ruta
      if (values.length - 1 > 0) {
        // _waypointsObtenidos = false;
        getWaypoints(values);
      } //else {
      //   _waypointsObtenidos = true;
      // }
    }
    return true;
  }

  //Obtener los puntos medios para la consulta con el API de google
  getWaypoints(List<DataClient> valuesClient) {
    _wayPoints = "";
    for (int i = 0; i < valuesClient.length - 1; i++) {
      _wayPoints =
          _wayPoints + "${valuesClient[i].lat},${valuesClient[i].lng}|";
    }
    // _waypointsObtenidos = true;
    print("WP: $_wayPoints");
    // return true;
  }

  // Esto lo copie del codigo de UberClone
  // asi que ni idea como funciona,
  // pero funciona
  /////////////////////// INICIO TALLARIN //////////////////////////
  // ! SEND REQUEST
  void sendRequest(
      {@required LatLng origen,
      @required LatLng destino,
      @required String puntos}) async {
    print("Graficando... $origen ");
    String route =
        await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
    createRoute(route);
  }

  // ! TO CREATE ROUTE
  void createRoute(String encondedPoly) {
    _polyLines.clear();
    print("Pintar linea azul");
    _polyLines.add(Polyline(
        polylineId: PolylineId("1"),
        width: 8,
        geodesic: true,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.blue));
    _retry();
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

    return lList;
  }

  ///////////////////////  FIN TALLARIN  //////////////////////////
  Future _displayText(BuildContext context, {@required String text}) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text(
            'AVISO',
            textAlign: TextAlign.center,
          ),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
