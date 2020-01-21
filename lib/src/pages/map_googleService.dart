import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = "AIzaSyAdoB5hIORuaqfcPStZX8r61NCu2vV7xwE";

class GoogleMapsServices{
    Future<String> getRouteCoordinates(LatLng origin, LatLng destination, String waypoints)async{
      print("Origen: $origin");
      print("Destino: $destination");
      print("WayPoints: $waypoints");
    print("Graficando En google...");
    print("URL");
    print("https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypoints&key=$apiKey");
    print("URL");
      String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypoints&key=$apiKey";
      http.Response response = await http.get(url);
      Map values = jsonDecode(response.body);
      return values["routes"][0]["overview_polyline"]["points"];
    }
}