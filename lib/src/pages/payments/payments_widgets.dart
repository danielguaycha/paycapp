import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/maps/map_with_route.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart';
import 'list_payments_page.dart';

GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
String reason = "";
ProgressLoader _loader;

// Este metodo retorna un widget Slideable con toda la informacion necesaria para cobros
Widget slideableForPyments({
  String idPago,
  String date,
  String value,
  String state,
  String name,
  String surname,
  String address,
  String creditID,
  String refDetail,
  String refImage,
  String lat,
  String lon,
  String cobro,
  @required Function retry,
  @required context,
  @required scaffoldKey,
  @required bool showDetail,
}) {
  _loader = new ProgressLoader(context);
  _scaffoldKey = scaffoldKey;
  Color _color = Colors.black54;
  String _state = "Pendiente";
  if (state == "-1") {
    _color = Colors.red;
    _state = "En mora";
  } else if (state == "2") {
    _color = Colors.green;
    _state = "Pagado";
  }

  double fontWeit = 20.0;
  if ("$name - $surname".length > 25) fontWeit = 18.0;
  if ("$name - $surname".length > 30) fontWeit = 17.0;

  return Slidable(
    actionPane: SlidableDrawerActionPane(),
    actionExtentRatio: 0.20,
    child: Container(
        // padding: EdgeInsets.symmetric( horizontal: 10.0, vertical: 8),
        child: ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              !showDetail
                  ? Column(
                      children: <Widget>[
                        Text(
                          money(value),
                          style: TextStyle(
                              fontSize: 18,
                              color: _color,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$date",
                          style: TextStyle(fontSize: 15, color: _color),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "$name - $surname",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: fontWeit,
                              color: _color,
                              fontWeight: FontWeight.bold),
                        ),
                        // Text(
                        //   "$addres",
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(fontSize: fontWeit, color: _color),
                        // ),
                      ],
                    )
            ],
          )),
          !showDetail
              ? Column(
                  children: <Widget>[
                    Text(
                      "$_state",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _color),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      money(value),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _color),
                    ),
                    Text(
                      "$_state",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _color),
                    ),
                  ],
                ),
        ],
      ),
      onLongPress: showDetail
          ? () {
              _callModalBotonsheet(context,
                  textInfo: address,
                  urlImage: refImage,
                  refDetail: refDetail,
                  lat: lat,
                  lon: lon,
                  name: name,
                  surname: surname,
                  address: address,
                  status: int.parse(state),
                  idCredit: creditID,
                  cobro: cobro 
              );
            }
          : null,
    )),
    actions: <Widget>[
      _slidePagar(state, idPago, context, retry),
      _slideMora(state, idPago, context, retry),
    ],
    secondaryActions: showDetail
        ? twoElements(idPago, context, creditID, state)
        : oneElement(idPago, context, state),
  );
}

Widget _slideMora(String state, String idPago, context, Function retry) {
  return IconSlideAction(
    caption: 'Mora',
    color: Colors.red,
    icon: Icons.remove_circle_outline,
    onTap: () async {
      if (int.parse(state) == TYPE_MORA) {
        return null;
      }

      if (int.parse(state) == TYPE_PAGADO) {
        _scaffoldKey.currentState
            .showSnackBar(customSnack("Esta pago ya fue procesado", type: 'err'));
        return null;
      }

      String process = await updatePayment(
          int.parse(idPago), TYPE_MORA, context,
          title: "Marcar en Mora",
          content: "¿Está seguro que desea marcar como mora este pago?");
      if (process != null) {
        if (process == "OK") {
          _scaffoldKey.currentState
              .showSnackBar(customSnack("Marcado como mora"));
          retry();
        } else {
          _scaffoldKey.currentState
              .showSnackBar(customSnack(process, type: 'err'));
        }
      }
    },
  );
}

Widget _slidePagar(String state, String idPago, context, Function retry) {
  return IconSlideAction(
    caption: 'Pagar',
    color: Colors.green,
    icon: Icons.payment,
    onTap: () async {
      if (int.parse(state) == TYPE_PAGADO) {
        return null;
      }

      String process = await updatePayment(
          int.parse(idPago), TYPE_PAGADO, context,
          title: "Realizar pago",
          content: "¿Está seguro de realizar este pago?");
      if (process != null) {
        if (process == "OK") {
          _scaffoldKey.currentState
              .showSnackBar(customSnack("Pago confirmado"));
          retry();
        } else {
          _scaffoldKey.currentState
              .showSnackBar(customSnack(process, type: 'err'));
        }
      }
    },
  );
}

// En caso de encontrarse en la lista de pagos en un credito se llama a este widget para tener la opcion de anular
Widget _slideAnular(idPago, context, state) {
  return IconSlideAction(
    caption: 'Anular',
    color: Theme.of(context).primaryColor,
    icon: Icons.delete,
    onTap: () async {
      if (int.parse(state) == TYPE_MORA || int.parse(state) == TYPE_PENDIENTE) {
        _scaffoldKey.currentState.showSnackBar(
            customSnack("Solo se pueden anular pagos procesados", type: 'err'));
        return null;
      }

      String process =
          await cancelPaymentOnPayments(int.parse(idPago), context);
      if (process != null) {
        if (process == "OK") {
          _scaffoldKey.currentState
              .showSnackBar(customSnack("Pago anulado con exito"));
        } else {
          _scaffoldKey.currentState
              .showSnackBar(customSnack(process, type: 'err'));
        }
      }
    },
  );
}

Widget _slideVerDetalle(String creditID, context) {
  return IconSlideAction(
    caption: 'Ver detalle',
    color: Colors.amber,
    icon: Icons.list,
    onTap: () async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListPaymentsPage(id: int.parse(creditID))));
    },
  );
}

// Como puede existir uno o dos iconos se crea esta lista para el caso de necesitar un elemento
List<Widget> oneElement(idPago, context, state) {
  List<Widget> list = new List<Widget>();
  list.add(_slideAnular(idPago, context, state));
  return list;
}

// Como puede existir uno o dos iconos se crea esta lista para el caso de necesitar dos elementos
// Llamado al elemento de la lista anterior
List<Widget> twoElements(idPago, context, creditID, state) {
  List<Widget> list = new List<Widget>();
  list.add(_slideAnular(idPago, context, state));
  list.add(_slideVerDetalle(creditID, context));
  return list;
}

// Llamar al modalBotonSheet
_callModalBotonsheet(context,
    {String textInfo,
    String urlImage,
    String refDetail,
    String lat,
    String lon,
    String name,
    String surname,
    String address,
    int status,
    String cobro,
    String idCredit}) {
  showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.info),
              title: Text("Información"),
              onTap: () {
                Navigator.pop(context);
                _displayText(context, text: textInfo);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text("Ubicacion"),
              onTap: () {
                Navigator.pop(context);
                gotToMap(context, lat, lon, "$name $surname", address, status, cobro, idCredit);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Referencia"),
              onTap: () {
                Navigator.pop(context);
                _displayImage(context, url: urlImage, refDetail: refDetail);
              },
            ),
          ],
        );
      });
}



//Actualizar a mora
Future<String> updatePayment(int id, int status, context,
    {String title, String content}) async {
  _loader = new ProgressLoader(context);
  String _respuesta = "";

  int isOk = await Alert.confirm(context, title: title, content: content);
  if (isOk == 1) {
    return null;
  }
  _loader.show(msg: "Actualizando...");
  Responser res = await CreditProvider().updatePayment(id, status);
  if (res.ok) {
    // _scaffoldKey.currentState
    //     .showSnackBar(customSnack("Actualizado con exito"));
    _respuesta = "OK";
  } else {
    // print("ERROR: ${res.message}");
    // _scaffoldKey.currentState
    //     .showSnackBar(customSnack(res.message, type: 'err'));
    _respuesta = res.message;
  }
  _loader.hide();
  return _respuesta;
}

// Anular pago
Future<String> cancelPaymentOnPayments(creditId, context) async {
  String _response;
  int isOk = await Alert.confirm(context,
      title: "Anular Pago",
      content: "¿Está seguro que desea anular este pago?");
  if (isOk == 1) {
    return null;
  }
  if (creditId <= 0) {
    return "No se ha podido anular este pago";
  }

  await _displayDialog(context);
  _loader.show(msg: "Anulando crédito");
  Responser res = await CreditProvider().deletePayments(creditId, reason);
  if (res.ok) {
    _response = "OK";
  } else {
    _response = res.message;
  }
  _loader.hide();
  return _response;
}

Future _displayDialog(BuildContext context) async {
  reason = "";
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ingrese el motivo por el cual va a anular el pago'),
          content: TextField(
            decoration: InputDecoration(hintText: "Motivo"),
            onChanged: (text) {
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
      });
}

// Mostrar un Alert con la direccion del cliente
Future _displayText(BuildContext context, {@required String text}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text(
          'Dirección',
          textAlign: TextAlign.center,
        ),
        content: Text(text),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Mostrar un alert con la imagen y descripcion de referencia
Future _displayImage(BuildContext context,
    {@required String url, String refDetail}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Text(
          'Referencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[showImage(url), Text(refDetail)],
        ),
        actions: <Widget>[
          new FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

// Ir al mapa en base a la ubicacion de un pago
void gotToMap(
    context, String lat, String lon, String name, String address, int status, String cobro, String idCredit) {
  List<DataClient> _dataClient = new List<DataClient>();
  _dataClient.add(new DataClient(lat, lon, name, address, status: status, cobro: cobro, idCredit: int.parse(idCredit)));
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapRoutePage(cliente: _dataClient)));
}
