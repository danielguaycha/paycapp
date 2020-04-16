import 'package:backdrop/backdrop.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart'
    show loader, money, renderError, renderNotFoundData;
import 'package:paycapp/src/config.dart' show colors;
import '../map_only_location_page.dart';
import '../map_with_route.dart';

// List<LatLng> _listLocations = new List<LatLng>();
// List<String> _listname = new List<String>();
List<ClientCredit> _listClients = new List<ClientCredit>();
class ListCreditPage extends StatefulWidget {
  @override
  _ListCreditPageState createState() => _ListCreditPageState();
}

class _ListCreditPageState extends State<ListCreditPage> with SingleTickerProviderStateMixin{

  TextEditingController _textEditingController = new TextEditingController();
  String _reason = "";

  ProgressLoader _loader;
  @override
  Widget build(BuildContext context) {
    double heightDevice = MediaQuery.of(context).size.height;
 
    _loader = new ProgressLoader(context);

    //CreditProvider().getlist();

    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //     label: Text("Ver en mapa", style: TextStyle(color: Colors.white),),
      //     icon: Icon(Icons.location_on, color: Colors.white,),
      //     onPressed: () {
      //       if(_listClients.length <= 0 ){
      //         print("No hay nada para mostrar");
      //       }else{
      //       print("Inicio Ubicacion ${_listClients.length}");
      //       for (var x in _listClients){
      //         print(x.lat);
      //         print(x.lng);
      //         print("---------");
      //       }
      //       print("Fin Ubicacion");
      //         Navigator.push(context, MaterialPageRoute( builder: (context) => MapRoutePage(cliente: _listClients)));
      //       }
      //     },
      // ),
      body: BackdropScaffold(
         stickyFrontLayer: true,
        // headerHeight: heightDevice / 4 ,
        title: _title(),
        backLayer: _backLayer(),
        frontLayer: _creditList(),
        iconPosition: BackdropIconPosition.action,
        frontLayerBorderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
    );
  }

  bool _actualizar = true;
  
  Widget _creditList() {
    _listClients.clear();
    return FutureBuilder(
      //lista del servidor
      future: _actualizar ? CreditProvider().list(plazo: _valorPlazo, cobros: _valorCobro, ruta: _valorRuta, search: _search) : null,
      builder: (context, snapshot) {
        _actualizar = false;

        if (snapshot.hasError) {
          return renderError(snapshot.error, _retry);
        }

        if (!snapshot.hasData) return loader(text: "Cargando créditos...");

        var results = snapshot.data.data;

        print(results);

        if (results != null && results.length <= 0) {
          return renderNotFoundData("No hay creditos para mostrar");
        }

        return ListView.separated(
          separatorBuilder: (context, index) => Container(
            height: 0.0,
            width: 0.0,
          ),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            var credit = (results[index]);
            return _elements(context, credit, results, index);
          },
        );
      },
    );
  }

  Slidable _elements(context, credit, results, index) {
    _listClients.add(new ClientCredit(credit['geo_lat'], credit['geo_lon'], "${credit['name']}  ${credit['surname']}", credit['address'], credit['ruta']));

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
              "Plazo: ${credit['plazo']} | Total: ${money(credit['total'])}"),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListPaymentsPage(id: credit['id'])));
          },
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Ubicacion',
            color: Colors.blue,
            icon: Icons.map,
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapOnlyLocationPage( cliente: new ClientCredit(credit['geo_lat'], credit['geo_lon'], "${credit['name']}  ${credit['surname']}", credit['address'], credit['ruta']))));
              },
          ),
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Anular',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {
              bool process =
                  await _invalidateCredit(credit['id'], _reason, context);
              if (process) {
                results.removeAt(index);
                _retry();
              }
            },
          ),
          IconSlideAction(
            caption: 'Finalizar',
            color: Colors.green,
            icon: Icons.cancel,
            onTap: () async {
              bool process = await _endCredit(credit['id'], context);
              if (process) {
                results.removeAt(index);
                _retry();
              }
            },
          ),
        ]);
  }

  // Finalizar crédito
  Future<bool> _endCredit(creditId, context) async {
    int isOk = await Alert.confirm(context,
        title: "Finalizar Crédito",
        content: "¿Está seguro que desea finalizar este crédito?");
    if (isOk == 1) {
      return false;
    }
    if (creditId <= 0) {
      Scaffold.of(context).showSnackBar(
          customSnack("No se ha podido finalizar este crédito", type: 'err'));
      return false;
    }
    _loader.show(msg: "Finalizando crédito");
    Responser res = await CreditProvider().end(creditId);
    if (res.ok) {
      Scaffold.of(context)
          .showSnackBar(customSnack("Crédito procesado con exito"));
    } else {
      Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
    }
    _loader.hide();
    return true;
  }

  _retry() {
    //locations.clear();
    setState(() {});
  }

  // Codigo para el nuevo AppBar con filtro

  Map<String, String> rutas = {'1': 'Zona 1', '2': 'Zona 2', 'null': 'Todos'};
  Map<String, String> cobros = {
    'DIARIO': 'Diario',
    'SEMANAL': 'Semanal',
    'QUINCENAL': 'Quincenal',
    'MENSUAL': 'Mensual',
    'null': 'Todos',
  };
  Map<String, String> plazos = {
    'SEMANAL': 'Semanal',
    'QUINCENAL': 'Quincenal',
    'MENSUAL': 'Mensual',
    'MES_Y_MEDIO': 'Mes y medio',
    'DOS_MESES': 'Dos meses',
    'null': 'Todos',
  };

  String _valorPlazo = "null";
  String _valorCobro = "null";
  String _valorRuta = "null";
  String _search = "null";
  bool isSearching = false;

  Widget _title() {
    return Row(
      children: <Widget>[
        !isSearching
            ? Text('Lista de Creditos')
            : 
            SizedBox(
              width: 100.0,
              child: 
            TextField(
              
                onSubmitted: (v) {},
                onChanged: (value) {
                  _search = value;
                  _actualizar = true;
                  setState(() {
                    
                  });
                  // _filterCountries(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    // icon: Icon(Icons.search, color: Colors.white,),
                    hintText: "Buscar cliente",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
              
            ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      _search = "null";
                  _actualizar = true;
                      //llenar los datos con la busqueda
                      // filteredCountries = countries;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _comboPlazo(context),
              _comboCobros(context),
              _comboRutas(context),
              Divider(),
              RaisedButton(
                elevation: 0.0,
                disabledTextColor: Colors.white,
                color: colors['primaryDark'],
                onPressed: () {
                  _listClients.clear();
                  _actualizar = true;
                  _retry();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Aceptar", style: TextStyle(color: Colors.white, fontSize: 18.0, wordSpacing: 20.0),
                    textAlign: TextAlign.center,),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Plazo
  Widget _comboPlazo(context) {
    return Container(
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
        onChanged: (opt) async {
          // setState(() {
          _valorPlazo = opt;
          _retry();
          // });
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
          // setState(() {
          _valorCobro = opt;
          _retry();
          // });
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
          // setState(() {
          _valorRuta = opt;
          _retry();
          // });
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
            style: TextStyle(
              color: Colors.orange,
            ),
          ),
          value: k,
        ));
    });
    return lista;
  }

  // Anular crédito
  Future<bool> _invalidateCredit(creditId, reason, context) async {
    int isOk = await Alert.confirm(context,
        title: "Anular Crédito",
        content: "¿Está seguro que desea anular este crédito?");
    if (isOk == 1) {
      return false;
    }
    if (creditId <= 0) {
      Scaffold.of(context).showSnackBar(
          customSnack("No se ha podido anular este crédito", type: 'err'));
      return false;
    }

    await _displayDialog(context);
    _loader.show(msg: "Anulando crédito");
    Responser res = await CreditProvider().cancel(creditId, _reason);
    if (res.ok) {
      Scaffold.of(context)
          .showSnackBar(customSnack("Crédito anulado con exito"));
      _loader.hide();
    } else {
      _loader.hide();
      Scaffold.of(context).showSnackBar(customSnack(res.message, type: 'err'));
      return false;
    }
    return true;
  }

  Future _displayDialog(BuildContext context) async {
    //Refrescar los valores
    _textEditingController.text = "";
    _reason = "";
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ingrese el motivo por el cual va a anular el crédito'),
            content: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(hintText: "Motivo"),
              onChanged: (text) {
                _reason = text;
              },
            ),
            actions: <Widget>[
              new FlatButton(
                child: Text('Enviar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
