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
DataClient dataClient;
// Este metodo retorna un widget Slideable con toda la informacion necesaria para cobros
Widget slideableForPyments({
  @required DataClient dataCliente,

  // String idPago,
  // String date,
  // String value,
  // String state,
  // String name,
  // String surname,
  // String address,
  // String creditID,
  // String refDetail,
  // String refImage,
  // String lat,
  // String lon,
  // String cobro,

  @required Function retry,
  @required context,
  @required scaffoldKey,
  @required bool showDetail,
}) {
  dataClient = dataCliente;
  _loader = new ProgressLoader(context);
  _scaffoldKey = scaffoldKey;
  Color _color = Colors.black54;
  String _state = "Pendiente";
  if (dataClient.status == TYPE_MORA) {
    _color = Colors.red;
    _state = "En mora";
  } else if (dataClient.status == TYPE_PAGADO) {
    _color = Colors.green;
    _state = "Pagado";
  }

  double fontWeit = 20.0;
  if ("${dataClient.name}".length > 25) fontWeit = 18.0;
  if ("${dataClient.name}".length > 30) fontWeit = 17.0;

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
                          money(dataClient.totalPago),
                          style: TextStyle(
                              fontSize: 18,
                              color: _color,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${dataClient.date}",
                          style: TextStyle(fontSize: 15, color: _color),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${dataClient.name}",
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
                      money(dataClient.totalPago),
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
            // PhotoView(imageProvider: AssetImage('assets/payicon.png'));
              _callModalBotonsheet(context,
                  urlImage: dataClient.ref_img,
                  refDetail: dataClient.ref_detail,
                  lat: dataClient.lat,
                  lon: dataClient.lng,
                  name: dataClient.name,
                  address: dataClient.address,
                  status: dataClient.status,
                  idCredit: dataClient.idCredit.toString(),
                  cobro: dataClient.cobro,
                  idPayment: dataClient.idPayment);
            }
          : null,
    )),
    actions: <Widget>[
      _slidePagar(dataClient.status, dataClient.idPayment, context, retry),
      _slideMora(dataClient.status, dataClient.idPayment, context, retry),
    ],
    secondaryActions: showDetail
        ? twoElements(dataClient.idPayment, context, dataClient.idCredit,
            dataClient.status)
        : oneElement(dataClient.idPayment, context, dataClient.status),
  );
}

Widget _slideMora(int state, int idPago, context, Function retry) {
  return IconSlideAction(
    caption: 'Mora',
    color: Colors.red,
    icon: Icons.remove_circle_outline,
    onTap: () async {
      if (state == TYPE_MORA) {
        return null;
      }

      if (state == TYPE_PAGADO) {
        _scaffoldKey.currentState.showSnackBar(
            customSnack("Esta pago ya fue procesado", type: 'err'));
        return null;
      }

      String process = await updatePayment(idPago, TYPE_MORA, context,
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

Widget _slidePagar(int state, int idPago, context, Function retry) {
  return IconSlideAction(
    caption: 'Pagar',
    color: Colors.green,
    icon: Icons.payment,
    onTap: () async {
      if (state == TYPE_PAGADO) {
        return null;
      }

      String process = await updatePayment(idPago, TYPE_PAGADO, context,
          title: "Realizar pago",
          content: "¿Está seguro de realizar este pago?");
      if (process != null) {
        if (process == "OK") {
          print("OLD: ${dataClient.status}");
          _scaffoldKey.currentState
              .showSnackBar(customSnack("Pago confirmado"));
          dataClient.status = TYPE_PAGADO;
          print("NEW: ${dataClient.status}");
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
Widget _slideAnular(int idPago, context, int state) {
  return IconSlideAction(
    caption: 'Anular',
    color: Theme.of(context).primaryColor,
    icon: Icons.delete,
    onTap: () async {
      if (state == TYPE_MORA || state == TYPE_PENDIENTE) {
        _scaffoldKey.currentState.showSnackBar(
            customSnack("Solo se pueden anular pagos procesados", type: 'err'));
        return null;
      }

      String process = await cancelPaymentOnPayments(idPago, context);
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

Widget _slideVerDetalle(int creditID, context) {
  return IconSlideAction(
    caption: 'Ver detalle',
    color: Colors.amber,
    icon: Icons.list,
    onTap: () async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListPaymentsPage(id: creditID)));
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
List<Widget> twoElements(int idPago, context, int creditID, state) {
  List<Widget> list = new List<Widget>();
  list.add(_slideAnular(idPago, context, state));
  list.add(_slideVerDetalle(creditID, context));
  return list;
}

// Llamar al modalBotonSheet
_callModalBotonsheet(context,
    {String urlImage,
    String refDetail,
    String lat,
    String lon,
    String name,
    String address,
    int status,
    String cobro,
    String idCredit,
    int idPayment}) {
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
                _displayText(context, text: address);
              },
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text("Ubicacion"),
              onTap: () {
                Navigator.pop(context);
                gotToMap(context, lat, lon, "$name", address, status, cobro,
                    idCredit, idPayment);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text("Referencia"),
              onTap: () {
                Navigator.pop(context);
                // PhotoView(imageProvider: AssetImage('assets/payicon.png'));
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
        // contentPadding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        title: Column(children: <Widget>[
          Text(
          'Referencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(refDetail),
        ],),
        content:  
        Container(
          width: 100.0,
          height: 300.0,
          child: 
              showImage(dataClient.ref_img),
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
void gotToMap(context, String lat, String lon, String name, String address,
    int status, String cobro, String idCredit, int idPayment) {
  List<DataClient> _dataClient = new List<DataClient>();
  _dataClient.add(new DataClient(lat, lon, name, address,
      status: status,
      cobro: cobro,
      idCredit: int.parse(idCredit),
      idPayment: idPayment));
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapRoutePage(cliente: _dataClient)));
}
