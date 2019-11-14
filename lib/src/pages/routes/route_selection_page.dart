import 'package:flutter/material.dart';
import 'package:paycapp/src/models/ruta_model.dart';
import 'package:paycapp/src/providers/route_provider.dart';
import 'package:paycapp/src/utils/utils.dart' show loader, renderError, renderNotFoundData;

class RouteSelectionPage extends StatefulWidget {
  RouteSelectionPage({Key key}) : super(key: key);

  @override
  _RouteSelectionPageState createState() => _RouteSelectionPageState();
}

class _RouteSelectionPageState extends State<RouteSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccione Ruta')),
      body:  _getRoutes(),
    );
  }

  _getRoutes() {
    return FutureBuilder(
      future: RouteProvider().getRoutes(),
      builder: (context, snapshot) {      
                    
          if(snapshot.hasError){
            return renderError(snapshot.error, _reintentar);           
          }
          
          if(!snapshot.hasData) 
            return loader(text: "Cargando rutas...");

          var results = snapshot.data.data;
          if(results != null && results.length <=0) {
            return renderNotFoundData("No tienes rutas asignadas aún");
          }
                  
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, int index) {
              var route = Ruta.fromJson(results[index]);
              return ListTile(
                    leading: Icon(Icons.map, size: 30,color: Theme.of(context).accentColor),                                        
                    trailing: Icon(Icons.add, color: Theme.of(context).primaryColor),
                    title: Text("${route.name}".toUpperCase(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),),
                    subtitle: Text("${route.description}"),
                    onTap:() {
                        Navigator.pop(context, route);
                    },
                  );
            },      
          );
      },
    );
  }
  _reintentar() {
    setState(() {
      
    });
  }
}