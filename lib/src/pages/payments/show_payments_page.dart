import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paycapp/src/config.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/models/ruta_model.dart';
import 'package:paycapp/src/pages/payments/payments_widgets.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/providers/route_provider.dart';
import 'package:paycapp/src/utils/utils.dart';

import '../../brain.dart';
import '../maps/map_with_route.dart';

//Variables
String _fecha = "";
String category = 'diario';
Ruta route;
final _scaffoldKey = GlobalKey<ScaffoldState>();
List<DataClient> _paymentsClients = new List<DataClient>();

class ShowPaymentsPage extends StatefulWidget {
  ShowPaymentsPage({Key key}) : super(key: key);

  @override
  _ShowPaymentsPageState createState() => _ShowPaymentsPageState();
}

class _ShowPaymentsPageState extends State<ShowPaymentsPage> {
  @override
  void initState() {
    _fecha = _currentTime();

    // _loadRoute().then((data){
    //   route = Ruta.fromJson(data.data);
    // });
    _paymentsClients.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Cobros \t | \t $_fecha"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              if (_paymentsClients.length <= 0) {
                return null;
              }

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapRoutePage(cliente: _paymentsClients)));
            },
          ),

          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              await _selecionarFecha(context);
            },
          ),
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context) {
              return choicesForPyments.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          //  Expanded(
          //    flex: 1,
          //               child:
          //       FutureBuilder(
          //           future: RouteProvider().getRoutes(),
          //           builder: (context, snapshot) {
          //             if (snapshot.hasError) {
          //               return renderError(snapshot.error, _retry);
          //             }

          //             if (!snapshot.hasData)
          //               return loader(text: "Cargando rutas...");

          //             var results = snapshot.data.data;
          //             if (results != null && results.length <= 0) {
          //               return renderNotFoundData(
          //                   "No tienes rutas asignadas aún");
          //             }

          //             return ListView.builder(
          //               scrollDirection: Axis.horizontal,
          //               itemCount: results.length,
          //               itemBuilder: (BuildContext context, int index) {
          //                 var route = Ruta.fromJson(results[index]);
          //                 print("Name: ${route.name}");
          //                 return _boxRoute(contenido: route.name);
          //               },
          //             );
          //           }),
          //  ),

          Expanded(
            flex: 6,
            child: _futureBuilderPyments(context, _scaffoldKey),
          )
        ],
      ),
    );
  }

// Widget _zones () {
//     return StoreConnector<AppState, dynamic>(
//         onInit: (store) => {

//         },
//         converter: (store) => store.state.user,
//         builder: (context, user) {
//           return DropdownButtonFormField(
//             value: _credit.rutaId == null ? 0 : _credit.rutaId,
//             itemHeight: 80,
//             isDense: true,
//             decoration: InputDecoration(
//                 icon: Icon(FontAwesomeIcons.route, color: Colors.orange,), labelText: 'Zona/Ruta'),
//             onChanged: (v) {
//               setState(() {
//                 _credit.rutaId = v;
//               });
//             },
//             items: _renderZones(user.zones),
//           );
//         },
//     );
//   }

  _loadRoute() async {
    var response = await RouteProvider().getRoutes();
    return response;
  }

  void choiceAction(String choice) {
    category = choice;
    _retry();
  }

  Widget _futureBuilderPyments(context, _scaffoldKey) {
    return FutureBuilder(
      //lista del servidor
      future: _paymentsClients.length <= 0 ? CreditProvider().listPaymentsForDay(_fecha) : null,

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Error");
          return renderError(snapshot.error, () {});
        }

        if (!snapshot.hasData) return loader(text: "Cargando pagos...");

        var results = snapshot.data.data;

        if (results != null && results.length <= 0) {
          return renderNotFoundData("No tienes rutas asignadas aún");
        }
        print("DATA: ${results[category].length}");

            _paymentsClients.clear();

        choicesForPyments.map((String choice) {
          _loadResultsToList(results[choice]);
        }).toList();

          print("ELEMENTO: ${_paymentsClients.length}");
        
        return Row(
          children: <Widget>[_lista(results[category], context, _scaffoldKey)],
        );
      },
    );
  }

  void _loadResultsToList(results) {
    for (int i = 0; i < results.length; i++) {
      var payment = results[i];
      _paymentsClients.add(new DataClient(
          payment['lat'].toString(),
          payment['lon'].toString(),
          "${payment['client_name']}  ${payment['client_surname']} ",
          payment['address'],
          totalPago: payment['total'],
          cobro: payment['cobro'],
          status: payment['status'],
          idPayment: payment['id'],
          idCredit: payment['credit_id'],
          ref_detail: payment['ref_detail'],
          ref_img: payment['ref_img'],
          payment: true,));
    }
  }

  Widget _lista(results, context, scaffoldKey) {
    if (results.length == 0) {
      return Expanded(
        child: renderNotFoundData(
            "No hay cobros de tipo ${category.toUpperCase()} en esta fecha"),
      );
    }

    return Expanded(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: results.length,
            itemBuilder: (context, index) {
              var payment = results[index];

              return slideableForPyments(
                  // dataCliente: _paymentsClients[index], 
                  dataCliente: new DataClient(
                    payment['lat'].toString(),
                    payment['lon'].toString(),
                    "${payment['client_name']} ${payment['client_surname']}",
                    payment['address'],
                    idPayment: payment['id'],
                    status: payment['status'],
                    totalPago: payment['total'].toString(),
                    idCredit: payment['credit_id'],
                    ref_detail: payment['ref_detail'],
                    ref_img: payment['ref_img'],
                    cobro: payment['cobro'],
                  ),
                  retry: _retry,
                  context: context,
                  scaffoldKey: scaffoldKey,
                  showDetail: true);
            }));
  }

  String _getStatus(int status) {
    String st = 'pendiente';
    switch (status) {
      case 1:
        st = 'pendiente';
        break;

      case 2:
        st = 'cobrado';
        break;

      case -1:
        st = 'mora';
        break;

      default:
        st = 'pendiente';
        break;
    }
    return st;
  }

  String _currentTime() {
    DateTime currentTime = new DateTime.now();
    return dateTimetoString(currentTime);
  }

  _selecionarFecha(BuildContext context) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2100),
      locale: Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fecha = dateTimetoString(picked);
        _paymentsClients.clear();
      });
    }
  }

  Widget _boxRoute({String contenido: ''}) {
    return Container(
      // color: colors['aaccent'],
      margin: EdgeInsets.all(10),
      child: RaisedButton(
        color: colors['accent'],
        child: Text(
          "$contenido",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {},
      ),
    );
  }

  _retry() {
    setState(() {});
  }
}
