import 'package:flutter/material.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/auth_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart'
    show errMessage, textOrLoader;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authProvider = new AuthProvider();
  final _formKey = GlobalKey<FormState>();

  String _user = '';
  String _password = '';

  String _msg = '';
  bool _loader = false;

  // logo
  final _logo = SizedBox(
    height: 110.0,
    child: Image.asset(
      "assets/payicon.png",
      fit: BoxFit.contain,
    ),
  );

  // username input
  _userInput() {
    return TextFormField(
      initialValue: _user,
      decoration: InputDecoration(
        hintText: "Usuario",
        suffixIcon: Icon(Icons.account_box),
      ),
      onSaved: (value) => _user = value,
      validator: (value) {
        if (value.trim() == '') {
          return 'Ingrese su nombre de usuario';
        }

        if (value.length < 3) {
          return 'Ingrese un nombre de usuario válido';
        }
        return null;
      },
    );
  }

  // password input
  _pwInput() {
    return TextFormField(
      obscureText: true,
      initialValue: '',
      decoration: InputDecoration(
        hintText: "Contraseña",
        suffixIcon: Icon(Icons.lock_outline),
      ),
      onSaved: (value) =>  _password = value,
      validator: (value) {
        if (value.trim() == '') {
          return 'Ingrese su contraseña';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: 45.0),
                  _logo,
                  errMessage(msg: _msg),
                  _userInput(),
                  SizedBox(height: 20.0),
                  _pwInput(),
                  SizedBox(height: 30.0),
                  _btnLogin(context)

                ],
              ),
            ),
          ),

      ),
    );
  }

  Widget _btnLogin(BuildContext context) {
    return MaterialButton(
        disabledColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        onPressed: _loader
            ? null
            : () {
                if (!_formKey.currentState.validate()) return;
                _formKey.currentState.save();
                _submitLogin(context);
                //Navigator.of(context).pushNamed(.tag);
              },
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        color: Theme.of(context).accentColor,
        child: textOrLoader(
            loader: _loader,
            loaderText: "Iniciando...",
            text: "Iniciar Sesión"),
      );
  }

  void _submitLogin(BuildContext context) async {
    setState(() {
      // reset Params
      _loader = true;
      _msg = '';
    });

    Responser res = await _authProvider.login(_user, _password);
    // invalid user or password -----------------------
    if (!res.ok) {
      setState(() {
        _msg = res.message;
      });
    }

    // Success Login ----------------------
    if(res.data != null && res.data['access_token']!=null) {
      Navigator.pushReplacementNamed(context, 'home');
    }



    setState(() {
      _loader = false;
    });
  }
}
