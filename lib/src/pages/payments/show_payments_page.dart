import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:paycapp/src/utils/utils.dart';

//Variables
String _fecha = "";

class ShowPaymentsPage extends StatefulWidget {
  ShowPaymentsPage({Key key}) : super(key: key);

  @override
  _ShowPaymentsPageState createState() => _ShowPaymentsPageState();
}

class _ShowPaymentsPageState extends State<ShowPaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Cobros"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              await _selecionarFecha(context);
              print("Fecha: $_fecha");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[ _boxRoute(contenido: "1")],
          ),
          _containerCards(etiqueta: "DIARIOS"),
          Divider(),
          _containerCards(etiqueta: "SEMANALES"),
          Divider(),
          _containerCards(etiqueta: "QUINCENALES"),
          Divider(),
          _containerCards(etiqueta: "MENSUALES"),
        ],
      )),
    ));
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
        _fecha = picked.year.toString() +
            "-" +
            picked.month.toString() +
            "-" +
            picked.day.toString();
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
                  color: Colors.grey,)
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



  Container _containerCards({String etiqueta: ''}) {
    return Container(
        child: Column(
      children: <Widget>[
        Row(children: <Widget>[
          Text(
            "\t $etiqueta",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ]),
        _tarjeta(
            name: "Nixon Quezada",
            addres: "El Cambio",
            value: 15.75,
            state: "Pagado"),
        Divider(),
        _tarjeta(
            name: "Nixon Quezada",
            addres: "El Cambio",
            value: 15.75,
            state: "En mora"),
        Divider(),
        _tarjeta(
            name: "Nixon Quezada",
            addres: "El Cambio",
            value: 15.75,
            state: "Pendiente"),
      ],
    ));
  }

  Slidable _tarjeta({String name, String addres, double value, String state}) {
    Color _color = Colors.green;
    if (state == "En mora") {
      _color = Colors.red;
    } else if (state == "Pendiente") {
      _color = Colors.grey;
    }

    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "$name",
                          style: TextStyle(
                            fontSize: 20,
                            color: _color,
                          ),
                        ),
                        Text(
                          "$addres",
                          style: TextStyle(fontSize: 20, color: _color),
                        ),
                      ],
                    )
                  ],
                )),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          money(value),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 20,
                            color: _color,
                          ),
                        ),
                        Text(
                          "$state",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 20, color: _color),
                        ),
                      ],
                    )
                  ],
                )),
              ],
            )),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Pagar',
            color: Colors.blue,
            icon: Icons.payment,
            onTap: () async {
              //bool process = await _deleteCredit(credit['id'], context);
              //if(process){
              //  results.removeAt(index);
              //  setState(() {});
              //}
            },
          ),
          IconSlideAction(
            caption: 'Marcar \ncomo mora',
            color: Colors.red,
            icon: Icons.remove_circle_outline,
            onTap: () async {
              //bool process = await _deleteCredit(credit['id'], context);
              //if(process){
              //  results.removeAt(index);
              //  setState(() {});
              //}
            },
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Anular',
            color: Colors.black38,
            icon: Icons.delete,
            onTap: () async {
              //bool process = await _deleteCredit(credit['id'], context);
              //if(process){
              //  results.removeAt(index);
              //  setState(() {});
              //}
            },
          ),
          IconSlideAction(
            caption: 'Ver detalle',
            color: Colors.amber,
            icon: Icons.list,
            onTap: () async {
              //bool process = await _deleteCredit(credit['id'], context);
              //if(process){
              //  results.removeAt(index);
              //  setState(() {});
              //}
            },
          ),
        ]);
  }
}
