import 'dart:async';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paycapp/src/utils/messages_util.dart';

double _latSelected = 0.0;
double _longSelected = 0.0;
bool _locationChange = false;
class MapOnlyPage extends StatefulWidget {

  MapOnlyPage({Key key}) : super(key: key);

  @override
  _MapOnlyPageState createState() => _MapOnlyPageState();
}

class _MapOnlyPageState extends State<MapOnlyPage> {
  final Set<Marker> _markers = Set();

  CameraPosition _initialPosition = null;
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text("Seleccionar Ubicacion"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          backgroundColor: Colors.orange[300],
          onPressed: () async {
            _sendLocation();
          },
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
                if (!_locationChange) {
                  print("Pinta la marca inicial");
                  //Obtener puntos iniciales
                  _latSelected = snapshot.data.latitude;
                  _longSelected = snapshot.data.longitude;

                  //Crear marca inicial
                  _markers.add(
                    Marker(
                        draggable: false,
                        markerId: MarkerId('Inicial'),
                        position: new LatLng(_latSelected, _longSelected),                        
                        infoWindow: InfoWindow(
                          title: "Ubicacion del cliente",
                        )),
                  );
                }
                _initialPosition = CameraPosition(target: LatLng(snapshot.data.latitude, snapshot.data.longitude),zoom: 15.5);
                return _map();
              }
            }))
            ;
  }

  _map() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onTap: (v) {
            setState(() {
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
              _latSelected = v.latitude;
              _longSelected = v.longitude;
              _locationChange = true;
            });
          },
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialPosition,
          rotateGesturesEnabled: false,
          markers: Set<Marker>.of(_markers),
        ),
      ],
    );
  }

  Future<Position> _getLoc() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
 
  void _sendLocation() async{
    LatLng coordenadas = new LatLng(_latSelected, _longSelected);
    if (_locationChange) {
      bool res = await _sendLocationAlert(context, "Enviar ubicacion");
      if (res) {
        _locationChange = false;
        Navigator.pop(context, coordenadas);
      }
    } else {
      bool res = await _sendLocationAlert(context, "Se enviara la ubicacion actual");
      if (res) {
        _locationChange = false;
        Navigator.pop(context, coordenadas);
      }      
    }
  }
  // Alert Enviar Dialogo
 
  Future<bool> _sendLocationAlert(context, String title) async {
    int isOk = await Alert.confirm(context,
        title: "$title",
        content: "¿Está seguro que desea enviar esta ubicación?");
    if (isOk == 1) {
      return false;
    }
    return true;
  }
}