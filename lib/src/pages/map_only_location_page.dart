import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


double _latSelected = 0.0;
double _longSelected = 0.0;

class MapOnlyLocationPage extends StatefulWidget {
    final latitud;
  final longitud;
  String name;
  String addres;

  MapOnlyLocationPage({Key key, @required this.latitud, @required this.longitud, @required this.name, @required this.addres}) : super(key: key);

  @override
  _MapOnlyLocationPageState createState() => _MapOnlyLocationPageState();
}

class _MapOnlyLocationPageState extends State<MapOnlyLocationPage> {
  final Set<Marker> _markers = Set();
  CameraPosition _initialPosition;
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    _latSelected = double.parse(widget.latitud);
    _longSelected = double.parse(widget.longitud);

    return Scaffold(
        appBar: AppBar(
          title: Text("Ubicacion del cliente"),
          centerTitle: true,
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
                  _markers.add(
                    Marker(
                        draggable: false,
                        markerId: MarkerId('Inicial'),
                        position: new LatLng(_latSelected, _longSelected),                        
                        infoWindow: InfoWindow(
                          title: this.widget.name.toUpperCase(),
                          snippet: this.widget.addres.toUpperCase(),
                        )),
                  );
                _initialPosition = CameraPosition(target: LatLng(_latSelected, _longSelected),zoom: 15.5);
                return _map();
              }
            }))
            ;
  }

  _map() {
    return Stack(
      children: <Widget>[
        GoogleMap(
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

}