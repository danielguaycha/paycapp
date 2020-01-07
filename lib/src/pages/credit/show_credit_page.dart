import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/credit_model.dart';

class ShowCreditPage extends StatefulWidget {
  final int id;
  final Credit credit = null;
  //ShowCreditPage({Key key, @required this.id, Credit credit}) : super(key: key);
  ShowCreditPage({Key key, @required this.id}) : super(key: key);

  @override
  _ShowCreditPageState createState() => _ShowCreditPageState();
}

class _ShowCreditPageState extends State<ShowCreditPage> {
  bool _visible = false;
  double _width = 50.0;
  double _height = 50.0;

  @override
  Widget build(BuildContext context) {
  final Credit credito = ModalRoute.of(context).settings.arguments;
  print("XXXXXX");
  print(credito);
  print("XXXXXX");

    return Scaffold(
      appBar: AppBar(
        title: Text('\$ '),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _caja(contenido: "500", etiqueta: "Total"),
              ),
              Expanded(
                child: _caja(contenido: "10%", etiqueta: "Utilidad"),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _caja(contenido: "50", etiqueta: "Diarios"),
              ),
              Expanded(
                child: _caja(contenido: "15", etiqueta: "Pagos"),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _tarjetaUbicacion(
                    contenido: "Machala - 25 de Junio y Sucre"),
              ),
            ],
          ),
          FloatingActionButton.extended(
            backgroundColor: Colors.orangeAccent,
            label: Text("Prenda"),
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              setState(() {
                //Cambiar alto y ancho
                if (_visible) {
                  _width = 100.0;
                  _height = 100.0;
                  _visible = !_visible;
                } else {
                  _width = 0.0;
                  _height = 0.0;
                  _visible = !_visible;
                }
              });
            },
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: _tarjetaPrenda(width: _width, height: _height),
              )
            ],
          )
        ],
      ),
    );
  }

  AnimatedContainer _tarjetaPrenda(
      {@required double width,
      @required double height,
      String contenido: '',
      String etiqueta: '',
      String prenda: ''}) {
    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.decelerate,
        width: width,
        height: height,
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.orange,
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(1.0, 1.0))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: <Widget>[
                //Text( "Prenda", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                Center(
                  child:FadeInImage(

                      fadeInCurve: Curves.decelerate,
                      fadeOutCurve: Curves.decelerate,
                      fadeInDuration: Duration(milliseconds: 500),
                      width: width-10,
                      height: height-20,
                      placeholder: AssetImage('assets/jar_loading.gif'),
                      image:  NetworkImage('https://picsum.photos/id/1/100/100/?image=1'),
                    ),
                  ),                
              ],
            )));
  }

  Container _tarjetaUbicacion({String contenido: '', String etiqueta: ''}) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.orange,
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(1.0, 1.0))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "UBICACION",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$contenido",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  "$etiqueta",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                _btn(context, text: "Como llegar?", icon: FontAwesomeIcons.map,
                    click: () {
                  Navigator.pushNamed(context, 'map',
                      arguments: [-3.328816, -79.812166, "Nombre Apellido"]);
                })
              ],
            )));
  }

  Container _caja({String contenido: '', String etiqueta: ''}) {
    return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.orange,
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: Offset(1.0, 1.0))
            ]),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  "$contenido",
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  "$etiqueta",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            )));
  }

  RaisedButton _btn(BuildContext context,
      {String text: '',
      IconData icon: FontAwesomeIcons.icons,
      Color color: Colors.orange,
      @required void Function() click}) {
    return RaisedButton(
      elevation: 1,
      color: Colors.white,
      splashColor: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color),
          SizedBox(height: 10),
          Text(
            "$text",
            style:
                TextStyle(color: Colors.black45, fontWeight: FontWeight.w400),
          )
        ],
      ),
      onPressed: click,
    );
  }
}
