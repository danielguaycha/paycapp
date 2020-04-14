import 'package:flutter/material.dart';
import 'package:paycapp/src/utils/utils.dart';

class ShowExpensePage extends StatefulWidget {
  var expenseValue;
  ShowExpensePage({Key key, @required this.expenseValue}) : super(key: key);

  @override
  _ShowExpensePageState createState() => _ShowExpensePageState();
}

class _ShowExpensePageState extends State<ShowExpensePage> {
  bool _loadImagen = false;
  String _imagen; 
  @override
  Widget build(BuildContext context) {
    _imagen = widget.expenseValue["image"].toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Gasto'),
      ),
      body: SingleChildScrollView(
        child: _cardBasicData(context),
      ),
    );
  }

// Tarjeta
  _cardBasicData(context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Padding(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 2),
              _field(text: widget.expenseValue["date"], labeltext: 'Fecha', icon: Icons.calendar_today),
              SizedBox(height: 2),
              _field(text: widget.expenseValue["category"], labeltext: 'Categoria', icon: Icons.category),
              SizedBox(height: 2),
              _field(text: money(widget.expenseValue["monto"]), labeltext: 'Monto', icon: Icons.monetization_on),
              SizedBox(height: 2),
              _field(text: widget.expenseValue["description"], labeltext: 'Descripcion', icon: Icons.comment),
              SizedBox(height: 2),
              _field(text: widget.expenseValue["name"].toString().toUpperCase(), labeltext: 'Nombre', icon: Icons.person),
              SizedBox(height: 2),
              _imagen == "null" ? Container() : _photosBtn(),
              _loadImagen ? showImage(widget.expenseValue["image"].toString()) : Divider(),
            ],
          ),
        ));
  }

  Widget _field({text, labeltext, icon}) {
    return TextFormField(
      autofocus: true,
      readOnly: true,
      enableInteractiveSelection: false,
      initialValue: text,
      decoration: InputDecoration(
        labelText: labeltext,
        icon: Icon(icon),
      ),
    );
  }

  // Botones para imagenes 
  _photosBtn({String select: 'Ver Imagen'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.image, color: Colors.black38),
                label: Text(select, style: TextStyle(color: Colors.black45)),
                onPressed: () {
                  _loadImagen = true;
                  setState(() {                    
                  });
            },
              ),
            ],
    );
  }



}