import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/models/updater_model.dart';
import 'package:paycapp/src/pages/user/change_password_page.dart';
import 'package:paycapp/src/plugins/http.dart';
import 'package:paycapp/src/providers/updater_provider.dart';
import 'package:paycapp/src/utils/local_storage.dart';

import '../../config.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _prefs = LocalStorage();
  String _version;

  @override
  void initState() {
    this._version = "";
    this._comprobateUpdates();
    super.initState();
  }

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
            SizedBox(height: 10),
            _updateBtns(),
            Divider(color: Colors.transparent),
            _botton("Cambiar Contraseña", _changePassword),
            Divider(color: Colors.transparent),
            _botton("Cerrar Sesión", _logOut),
            
          ],
        ),
      );
  }

  Widget _updateBtns() {
    if(_prefs.update) {
      return _botton("Actualizar $appName-${_version == '' ? '...' : _version}", (){});
    }
    else {
      return _botton("Comprobar Actualizaciones", _comprobateUpdates);
    }
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
                  SizedBox(height: 15),
                  _botton("Cambiar Contraseña", _changePassword),
                  Divider(color: Colors.transparent),
                  _botton("Cerrar", _logOut),
                  
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
      child: FlatButton(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.white24,
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

  void _comprobateUpdates() async{
      Responser res = await UpdaterProvider().comprobate();
      if(res.ok) {
        Updater u = Updater.fromMap(res.data);
        if(u.update == true) {
          _prefs.update = true;
          this._version = u.version;          
        } else {
          Alert.toast(context, "No hay actualizaciones disponibles", position: ToastPosition.center, duration: ToastDuration.long);
          _prefs.update = false;
        }
        setState(() {});
      }
  }
}
