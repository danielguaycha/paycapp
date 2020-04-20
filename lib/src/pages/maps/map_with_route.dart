import 'dart:async';

import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/pages/payments/payments_widgets.dart';
import 'package:paycapp/src/providers/route_google_provider.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart';

class MapRoutePage extends StatefulWidget {
  final List<DataClient> cliente;

  MapRoutePage({Key key, @required this.cliente}) : super(key: key);

  @override
  _MapRoutePageState createState() => _MapRoutePageState();
}

ProgressLoader _newLoader;
GlobalKey<ScaffoldState> _newScaffoldKey;
GoogleMapController _mapController;

// Constantes para los colores de los estados
final double _yellow = 45.0;
final double _green = 75.0;
final double _reed = BitmapDescriptor.hueRed;
// Variables para graficar la ruta del mapa
// -- Set<Polyline> _polyLines = {};
// -- LatLng _destination;
// -- String _wayPoints = "";
//Datos del cliente
DataClient _dataClient = new DataClient("0.0", "0.0", "", "");
String _category = 'DIARIO';
// List<DataClient> _nuevocliente = List<DataClient>();
// List<DataClient> _nuevoclienteresp = List<DataClient>();
// Para almacenar la posicion actual
LatLng _currentCoridinates;

class _MapRoutePageState extends State<MapRoutePage> {
  // Para indicar en donde se enfocara la pantalla al inicar el mapa
  CameraPosition _initialCameraPosition;
  double _zoomForMap = 12.0;
  // Para definir los pines en el mapa
  Set<Marker> _markers = Set();
  // Para el widget flotante al hacer clic sobre un pin
  double _position = -100;
  // Para llamar al servicio de consulta de ruta
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    // _nuevoclienteresp = widget.cliente;
    // for (var item in _nuevoclienteresp) {
    //   _nuevocliente.add(item);
    // }
    // TODO: implement initState
    super.initState();
     // = widget.cliente;
    // -- _destination = null;
    // -- _wayPoints = "";
    // -- _polyLines = {};
    //Este metodo carga todo lo necesario para cuando el ususario quiera ver una ruta
    // getCoordinates(widget.cliente);
  }

  @override
  Widget build(BuildContext context) {
    _newLoader = new ProgressLoader(context);
    return Scaffold(
      key: _newScaffoldKey,
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
            // Para ver la ruta en el mapa
          // PopupMenuButton<String>(
          //   onSelected: choiceAction,
          //   itemBuilder: (BuildContext context) {
          //     return choicesForPyments.map((String choice) {
          //       return PopupMenuItem<String>(
          //         value: choice,
          //         child: Text(
          //           choice.toUpperCase(),
          //           style: TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       );
          //     }).toList();
          //   },
          // ),
          ]),
      body: FutureBuilder<Position>(
        future: _getPosition(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Si no tiene datos, mostrar un loading
          if (!snapshot.hasData) {
            return loader();
          }

          return _map(snapshot.data, widget.cliente, context);
          // return _map(snapshot.data, _nuevocliente, context);
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

    if(listaClientes.length >= 1){

    _initialCameraPosition = CameraPosition(
        target:
            LatLng(double.parse(listaClientes.first.lat), double.parse(listaClientes.first.lng)),
        zoom: _zoomForMap);
    }

        // _controller.

    _markers.add(Marker(
      onTap: () => _hideCard(),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      position: _currentCoridinates,
      markerId: MarkerId('myOnlyId'),
      infoWindow: InfoWindow(title: "Tu ubicación"),
    ));

    for (var item in listaClientes) {
      // if(item.cobro == _category){

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
      // }
    }

    // Codigo para la paleta de colores
    // double x = 0.0;
    // for (double i = 0.0; i < 360; i = i + 0.1) {

    //   x = x + 0.000008;
    //   _markers.add(new Marker(
    //     icon: BitmapDescriptor.defaultMarkerWithHue(i),
    //     position: new LatLng(-3.2889400 + x,-79.899520 + x),
    //     markerId: MarkerId("$i"),
    //     infoWindow: InfoWindow(title: "$i")
    //     ));
    // }
    // print("Leng nuevo: ${_nuevocliente.length}");
    widget.cliente.clear();

    return Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (v) {
            _hideCard();
          },
          onMapCreated: _onMapCreated,
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

  void _hideCard() {
    //Con esta opcion oculto la tarjeta cuando se aplaste fuera del pin
    _position = -100;
    _retry();
  }

  void _retry() {

    _markers.removeWhere((m) => m.markerId.value == 'myOnlyId');
    _markers.removeWhere((m) => m.markerId.value == 'myOnlyId');
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
                      _showTypePayment(_dataClient.cobro, _dataClient.status),
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(left: 15, top: 5.0, bottom: 5.0),
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
                      // Expanded(child:
                      Visibility(
                          visible: _dataClient.status != null,
                          child: Container(
                            margin: EdgeInsets.only(left: 10),
                            width: 50,
                            height: 50,
                            child: PopupMenuButton<String>(
                              onSelected: choiceAction,
                              itemBuilder: (BuildContext context) {
                                return actionForMap.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(
                                      choice.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          )),
                    ]))));
  }

  void choiceFilter(String choice) async {
    _category = choice;

  }
  void choiceAction(String choice) async {
    switch (choice) {
      case "cobrar":
        if (_dataClient.status == TYPE_PAGADO) {
          return null;
        }

        String process = await updatePayment(
            _dataClient.idPayment, TYPE_PAGADO, context,
            title: "Realizar pago",
            content: "¿Está seguro de realizar este pago?");
        if (process != null) {
          if (process == "OK") {
            Alert.toast(context, "Pago realizado");
            _dataClient.status = TYPE_PAGADO;
            widget.cliente.add(_dataClient);
            _retry();
          } else {
            Alert.toast(context, process);
          }
        }
        break;
      case "marcar en mora":
        if (_dataClient.status == TYPE_MORA) {
          return null;
        }

        if (_dataClient.status == TYPE_PAGADO) {
          Alert.toast(context, "Esta pago ya fue procesado");
          return null;
        }

        String process = await updatePayment(
            _dataClient.idPayment, TYPE_MORA, context,
            title: "Marcar en Mora",
            content: "¿Está seguro que desea marcar como mora este pago?");
        if (process != null) {
          if (process == "OK") {
            Alert.toast(context, "Marcado como mora");
            _dataClient.status = TYPE_MORA;
            widget.cliente.add(_dataClient);
            _retry();
          } else {
            Alert.toast(context, process);
          }
        }
        break;
      case "anular":
        if (_dataClient.status == TYPE_MORA ||
            _dataClient.status == TYPE_PENDIENTE) {
          Alert.toast(context, "Solo se pueden anular pagos procesados");
          return null;
        }

        String process =
            await cancelPaymentOnPayments(_dataClient.idPayment, context);
        if (process != null) {
          if (process == "OK") {
            Alert.toast(context, "Pago anulado con exito");
            _dataClient.status = TYPE_PENDIENTE;
            widget.cliente.add(_dataClient);
            _retry();
          } else {
            Alert.toast(context, process);
          }
        }
        break;
      case "ver detalle":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ListPaymentsPage(id: _dataClient.idCredit)));
        print("Ver detalle seleccionado");
        break;
    }
  }

  Color _setColor(int status) {
    switch (status) {
      case TYPE_PENDIENTE:
        return Colors.grey;
        break;
      case TYPE_PAGADO:
        return Colors.green;
        break;
      case TYPE_MORA:
        return Colors.red;
        break;
      default:
        return Colors.grey;
        break;
    }
  }

  // Muestra un icono diferente para pagos
  Widget _showTypePayment(String cobro, int status) {
    if (cobro == null) {
      return Container(
        margin: EdgeInsets.only(left: 10),
        width: 40,
        height: 40,
        child: Icon(Icons.person_pin),
      );
    }
    String _text = "D";
    Color _color = _setColor(status);

    switch (cobro) {
      case "DIARIO":
        _text = "D";
        break;
      case "SEMANAL":
        _text = "S";
        break;
      case "QUINCENAL":
        _text = "Q";
        break;
      case "MENSUAL":
        _text = "M";
        break;
      default:
        _text = "D";
        break;
    }

    return Container(
      margin: EdgeInsets.only(left: 10),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _color),
      ),
      child: Center(
        child: Text(
          _text,
          style: TextStyle(
              color: _color, fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Muestra la zona del cliente
  Widget _showZone(String zone) {
    return Visibility(
      visible: zone != null,
      child: Text("Zona: $zone"),
    );
  }

  // Muestra texto en base al estado de pago
  Widget _showStatus(int status) {
    String _text = "ESTADO: PENDIENTE";
    bool _visible = (status != null);
    switch (status) {
      case TYPE_PENDIENTE:
        _text = "ESTADO: PENDIENTE";
        break;
      case TYPE_PAGADO:
        _text = "ESTADO: COBRADO";
        break;
      case TYPE_MORA:
        _text = "ESTADO: MORA";
        break;
    }
    return Visibility(
        visible: _visible,
        child: Text(
          _text,
          style:
              TextStyle(color: _setColor(status), fontWeight: FontWeight.bold),
        ));
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
  // -- getCoordinates(List<DataClient> values) {
  // --   //Si la lista es mayor a cero ejecuto el metodo
  // --   if (values.length > 0) {
  // --     //Obtener el ultimo valor de la lista
  // --     _destination = new LatLng(double.parse(values[values.length - 1].lat),
  // --         double.parse(values[values.length - 1].lng));
  // --     //Eliminar el ultimo valor de la lista
  // --     // values.removeLast();
  // --     //Si quedan elementos en la lista, obtengo los puntos del camino de la ruta
  // --     if (values.length - 1 > 0) {
  // --       // _waypointsObtenidos = false;
  // --       getWaypoints(values);
  // --     } //else {
  // --     //   _waypointsObtenidos = true;
  // --     // }
  // --   }
  // --   return true;
  // -- }

  // -- //Obtener los puntos medios para la consulta con el API de google
  // -- getWaypoints(List<DataClient> valuesClient) {
  // --   _wayPoints = "";
  // --   for (int i = 0; i < valuesClient.length - 1; i++) {
  // --     _wayPoints =
  // --         _wayPoints + "${valuesClient[i].lat},${valuesClient[i].lng}|";
  // --   }
  // --   // _waypointsObtenidos = true;
  // --   print("WP: $_wayPoints");
  // --   // return true;
  // -- }
 
  // -- // Esto lo copie del codigo de UberClone
  // -- // asi que ni idea como funciona,
  // -- // pero funciona
  // -- /////////////////////// INICIO TALLARIN //////////////////////////
  // -- // ! SEND REQUEST
  // -- void sendRequest(
  // --     {@required LatLng origen,
  // --     @required LatLng destino,
  // --     @required String puntos}) async {
  // --   print("Graficando... $origen ");
  // --   String route =
  // --       await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
  // --   createRoute(route);
  // -- }
 
  // -- // ! TO CREATE ROUTE
  // -- void createRoute(String encondedPoly) {
  // --   _polyLines.clear();
  // --   print("Pintar linea azul");
  // --   _polyLines.add(Polyline(
  // --       polylineId: PolylineId("1"),
  // --       width: 8,
  // --       geodesic: true,
  // --       points: _convertToLatLng(_decodePoly(encondedPoly)),
  // --       color: Colors.blue));
  // --   _retry();
  // -- }
 
  // -- List<LatLng> _convertToLatLng(List points) {
  // --   List<LatLng> result = <LatLng>[];
  // --   for (int i = 0; i < points.length; i++) {
  // --     if (i % 2 != 0) {
  // --       result.add(LatLng(points[i - 1], points[i]));
  // --     }
  // --   }
  // --   return result;
  // -- }
 
  // -- // !DECODE POLY
  // -- List _decodePoly(String poly) {
  // --   var list = poly.codeUnits;
  // --   var lList = new List();
  // --   int index = 0;
  // --   int len = poly.length;
  // --   int c = 0;
  // --   //repeating until all attributes are decoded
  // --   do {
  // --     var shift = 0;
  // --     int result = 0;
 
  // --     // for decoding value of one attribute
  // --     do {
  // --       c = list[index] - 63;
  // --       result |= (c & 0x1F) << (shift * 5);
  // --       index++;
  // --       shift++;
  // --     } while (c >= 32);
  // --     /* if value is negetive then bitwise not the value */
  // --     if (result & 1 == 1) {
  // --       result = ~result;
  // --     }
  // --     var result1 = (result >> 1) * 0.00001;
  // --     lList.add(result1);
  // --   } while (index < len);
 
  // --   /*adding to previous value as done in encoding */
  // --   for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];
 
  // --   return lList;
  // -- }
 
  // -- ///////////////////////  FIN TALLARIN  //////////////////////////
  // -- Future _displayText(BuildContext context, {@required String text}) async {
  // --   return showDialog(
  // --     context: context,
  // --     builder: (context) {
  // --       return AlertDialog(
  // --         shape: RoundedRectangleBorder(
  // --             borderRadius: BorderRadius.all(Radius.circular(20))),
  // --         title: Text(
  // --           'AVISO',
  // --           textAlign: TextAlign.center,
  // --         ),
  // --         content: Text(text),
  // --         actions: <Widget>[
  // --           FlatButton(
  // --             child: Text('OK'),
  // --             onPressed: () {
  // --               Navigator.of(context).pop();
  // --             },
  // --           ),
  // --         ],
  // --       );
  // --     },
  // --   );
  // -- }
}
