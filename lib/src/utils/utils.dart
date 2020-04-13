import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/config.dart' show urlApi;
import 'package:paycapp/src/config.dart' show debug;

// Loader Component
Widget loader({String text = 'Cargando...'}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text(text)
      ],
    ),
  );
}

// Render Lists
List<DropdownMenuItem<dynamic>> listItems(Map<dynamic, String> map) {
  List<DropdownMenuItem<dynamic>> lista = new List();
  map.forEach((k, v) {
    lista
      ..add(DropdownMenuItem(
        child: Text('$v'),
        value: k,
      ));
  });
  return lista;
}

List<DropdownMenuItem<dynamic>> listItemsNormal(
    List<dynamic> map, String concat) {
  List<DropdownMenuItem<dynamic>> lista = new List();
  map.forEach((v) {
    lista
      ..add(DropdownMenuItem(
        child: Text('$v $concat'),
        value: v,
      ));
  });
  return lista;
}

// Process Error
Map<String, dynamic> processError(error) {
  if (error is DioError) {
    DioError e = error;
    if (debug) {
      debugPrint(e.message);
    }
    if (e.response != null && e.response.data != null) {
      String msg = '';
      if (e.response.data['message'] != null &&
          e.response.data['errors'] == null)
        msg = e.response.data['message'];
      else if (e.response.data['error'] != null)
        msg = e.response.data['error'];
      else if (e.response.data['errors'] != null) {
        List<dynamic> errs = e.response.data['errors'];
        errs.forEach((f) {
          if (f.length > 0) {
            String err = (f[0]).toString();
            msg += err + ", ";
          }
        });
        msg += "--";
        msg = msg.replaceAll(", --", "");
      } else {
        msg = 'Error desconocido en la respuesta, contacte a soporte #1';
      }
      return {'ok': false, 'message': msg};
    } else {
      if (e.type == DioErrorType.DEFAULT) {
        print("ERROR: $error ");
        return {
          'ok': false,
          'message': "No se pudo comunicar con el servidor #2"
        };
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        return {
          'ok': false,
          'message': "El servidor no responde, contacte con soporte #3"
        };
      }
      return {
        'ok': false,
        'message': "Error desconocido con el servidor, contacte con soporte! #4"
      };
    }
  }
  return {'ok': false, 'message': 'Error desconocido, contacte con soporte #5'};
}

// Render Errors
Widget renderError(error, Function callback) {
  print(error);
  if (error is DioError) {
    DioError e = error;

    if (debug) {
      debugPrint(e.message);
    }

    if (e.response != null && e.response.data != null) {
      final msg = e.response.data['error'];
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(FontAwesomeIcons.exclamation),
          SizedBox(height: 20),
          Text(msg == null
              ? 'Error desconocido, contacte con el administrador'
              : msg)
        ],
      ));
    } else {
      if (e.type == DioErrorType.DEFAULT) {
        return _defaultErrorContainer(
            callback: callback,
            msg: "No se pudo comunicar con el servidor",
            icon: FontAwesomeIcons.wifi);
      }
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        return _defaultErrorContainer(
            callback: callback,
            msg: "El servidor no responde, contacte con soporte",
            icon: FontAwesomeIcons.question);
      }
      return Center(
          child:
              Text("Error desconocido con el servidor, contacte con soporte!"));
    }
  } else {
    if (debug) {
      debugPrint(error.toString());
    }
    return Center(child: Text("Error desconocido, contacte con soporte!"));
  }
}

Widget renderNotFoundData(String msg) {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(FontAwesomeIcons.searchengin, size: 60, color: Colors.blueGrey),
      SizedBox(height: 15),
      Text(msg,
          style:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
    ],
  ));
}

Widget _defaultErrorContainer(
    {Function callback, String msg, IconData icon: FontAwesomeIcons.dizzy}) {
  return Center(
      child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Icon(icon, size: 60, color: Colors.blueGrey),
      SizedBox(height: 15),
      Text(msg,
          style:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Text(
          "Revise su conexión a internet, sus datos móviles, su intensidad de señal",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black38, fontSize: 14),
        ),
      ),
      SizedBox(height: 10),
      (callback != null)
          ? MaterialButton(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: Border.all(width: 2.0, color: Colors.blueGrey[600]),
              textColor: Colors.blueGrey[600],
              elevation: 2,
              child: Text("Reintentar"),
              onPressed: () {
                callback();
              },
            )
          : Center()
    ],
  ));
}

// Validation Functions
Future<bool> checkConn() async {
  final connectivityResult = await InternetAddress.lookup(urlApi);
  if (connectivityResult.isNotEmpty && connectivityResult != null) {
    return true;
  } else {
    return false;
  }
}

String getImagen(String imageName) {
  return "$urlApi/image/$imageName";
}

String money(value) {
  String text = "0.0";
  if (value is double) {
    text = "\$ ${(value).toStringAsFixed(2)}";
  }

  if (value is String) {
    if (isNumeric(value)) {
      text = "\$ ${double.parse(value).toStringAsFixed(2)}";
    } else {
      text = "\$ $value";
    }
  }

  return text;
}

const List<String> choicesForPyments = <String>[
  "diario",
  "semanal",
  "quincenal",
  "mensual",
];

String dateTimetoString(DateTime currentTime) {
  return "${currentTime.year}-${currentTime.month}-${currentTime.day}";
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}
