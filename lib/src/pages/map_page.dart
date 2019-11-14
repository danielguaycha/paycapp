import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final Set<Marker> _markers = Set();

  CameraPosition _initialPosition = CameraPosition(target: LatLng(26.8206, 30.8025), zoom: 100.0);
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Visualizar rutas'),
          centerTitle: true,
        ),
        body: FutureBuilder<Position>(
          future: _getLoc(),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
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
              _initialPosition = CameraPosition(target: LatLng(snapshot.data.latitude, snapshot.data.longitude), zoom: 15.5);
              _markers.add(
                  Marker(
                      markerId: MarkerId('Mi localización'),
                      position: LatLng(snapshot.data.latitude, snapshot.data.longitude),
                       infoWindow: InfoWindow(title: 'Shumiral', snippet: 'Casa de Daniel Guaycha')
                  ),
                );
              //print(snapshot.data.latitude);
              return _map();
            }
          }      
        )
      );
  }

  _map() {
    return Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialPosition,            
                rotateGesturesEnabled: false,
                markers: _markers,
            ),
          ],
        );
  }

  Future<Position> _getLoc() async {
    return await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
