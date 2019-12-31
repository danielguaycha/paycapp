import 'package:flutter/material.dart';

Widget errMessage({String msg: ''}) {
  bool _show = false;
  
  if(msg != null && msg.isNotEmpty)
    _show = true;

  return Visibility(
      visible: _show,
      child: Container(         
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: new BoxDecoration(
          color: Colors.red[100],
          border: Border(
            left: BorderSide(color: Colors.red, width: 3.0)
          ),
        ),
        child: Row(           
          children: <Widget>[      
            Container(
              child: Icon(Icons.error, color: Colors.red[900]),
              margin: EdgeInsets.only(right: 7),          
            ),
            
            Expanded(          
              child: Text("$msg", style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.w400)), 
            ),          
        ]
      )
    ),
  );
}

Widget textOrLoader({bool loader: false, String loaderText: 'Procesando...', String text: 'Button'}) {
  if(loader) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
            strokeWidth: 2.0,      
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),        
        SizedBox(width: 10),
        Text(loaderText),        
      ],
    );
  }
  return Text(text, style: TextStyle(color: Colors.white));
}

Widget customSnack(String message, {String type: 'ok'}) {
  SnackBar snack;
  switch(type.toLowerCase()){
    case 'ok':
      snack = SnackBar(content: Text(message),
        backgroundColor: Colors.green, elevation: 12, duration: Duration(seconds: 4));
      break;
    case 'err':
      snack = SnackBar(content: Text(message),
        backgroundColor: Colors.red, elevation: 12, duration: Duration(seconds: 5));
      break;
    default:
      snack = SnackBar(content: Text(message));
      break;
  }
  return snack;
}
