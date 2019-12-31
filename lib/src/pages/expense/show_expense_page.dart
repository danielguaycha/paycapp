import 'package:flutter/material.dart';

//Variables
String _fecha = "";

class ShowExpensePage extends StatefulWidget {
  ShowExpensePage({Key key}) : super(key: key);

  @override
  _ShowExpensePageState createState() => _ShowExpensePageState();
}

class _ShowExpensePageState extends State<ShowExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gastos"),
        actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              await _selecionarFecha(context);
              print("Fecha: $_fecha");
            },
          ),
        ],
      ),
      floatingActionButton: _addExpense(),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _textMonth(contenido: "Diciembre"),
                ),
                Expanded(
                    child: _textCantidad(contenido: "\$ 100000"),
                ),
              ],
            ),
            Divider(),
            Column(
              children: _lista(),
            )
          ],
        ),
      ),
    );
  }

  FloatingActionButton _addExpense() {
    return FloatingActionButton(
      foregroundColor: Colors.white,
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.pushNamed(context, 'expense_add');
      },
    );
  }

  Container _textCantidad({String contenido: ''}){
    return _textMonth(contenido: contenido, color: Colors.red, textAlign: TextAlign.right);
  }

  Container _textMonth(
      {String contenido: '',
      Color color: Colors.black,
      TextAlign textAlign: TextAlign.left}) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(
        "$contenido",
        textAlign: textAlign,
        style:
            TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Container _tarjeta({DateTime date, String category, double value}) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey,
              blurRadius: 0.5,
              spreadRadius: 0.5,
              offset: Offset(0.0, 0.0))
        ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Row(
                  children: <Widget>[
                    Text(
                      "${date.day}",
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                    Divider(
                      indent: 3.0,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "${date.year} - ${date.month}",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$category",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ],
                )),
                Expanded(
                  child: Text(
                    "\$ $value",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ],
            )));
  }

  List<Widget> _lista() {
    List<Widget> list = new List<Widget>();
    //Lista para cargar cada tarjeta con su informacion correspondiente
    for (int i = 0; i < 2; i++) {
      list.add(_tarjeta(
          date: new DateTime.now(), category: "Gasolina", value: 1000.0 + i));
    }
    return list;
  }

  _selecionarFecha(BuildContext context) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2025),
      locale: Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fecha = picked.year.toString() +
            "-" +
            picked.month.toString() +
            "-" +
            picked.day.toString();
      });
    }
  }

}
