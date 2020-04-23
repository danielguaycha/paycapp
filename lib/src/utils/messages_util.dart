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

Widget customSnack(String message, {String type: 'ok', SnackBarAction action, int seconds = 4}) {
  SnackBar snack;
  switch(type.toLowerCase()){
    case 'ok':
      snack = SnackBar(content: Text(message), action: action,
        backgroundColor: Colors.green, elevation: 12, duration: Duration(seconds: 3));
      break;
    case 'err':
      snack = SnackBar(content: Text(message),action: action,
        backgroundColor: Colors.red, elevation: 12, duration: Duration(seconds: seconds));
      break;
    default:
      snack = SnackBar(content: Text(message), action: action);
      break;
  }
  return snack;
}

