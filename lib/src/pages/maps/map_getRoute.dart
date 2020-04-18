// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:paycapp/src/providers/route_google_provider.dart';

// class AppState with ChangeNotifier {
//   static LatLng _initialPosition;
//   LatLng _lastPosition = _initialPosition;
//   bool locationServiceActive = true;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polyLines = {};
//   GoogleMapController _mapController;
//   GoogleMapsServices _googleMapsServices = GoogleMapsServices();
//   TextEditingController locationController = TextEditingController();
//   TextEditingController destinationController = TextEditingController();
//   LatLng get initialPosition => _initialPosition;
//   LatLng get lastPosition => _lastPosition;
//   GoogleMapsServices get googleMapsServices => _googleMapsServices;
//   GoogleMapController get mapController => _mapController;
//   Set<Marker> get markers => _markers;
//   Set<Polyline> get polyLines => _polyLines;

//   AppState() {}

//   // ! SEND REQUEST
//   void sendRequest(
//     LatLng origen,
//     LatLng destino,
//     String puntos,
//   ) async {
//     String route =
//         await _googleMapsServices.getRouteCoordinates(origen, destino, puntos);
//     createRoute(route);
//     notifyListeners();
//   }

//   // ! TO CREATE ROUTE
//   void createRoute(String encondedPoly) {
//     print("Puntos: $encondedPoly");
//     print("Puntos: ${_polyLines.toString()}");

//     _polyLines.add(Polyline(
//         polylineId: PolylineId(_lastPosition.toString()),
//         width: 8,
//         geodesic: true,
//         points: _convertToLatLng(_decodePoly(encondedPoly)),
//         color: Colors.red));
    
//     print("Linea!");
//     print(_polyLines.isEmpty);
//     print("Linea!");

//     notifyListeners();
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
// // repeating until all attributes are decoded
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

// /*adding to previous value as done in encoding */
//     for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

//     //print(lList.toString() + "\n");

//     return lList;
//   }
// }
