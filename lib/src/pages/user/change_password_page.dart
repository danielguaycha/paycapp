import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/auth_provider.dart';
import '../../config.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

TextStyle badStyle = new TextStyle(
  color: Colors.red,
  decoration: TextDecoration.lineThrough,
);
TextStyle goodStyle = new TextStyle(
  color: Colors.green,
);

bool newpassValidate = false;
bool passLenght = false;
String oldPass = "";
String newPass = "";
class _ChangePasswordState extends State<ChangePassword> {
  @override
  void initState() { 
    newpassValidate = false;
    passLenght = false;
    newPass = "";
    oldPass = "";
    super.initState();    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configuraciones")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 10.0, top: 10),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _bigCircle(),
              Divider(),
              Container(
                  child: Column(
                children: <Widget>[
                  Text("Minimo 4 caracteres",
                      style: passLenght ? goodStyle : badStyle),
                  Text("Las nuevas claves coinciden",
                      style: newpassValidate ? goodStyle : badStyle),
                ],
              )),

              Divider(),
              _oldPpassword(),
              Divider(),
              _newPassword(),
              Divider(),
              _repeatNewPassword(),
              Divider(),
              _botton("Cambiar Contraseña", _back),
              
            ],
          ),
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
        color: newpassValidate && passLenght ? Colors.green : Colors.orange,
        border: Border.all(color: Colors.transparent),
      ),
      child: Center(
        child: Icon(
          Icons.lock,
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

  Widget _oldPpassword() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Clave actual',
      ),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        return "";
      },
      onChanged: (v) => oldPass = v,
    );
  }

  Widget _newPassword() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Clave nueva',
      ),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        return "";
      },
      onChanged: (v) {
        newPass = v;
        (v.length >= 4) ? passLenght = true : passLenght = false;
        _retry();
      },
    );
  }

  Widget _repeatNewPassword() {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Confirmar nueva clave',
      ),
      validator: (String value) {
        if (value.trim().isEmpty) {
          return 'Password is required';
        }
        return "";
      },
      onChanged: (v){
        print("$v == $newPass"); 
        (v == newPass) ? newpassValidate = true : newpassValidate = false;
        (v.length >=4) ? passLenght = true : passLenght = false;
        _retry();
      },
    );
  }
  void _retry(){
    setState(() {});
  }

  Future<bool> _back() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    
    Responser res = await AuthProvider().changePassword(oldPass, newPass);

    Navigator.pop(context);
  }
}
