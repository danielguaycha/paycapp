import 'package:flutter/material.dart';

class ProgressLoader {
  BuildContext _context;

  ProgressLoader(BuildContext context) {
    this._context = context;
  }

  void show({ String msg: 'Cargando...'}) {
    showDialog(
        context: _context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 15),
                Text(msg),
              ],
            ),
          );
        }
    );
  }

  void hide(){
    Navigator.of(_context).pop();
  }

}