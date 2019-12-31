import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart';

class ListPaymentsPage extends StatefulWidget {
  final int id;

  ListPaymentsPage({Key key, @required this.id}) : super(key: key);

  @override
  _ListPaymentsPageState createState() => _ListPaymentsPageState();
}

class _ListPaymentsPageState extends State<ListPaymentsPage> {
  ProgressLoader _loader;
  TextEditingController _textEditingController = new TextEditingController();
  String reason = "";
  
  @override
  Widget build(BuildContext context) {
    _loader = new ProgressLoader(context);

  return Scaffold(
        appBar: AppBar(
          title: Text("Historial de Cobros"),
        ),
        body: FutureBuilder(
          //lista del servidor
          future: CreditProvider().listPayments(widget.id),

          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return renderError(snapshot.error, () {});
            }

            if (!snapshot.hasData) return loader(text: "Cargando créditos...");

            var results = snapshot.data.data;

            if (results != null && results.length <= 0) {
              return renderNotFoundData("No tienes rutas asignadas aún");
            }

            return _bodyPayments(results);
          },
        ));
  }

  Widget _bodyPayments(results) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        _labelClient(
            contenido:
                "${results['name']} ${results['surname']}".toUpperCase()),
        Row(
          children: <Widget>[
            Expanded(
              child: _mediumCircle(
                  value: "\$ ${results['monto']}", etiqueta: "Prestamo"),
            ),
            Expanded(
              child: _bigCircle(
                  value: "\$ ${results['total']}", etiqueta: "Total a pagar"),
            ),
            Expanded(
              child: _mediumCircle(
                  value: "${results['utilidad']} %", etiqueta: "Interés"),
            ),
          ],
        ),
        Center(
          child: _labelDetail(
              description:
                  "${results['description']}"), //pagos: 7, value: 20.0, plazo: "SEMANAL"),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _labelInformation(
                  contenido: "${results['total_pagado']}",
                  etiqueta: "Total pagado"),
            ),
            _line(),
            Expanded(
              child: _labelInformation(
                  contenido: "${results['n_pagos']}", etiqueta: "Pagos"),
            ),
          ],
        ),
        _containerCards(etiqueta: "HISTORIAL DE PAGOS", results: results)
      ],
    ));
  }

  Container _labelClient({
    String contenido: '',
  }) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Cliente: ",
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            "$contenido",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Container _bigCircle(
      {String value: "0.0",
      String etiqueta: '',
      double widthAndheight: 130.0,
      double fontSize: 25}) {
    return Container(
      margin: EdgeInsets.all(5.0),
      width: widthAndheight,
      height: widthAndheight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "$value",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            Text(
              "$etiqueta",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Container _mediumCircle({String value: "0.0", String etiqueta: ''}) {
    double fontSize = 20;
    if (value.toString().length > 7) {
      fontSize = 16;
    }
    return _bigCircle(
        value: value,
        etiqueta: etiqueta,
        widthAndheight: 90.0,
        fontSize: fontSize);
  }

  bool _isPar(int x) {
    return x % 2 == 0;
  }

  Container _labelDetail({String description: ""}) {
    //int pagos: 0, double value: 0.0, String plazo: ""}) {
    //String cadena = "";
    // if (_isPar(pagos)) {
    //   cadena = "$pagos pago(s) de $value \n Plazo: $plazo";
    // } else {
    //   cadena = "$pagos pago(s) de $value + un pago de $value \n Plazo: $plazo";
    // }
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(
        "$description",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, color: Colors.black54),
        maxLines: 3,
      ),
    );
  }

  Container _labelInformation({String contenido: '', String etiqueta: ''}) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$contenido",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
          Text(
            "$etiqueta",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      height: 50.0,
      width: 2.0,
      color: Colors.grey,
    );
  }

  Container _containerCards({String etiqueta: '', var results}) {
    for (var payment in results['payments']) {
      return Container(
          child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            Text(
              "\t $etiqueta",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ]),
          _tarjeta(
              date: "${payment['date']}",
              value: "${payment['total']}",
              state: "${payment['status']}"),
          Divider(),
        ],
      ));
    }
  }

  Slidable _tarjeta({String date, String value, String state}) {
    Color _color = Colors.green;
    String _state = "Pagado";
    if (state == "1") {
      _color = Colors.grey;
      _state = "Pendiente";
    } else if (state == "2") {
      _color = Colors.red;
      _state = "En mora";
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
                          "\$ $value",
                          style: TextStyle(
                              fontSize: 20,
                              color: _color,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$date", // .day}/${date.month}/${date.year}",
                          style: TextStyle(fontSize: 20, color: _color),
                        ),
                      ],
                    )
                  ],
                )),
                Expanded(
                  child: Text(
                    "$_state",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _color),
                  ),
                ),
              ],
            )),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Pagar',
            color: Colors.blue,
            icon: Icons.payment,
            onTap: () async {
              bool process = await _updatePayment(widget.id, context);
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
              bool process = await _updateToMora(-1, context);
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

              bool process = await _deleteCredit(widget.id, context);
              if(process){
                print("Se elimino el pago por: $reason");
              }
            },
          ),
          IconSlideAction(
            caption: 'Ver detalle',
            color: Colors.amber,
            icon: Icons.list,
            onTap: () async {
              bool process = await _showDetail(widget.id, context);
              if(process){
                print("Detalle de: ${widget.id}");
              }
            },
          ),
        ]);
  }
  Future<bool> _updatePayment(int status, context) async {

    _loader.show(msg : "Marcando...");
    //Responser res = await CreditProvider().updateToMora(status);
    //if(res.ok) {
    //  Scaffold.of(context).showSnackBar(customSnack("Actualizado con exito"));
    // } else {
    //   Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    //}
    _loader.hide();
    return true;

  }
  
  //Actualizar a mora
  Future<bool> _showDetail(int status, context) async {
    //int isOk = await Alert.confirm(context, title: "Marcar en Mora" ,content: "¿Está seguro que desea marcar como mora este pago?");
    //if(isOk == 1){
    //  return false;
    //}
    //if(status <= 0){
    //  Scaffold.of(context).showSnackBar(customSnack("No se ha podido cambiar el estado de este pago", type: 'err'));
    //  return false;
    //}

    _loader.show(msg : "Marcando...");
    //Responser res = await CreditProvider().updateToMora(status);
    //if(res.ok) {
    //  Scaffold.of(context).showSnackBar(customSnack("Actualizado con exito"));
    // } else {
    //   Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    //}
    _loader.hide();
    return true;
  }
  
  //Actualizar a mora
  Future<bool> _updateToMora(int status, context) async {
    int isOk = await Alert.confirm(context, title: "Marcar en Mora" ,content: "¿Está seguro que desea marcar como mora este pago?");
    if(isOk == 1){
      return false;
    }
    //if(status <= 0){
    //  Scaffold.of(context).showSnackBar(customSnack("No se ha podido cambiar el estado de este pago", type: 'err'));
    //  return false;
    //}

    _loader.show(msg : "Marcando...");
    //Responser res = await CreditProvider().updateToMora(status);
    //if(res.ok) {
    //  Scaffold.of(context).showSnackBar(customSnack("Actualizado con exito"));
    // } else {
    //   Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    //}
    _loader.hide();
    return true;
  }


  // Anular crédito
  Future<bool> _deleteCredit(creditId, context) async {
    int isOk = await Alert.confirm(context, title: "Anular Pago" ,content: "¿Está seguro que desea anular este pago?");
    if(isOk == 1){
      return false;
    }
    if(creditId <= 0){
      Scaffold.of(context).showSnackBar(customSnack("No se ha podido anular este pago", type: 'err'));
      return false;
    }

    await _displayDialog(context);
    // _loader.show(msg : "Anulando crédito");
    // Responser res = await CreditProvider().cancel(creditId);
    // if(res.ok) {
    //   Scaffold.of(context).showSnackBar(customSnack("Crédito procesao con exito"));
    // } else {
    //   Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    // }
    // _loader.hide();
    return true;
  }


  Future _displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingrese el motivo por el cual va a anular el pago'),
          content: TextField(              
            controller: _textEditingController,
            decoration: InputDecoration(hintText: "Motivo"),
            onChanged: (text){
              reason = text;
            },
          ),
          actions: <Widget>[
            new FlatButton(
              child: Text('Enviar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
}