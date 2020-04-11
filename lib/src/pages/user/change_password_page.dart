import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:paycapp/src/utils/local_storage.dart';

import '../../config.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configuraciones")),
      body: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Divider(),
                _bigCircle(),
                Divider(),
                Container(
                  child: Column(children: <Widget>[
                    Text("Nombre Apellido"),
                    Text("UserName")
                  ],)
                ),
                Divider(),
                Expanded(
                  child: Container()
                ),
                 _botton("Cambiar Contraseña", _back),
                Divider(),
                Expanded(
                  child: Container()
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Container _bigCircle() {
    return Container(
      margin: EdgeInsets.all(5.0),
      width: 130.0,
      height: 130.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors['accent'],
        border: Border.all(color: Colors.transparent),
      ),
      child: Center(
        child: Icon(Icons.lock, color: Colors.white, size: 100.0,),
      ),
    );
  }


  Widget _botton(String text, Function callBack) {
    return SizedBox(
      width: 300.0,
      child: RaisedButton(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          splashColor: colors['accent'],
          shape: StadiumBorder(),
          color: colors['primary'],
          onPressed: () {
            callBack();
          }),
    );
  }

  void _back() {
    Navigator.pop(context);
  }
}
