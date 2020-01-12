import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/credit/show_credit_page.dart';
import 'package:paycapp/src/pages/map_only_page.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart'
    show renderError, loader, renderNotFoundData;

import '../map_only_location_page.dart';

//import 'package:backdrop/backdrop.dart';
 import 'package:paycapp/src/config.dart'
     show plazos, cobros;


class ListCreditPage extends StatefulWidget {
  @override
  _ListCreditPageState createState() => _ListCreditPageState();
}

class _ListCreditPageState extends State<ListCreditPage> {
  ProgressLoader _loader;
  @override
  Widget build(BuildContext context) {
    _loader = new ProgressLoader(context);
    return Scaffold(
    
    // BackdropScaffold(
    //   title: _title(),
    //   backLayer: _backLayer(),
    //   frontLayerBorderRadius: BorderRadius.only(topLeft: Radius.circular(0.0), topRight: Radius.circular(0.0)),
    //   frontLayer: Text("text"),
    //   iconPosition: BackdropIconPosition.action,

      appBar: AppBar(
        title: Text("Créditos"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: null,
          )
          
        ],),
      body: _creditList(),
       floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, 'credit_add');
        },
        tooltip: 'Nuevo Crédito',
      ),
    );
  }


  _creditList() {
    return FutureBuilder(
      //lista del servidor
      future: CreditProvider().list(),
      
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return renderError(snapshot.error, _retry);
        }

        if (!snapshot.hasData) return loader(text: "Cargando créditos...");

        var results = snapshot.data.data;

        if (results != null && results.length <= 0) {
          return renderNotFoundData("No tienes rutas asignadas aún");
        }

        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            var credit = (results[index]);
            //Credit credito = (results[index]);
            return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.20,
                child: ListTile(                  
                  dense: true,
                  leading: Icon(FontAwesomeIcons.moneyBillAlt,
                      size: 25, color: Theme.of(context).accentColor),
                  trailing: Icon(Icons.keyboard_arrow_right,
                      color: Theme.of(context).primaryColor),
                  title: Text(
                    "${credit['name']} ${credit['surname']}".toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                      "Plazo: ${credit['plazo']} | Total: \$${double.parse(credit['total']).toStringAsFixed(2)}"),
                  onTap: () {
                    //Credit _credit = (new Credit()) credit;
                    //Navigator.pushNamed(context, 'showcredit', arguments: _credit);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListPaymentsPage(id: credit['id'])) );
                  },
                ),
                actions: <Widget>[
                  IconSlideAction(
                    caption: 'Ubicacion',
                    color: Colors.green,
                    icon: Icons.map,
                    onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MapOnlyLocationPage(latitud: credit['lat'], longitud: credit['lon'], name: "${credit['name']}  ${credit['surname']}", addres: "${credit['address']} - ${credit['ruta']}", ) ));
                    },
                  ),
                ],
                secondaryActions: <Widget>[                 
                  IconSlideAction(
                    caption: 'Anular',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () async {
                      bool process = await _deleteCredit(credit['id'], context);
                      if(process){
                        results.removeAt(index);
                        setState(() {});
                      }
                    },
                  ),
                ]);
          },
        );
      },
    );
  }

  // Anular crédito
  Future<bool> _deleteCredit(creditId, context) async {
    int isOk = await Alert.confirm(context, title: "Anular Crédito" ,content: "¿Está seguro que desea anular este crédito?");
    if(isOk == 1){
      return false;
    }
    if(creditId <= 0){
      Scaffold.of(context).showSnackBar(customSnack("No se ha podido anular este crédito", type: 'err'));
      return false;
    }
    _loader.show(msg : "Anulando crédito");
    Responser res = await CreditProvider().cancel(creditId);
    if(res.ok) {
      Scaffold.of(context).showSnackBar(customSnack("Crédito procesao con exito"));
    } else {
      Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    }
    _loader.hide();
    return true;
  }

  _retry() {
    setState(() {});
  }

  // Codigo para el nuevo AppBar con filtro
  
  static Map<String, String> rutas = {'Ruta 1': 'Ruta 1', 'Ruta 2': 'Ruta 2'};

  String _valorPlazo = "SEMANAL";
  String _valorCobro = "SEMANAL";
  String _valorRuta = "Ruta 1";

  Widget _title() {
    return Row(
      children: <Widget>[
        Text("Titulo"),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              )
            ],
          ),
        )
      ],
    );
  }


  Widget _backLayer() {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Padding(
        padding: EdgeInsets.only(right: 10, left: 10, bottom: 15, top: 10),
        child: Column(
          children: <Widget>[
            _comboPlazo(context),
            _comboCobros(context),
            _comboRutas(context),
          ],
        ),
      ),
    );
  }
  
  // Plazo
  Widget _comboPlazo(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: DropdownButtonFormField(
        value: _valorPlazo,
        items: listItems(plazos),
        decoration: InputDecoration(
          labelText: "Filtrar por Plazos",
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          fillColor: Colors.white,
          icon: Icon(
            Icons.timer,
            color: Colors.white,
          ),
        ),
        onSaved: (v) {},
        validator: (v) {
          if (v == null || v == '') return 'Selecciona un plazo';
          return null;
        },
        onChanged: (opt) {
          setState(() {
            _valorPlazo = opt;
          });
        },
      ),
    );
  }

  // Cobros
  Widget _comboCobros(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: DropdownButtonFormField(
        value: _valorCobro,
        items: listItems(cobros),
        decoration: InputDecoration(
          labelText: "Filtrar por Cobros",
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          fillColor: Colors.white,
          icon: Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
        ),
        onSaved: (v) {},
        validator: (v) {
          if (v == null || v == '') return 'Selecciona un plazo';
          return null;
        },
        onChanged: (opt) {
          setState(() {
            _valorCobro = opt;
          });
        },
      ),
    );
  }

  // Rutas
  Widget _comboRutas(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: DropdownButtonFormField(
        value: _valorRuta,
        items: listItems(rutas),
        decoration: InputDecoration(
          labelText: "Filtrar por Rutas",
          labelStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          fillColor: Colors.white,
          icon: Icon(
            Icons.map,
            color: Colors.white,
          ),
        ),
        onSaved: (v) {},
        validator: (v) {
          if (v == null || v == '') return 'Selecciona un plazo';
          return null;
        },
        onChanged: (opt) {
          setState(() {
            _valorRuta = opt;
          });
        },
      ),
    );
  }

  // Render Lists
  List<DropdownMenuItem<dynamic>> listItems(Map<dynamic, String> map) {
    List<DropdownMenuItem<dynamic>> lista = new List();
    map.forEach((k, v) {
      lista
        ..add(DropdownMenuItem(
          child: Text(
            '$v',
            style: TextStyle(color: Colors.black),
          ),
          value: k,
        ));
    });
    return lista;
  }


}
