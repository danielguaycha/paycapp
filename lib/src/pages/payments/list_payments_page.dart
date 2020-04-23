import 'package:flutter/material.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';

import 'package:paycapp/src/pages/payments/payments_widgets.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/utils.dart';

class ListPaymentsPage extends StatefulWidget {
  final int id;

  ListPaymentsPage({Key key, @required this.id}) : super(key: key);

  @override
  _ListPaymentsPageState createState() => _ListPaymentsPageState();
}

// Codigo extra
Icon iconoPanel = new Icon(Icons.arrow_upward);
final _scaffoldKey = GlobalKey<ScaffoldState>();
// Fin codigo extra

class _ListPaymentsPageState extends State<ListPaymentsPage> {
  // ProgressLoader _loader;
  // TextEditingController _textEditingController = new TextEditingController();
  String reason = "";

  @override
  Widget build(BuildContext context) {
    // _loader = new ProgressLoader(context);

    return Scaffold(
        key: _scaffoldKey,
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
    return Column(
      children: <Widget>[
        _labelClient(
            contenido:
                "${results['name']} ${results['surname']}".toUpperCase()),
        Row(
          children: <Widget>[
            Expanded(
              child: _mediumCircle(
                  value: money(results['monto']), etiqueta: "Prestamo"),
            ),
            Expanded(
              child: _bigCircle(
                  value: money(results['total']), etiqueta: "Total a pagar"),
            ),
            Expanded(
              child: _mediumCircle(
                  value: "${results['utilidad']} %", etiqueta: "Interés"),
            ),
          ],
        ),
        Center(
          child: _labelDetail(description: "${results['description']}"),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: _labelInformation(
                  contenido: money(results['total_pagado']),
                  etiqueta: "Total pagado"),
            ),
            _line(),
            Expanded(
              child: _labelInformation(
                  contenido: "${results['n_pagos']}", etiqueta: "Pagos"),
            ),
          ],
        ),
        Expanded(
            child: _containerCards(
                etiqueta: "HISTORIAL DE PAGOS", results: results))
      ],
    );
  }

  Container _labelClient({
    String contenido: '',
  }) {
    double fontSize = 16.0;
    if (contenido.length > 25) {
      fontSize = 17.0;
    }
    if (contenido.length > 30) {
      fontSize = 15.0;
    }

    return Container(
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Cliente: ",
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black54),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "$contenido",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: fontSize, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Container _bigCircle(
      {String value: "0.0",
      String etiqueta: '',
      double widthAndheight: 120.0,
      double fontSize: 22}) {
    return Container(
      width: widthAndheight,
      height: widthAndheight,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white54,
        border: Border.all(color: Colors.black26),
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
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Container _mediumCircle({String value: "0.0", String etiqueta: ''}) {
    double fontSize = 16;
    if (value.toString().length > 7) {
      fontSize = 16;
    }
    return _bigCircle(
        value: value,
        etiqueta: etiqueta,
        widthAndheight: 95.0,
        fontSize: fontSize);
  }

  bool _isPar(int x) {
    return x % 2 == 0;
  }

  Container _labelDetail({String description: ""}) {
    return Container(
      padding: EdgeInsets.all(2.0),
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        "$description",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
        maxLines: 3,
      ),
    );
  }

  Container _labelInformation({String contenido: '', String etiqueta: ''}) {
    return Container(
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$contenido",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
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
      height: 30.0,
      width: 1.5,
      color: Colors.black12,
    );
  }

  Widget _containerCards({String etiqueta: '', var results}) {
    return Container(
        child: Column(
      children: <Widget>[
        Divider(
          height: 1,
        ),
        Expanded(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: results['payments'].length,
              itemBuilder: (context, index) {
                var payment = results['payments'][index];

                return slideableForPyments(
                  dataCliente: new DataClient("", "", "", "",
                      idPayment: payment['id'],
                      date: payment['date'].toString(),
                      totalPago: payment['total'].toString(),
                      status: payment['status'],
                      numeroPago: index+1),
                  retry: _retry,
                  context: context,
                  scaffoldKey: _scaffoldKey,
                  showDetail: false,
                );
              }),

          //   return _tarjeta(
          //       id_pago: "${payment['id']}",
          //       date: "${payment['date']}",
          //       value: "${payment['total']}",
          //       state: "${payment['status']}");
          // }),
        ),
      ],
    ));
  }

  _retry() {
    setState(() {});
  }

  // Slidable _tarjeta({String id_pago, String date, String value, String state}) {
  //   Color _color = Colors.grey;
  //   String _state = "Pendiente";
  //   if (state == "-1") {
  //     _color = Colors.red;
  //     _state = "En mora";
  //   } else if (state == "2") {
  //     _color = Colors.green;
  //     _state = "Pagado";
  //   }

  //   return Slidable(
  //       actionPane: SlidableDrawerActionPane(),
  //       actionExtentRatio: 0.20,
  //       child: Container(
  //           padding: EdgeInsets.all(10.0),
  //           child: Row(
  //             children: <Widget>[
  //               Expanded(
  //                   child: Row(
  //                 children: <Widget>[
  //                   Column(
  //                     children: <Widget>[
  //                       Text(
  //                         money(value),
  //                         style: TextStyle(
  //                             fontSize: 20,
  //                             color: _color,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                       Text(
  //                         "$date",
  //                         style: TextStyle(fontSize: 20, color: _color),
  //                       ),
  //                     ],
  //                   )
  //                 ],
  //               )),
  //               Expanded(
  //                 child: Text(
  //                   "$_state",
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.bold,
  //                       color: _color),
  //                 ),
  //               ),
  //             ],
  //           )),
  //       actions: <Widget>[
  //         IconSlideAction(
  //           caption: 'Pagar',
  //           color: Colors.blue,
  //           icon: Icons.payment,
  //           onTap: () async {
  //             // 2 sginfica que esta pagado
  //             bool process = await _updatePayment(int.parse(id_pago) , 2, context, title: "Realizar pago", content: "¿Está seguro de realizar este pago?");
  //             if(process){
  //               print("Se pago");
  //               setState(() {});
  //             }},
  //         ),
  //         IconSlideAction(
  //           caption: 'Marcar \ncomo mora',
  //           color: Colors.red,
  //           icon: Icons.remove_circle_outline,
  //           onTap: () async {
  //             // -1 sginfica que estara en mora
  //             bool process = await _updatePayment(int.parse(id_pago) , -1, context, title: "Marcar en Mora", content: "¿Está seguro que desea marcar como mora este pago?");
  //             if(process){
  //               setState(() {
  //               });
  //             }
  //           },
  //         ),
  //       ],
  //       secondaryActions: <Widget>[
  //         IconSlideAction(
  //           caption: 'Anular',
  //           color: Colors.black38,
  //           icon: Icons.delete,
  //           onTap: () async {
  //             bool process = await _deleteCredit(int.parse(id_pago), context);
  //             // if (process) {
  //             //   print("Se elimino el pago por: $reason");
  //             //   reason = "";
  //             // }
  //           },
  //         ),
  //         IconSlideAction(
  //           caption: 'Ver detalle',
  //           color: Colors.amber,
  //           icon: Icons.list,
  //           onTap: () async {
  //             // bool process = await _showDetail(widget.id, context);
  //             // if (process) {
  //             //   print("Detalle de: ${widget.id}");
  //             // }
  //           },
  //         ),
  //       ]);
  // }

  // //Actualizar a mora
  // Future<bool> _updatePayment(int id, int status, context, {String title, String content}) async {
  //   int isOk = await Alert.confirm(context,
  //       title: title,
  //       content: content);
  //   if (isOk == 1) {
  //     return false;
  //   }
  //   _loader.show(msg: "Actualizando...");
  //   Responser res = await CreditProvider().updatePayment(id, status);
  //   if(res.ok) {
  //     _scaffoldKey.currentState
  //         .showSnackBar(customSnack("Actualizado con exito"));
  //   } else {
  //     print("ERROR: ${res.message}");
  //     _scaffoldKey.currentState
  //         .showSnackBar(customSnack(res.message, type: 'err'));
  //   }
  //   _loader.hide();
  //   return true;
  // }

  // // Anular crédito
  // Future<bool> _deleteCredit(creditId, context) async {
  //   int isOk = await Alert.confirm(context,
  //       title: "Anular Pago",
  //       content: "¿Está seguro que desea anular este pago?");
  //   if (isOk == 1) {
  //     return false;
  //   }
  //   if (creditId <= 0) {
  //     _scaffoldKey.currentState
  //         .showSnackBar(customSnack("No se ha podido anular este pago", type: 'err'));
  //     return false;
  //   }

  //   await _displayDialog(context);
  //   _loader.show(msg : "Anulando crédito");
  //   Responser res = await CreditProvider().deletePayments(creditId, reason);
  //   if(res.ok) {
  //     _scaffoldKey.currentState.showSnackBar(customSnack("Pago anulado con exito"));
  //   } else {
  //     _scaffoldKey.currentState.showSnackBar(customSnack(res.message, type: 'err'));
  //   }
  //   _loader.hide();
  //   return true;
  // }

  // Future _displayDialog(BuildContext context) async {
  //   _textEditingController.text = "";
  //   reason = "";
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text('Ingrese el motivo por el cual va a anular el pago'),
  //           content: TextField(
  //             controller: _textEditingController,
  //             decoration: InputDecoration(hintText: "Motivo"),
  //             onChanged: (text) {
  //               reason = text;
  //             },
  //           ),
  //           actions: <Widget>[
  //             new FlatButton(
  //               child: Text('Enviar'),
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //               },
  //             )
  //           ],
  //         );
  //       }
  //   );
  // }
}
