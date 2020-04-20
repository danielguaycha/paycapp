import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:paycapp/src/pages/user/change_password_page.dart';
import 'package:paycapp/src/plugins/http.dart';
import 'package:paycapp/src/utils/local_storage.dart';

import '../../config.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _prefs = LocalStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configuraciones")),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait ? _portraitView() : _landscapeView();
        }
      
      ),
    );
  }

  Widget _portraitView(){
    return Padding(
        padding: EdgeInsets.only(right: 10, left: 10, bottom: 10.0, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _bigCircle(),
            Divider(color: Colors.transparent),
            Container(
                child: Column(
              children: <Widget>[Text("Nombre Apellido"), Text("UserName")],
            )),
            Divider(color: Colors.transparent),
            _botton("Cambiar Contraseña", _changePassword),
            Divider(color: Colors.transparent),
            _botton("Cerrar Sesión", _logOut),
          ],
        ),
      );
  }

  Widget _landscapeView(){
    return SingleChildScrollView(
        // scrollDirection: Axis.horizontal,
        // scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(right: 10, left: 10, bottom: 10.0, top: 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  _bigCircle(),
                  Text("Nombre Apellido"),
                  Text("UserName")
                ],
              ),
            ),
            Divider(color: Colors.transparent),
            // Container(
            //     child: Column(
            //   children: <Widget>[],
            // )),
            // Divider(color: Colors.transparent),
            Expanded(
              child: Column(
                children: <Widget>[
                  _botton("Cambiar Contraseña", _changePassword),
                  Divider(color: Colors.transparent),
                  _botton("Cerrar Sesión", _logOut),
                ],
              ),
            ),          ],
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
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }

  Widget _botton(String text, Function callBack) {
    return SizedBox(      
      width: double.maxFinite,
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

  void _changePassword() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChangePassword()));
  }

  void _logOut() async {
    _prefs.token = null;
    var _client = HttpClient();
    _client.clearCachePrimary('/user');
    _client.clearCachePrimary("/route");
    Navigator.pushReplacementNamed(context, 'login');
  }
}
