import 'package:flutter/material.dart';
import 'package:paycapp/src/pages/payments/payments_widgets.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/utils.dart';

//Variables
String _fecha = "";
String category = 'diario';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class ShowPaymentsPage extends StatefulWidget {
  ShowPaymentsPage({Key key}) : super(key: key);

  @override
  _ShowPaymentsPageState createState() => _ShowPaymentsPageState();
}

class _ShowPaymentsPageState extends State<ShowPaymentsPage> {
  @override
  void initState() {
    _fecha = _currentTime();
    super.initState();
  }

  bool _reload = true;
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Cobros \t | \t $_fecha"),
              actions: <Widget>[
                // action button
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
            body: FutureBuilder(
              //lista del servidor
              future:
                  CreditProvider().listPaymentsForDay(_fecha),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return renderError(snapshot.error, () {});
                }

                if (!snapshot.hasData) return loader(text: "Cargando pagos...");

                var results = snapshot.data.data;

                if (results != null && results.length <= 0) {
                  return renderNotFoundData("No tienes rutas asignadas aún");
                }
                print(results[category] == null);
                _reload = false;
                return Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[_boxRoute(contenido: "1")],
                    ),
                    _lista(results[category], context, _scaffoldKey),
                  ],
                );
              },
            )));
  }

  void choiceAction(String choice) {
    category = choice;
    _retry();
  }

  Widget _lista(results, context, scaffoldKey) {
    if (results.length == 0) {
      return Expanded(child: renderNotFoundData("No hay cobros de tipo ${category.toUpperCase()} en esta fecha"),);
    }

    return Expanded(
        child: ListView.builder(

            scrollDirection: Axis.vertical,
            itemCount: results.length,
            itemBuilder: (context, index) {
              print("DATOS: ${results.length}");
              var payment = results[index];
              return slideableForPyments(
                  idPago: payment['id'].toString(),
                  name: payment['client_name'],
                  surname: payment['client_surname'],
                  address: payment['address'],
                  state: payment['status'].toString(),
                  value: payment['total'].toString(),
                  creditID: payment['credit_id'].toString(),
                  refDetail: payment['ref_detail'],
                  refImage: payment['ref_img'].toString(),
                  lat: payment['lat'].toString(),
                  lon: payment['lon'].toString(),
                  retry: _retry,
                  context: context,
                  scaffoldKey: scaffoldKey,
                  showDetail: true);
            }));
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
        _reload = true;
      });
    }
  }

  Container _boxRoute({String contenido: '', String etiqueta: ''}) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey,
              )
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Ruta #$contenido",
                  style: TextStyle(fontSize: 25),
                ),
              ],
            )));
  }

  _retry() {
    setState(() {});
  }
}
