import 'package:backdrop/backdrop.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart'
    show loader, money, renderError, renderNotFoundData;
import 'package:paycapp/src/config.dart' show colors;
import '../maps/map_with_route.dart';
import 'package:paycapp/src/brain.dart';
import 'package:paycapp/src/pages/credit/show_credit_page.dart';
// List<LatLng> _listLocations = new List<LatLng>();
// List<String> _listname = new List<String>();

class ListCreditPage extends StatefulWidget {
  @override
  _ListCreditPageState createState() => _ListCreditPageState();
}

class _ListCreditPageState extends State<ListCreditPage> with SingleTickerProviderStateMixin{

  TextEditingController _textEditingController = new TextEditingController();
  String _reason = "";
  List<DataClient> _listClients = new List<DataClient>();
  ProgressLoader _loader;
  AnimationController _controller;
  bool _actualizar = true;

  @override
  void initState() {    
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 100), value: 1.0);
    super.initState();
  }

  bool get isBackPanelVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.dismissed ||
        status == AnimationStatus.reverse;
  }

  void showFrontLayer() {
    if (isBackPanelVisible) _controller.fling(velocity: 1.0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    _loader = new ProgressLoader(context);
    return Scaffold(
      body: BackdropScaffold(
         stickyFrontLayer: true,
        // headerHeight: heightDevice / 4 ,}
        controller: _controller,
        title: _title(),
        backLayer: _backLayer(context),
        frontLayer: _creditList(),
        iconPosition: BackdropIconPosition.action,
        frontLayerBorderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
    );
  }

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
          //TODO: Revisar porque al parecer el widget imprime dos veces esto, doble petición es posible
        //print(results);

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
    _listClients.add(new DataClient(credit['geo_lat'], credit['geo_lon'], "${credit['name']}  ${credit['surname']}", credit['address'], zone: credit['ruta'] ));
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        child: ListTile(
          dense: false,          
          leading: Icon(FontAwesomeIcons.dollarSign,
              size: 25, color: (credit['status'] == 0 ? Colors.grey : Colors.orange)),        
          title: Text(
            "${credit['name']} ${credit['surname']}".toUpperCase(),
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600),
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
            caption: 'Mas Info',
            color: Colors.indigo,
            iconWidget: Icon(FontAwesomeIcons.info, color: Colors.white),
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ShowCreditPage(id: credit['id'])));
            }                            
          ),
          IconSlideAction(
            caption: 'Ubicación',
            color: Colors.blue,
            icon: FontAwesomeIcons.mapMarkerAlt,
            onTap: () async {
              List<DataClient> _dataClient = new List<DataClient>();
              _dataClient.add(new DataClient( credit['geo_lat'], credit['geo_lon'], "${credit['name']}  ${credit['surname']}", credit['address'], zone: credit['ruta'] ));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapRoutePage(cliente: _dataClient)));
              },
          ),
        ],
        secondaryActions: <Widget>[
           IconSlideAction(
            caption: 'Anular',
            color: credit['status'] != 0 ? Theme.of(context).primaryColor : Colors.grey[300],
            foregroundColor: credit['status'] != 0 ? Colors.white : Colors.grey[400],
            icon: Icons.delete,
            onTap: credit['status'] != 0 ? () async {
              bool process =
                  await _invalidateCredit(credit['id'], _reason, context);
              if (process) {
                results.removeAt(index);
                _retry();
              }
            } : null,
          ),
          IconSlideAction(
            caption: 'Finalizar',
            color: credit['status'] != 0 ? Colors.green :  Colors.grey[300],
            foregroundColor: credit['status'] != 0 ? Colors.white : Colors.grey[400],
            icon: Icons.done_all,
            onTap: credit['status'] != 0 ? () async {
              bool process = await _endCredit(credit['id'], context);
              if (process) {
                results.removeAt(index);
                _retry();
              }
            } : null,
          ),
        ]);
  }

  // Finalizar crédito
  Future<bool> _endCredit(creditId, context) async {
    int isOk = await Alert.confirm(context,
        title: "Finalizar Crédito",
        content: "Al marcar un crédito como finalizado el sistema entiende que no hay cobros pendientes\n¿Está seguro que desea finalizar este crédito?");
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
  int _valorRuta = 0;
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
              
              autofocus: true,
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

  Widget _backLayer(context) {
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
              _zones(),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    elevation: 0.0,
                    disabledTextColor: Colors.white,
                    color: colors['primaryDark'],
                    onPressed: () {
                      _listClients.clear();
                      _actualizar = true;
                      _retry();
                      showFrontLayer();
                    },
                    child: Text("Aceptar", style: TextStyle(color: Colors.white) ),
                  ),                  
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.white70,),
                    onPressed: () {                                              
                        _valorCobro = "null";
                        _valorPlazo = "null";
                        _valorRuta = 0;                         
                        _listClients.clear();
                        _actualizar = true;
                      setState(() {});
                    },
                  )
                ],
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
              TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          fillColor: Colors.white,
          icon: Icon(
            Icons.timer,
            color: Colors.white54,
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
              TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          fillColor: Colors.white,
          icon: Icon(
            Icons.calendar_today,
            color: Colors.white54,
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

    //*=== Zonas ===

  Widget _zones () {
    return StoreConnector<AppState, dynamic>(
        onInit: (store) => {

        },  
        converter: (store) => store.state.user,
        builder: (context, user) { 
          return DropdownButtonFormField(          
            value: _valorRuta,
            decoration: InputDecoration(
              labelText: "Filtrar por Rutas",
              labelStyle:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              fillColor: Colors.white,
              icon: Icon(
                FontAwesomeIcons.route,
                color: Colors.white54,
              ),
            ),                             
            onChanged: (v) {                     
              setState(() {
                _valorRuta = v;
              });
            },          
            items: _renderZones(user.zones),
          );
        },
    );
  }

  List _renderZones (List<Zone> zones) {
    List<DropdownMenuItem<int>> lista = new List();
    
    zones.forEach((z) {
      lista
      ..add(DropdownMenuItem(
        child: Text('${z.name}', style: TextStyle(
              color: Colors.orange,
            ),),
        
        value: z.id,
      ));
    });
    lista.add(DropdownMenuItem(
      child: Text("Todas", style: TextStyle(
              color: Colors.orange,
            ),),
      value: 0,
    ));
    return lista;
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
    if (creditId <= 0) {
      Scaffold.of(context).showSnackBar(
          customSnack("Vuelva a seleccionar un crédito", type: 'err'));
      return false;
    }

    var val = await _displayDialog(context);
    if(val == null) return false;

    if(_reason.isEmpty) {
      Scaffold.of(context)
          .showSnackBar(customSnack("Ingrese un motivo", type: 'err'));
      return false;
    }

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
            title: Text('Ingrese un motivo para confirmar la anulación'),
            content: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(hintText: "Motivo"),
              onChanged: (text) {                                
                  _reason = text;                  
              },
            ),
            actions: <Widget>[
               new FlatButton(
                child: Text('Cancelar'),
                onPressed: () {  

                  Navigator.of(context).pop(null);
                },
              ),
              new FlatButton(
                child: Text('Enviar'),
                onPressed: (_reason != null) ? () {                
                  Navigator.of(context).pop(1);
                }: null,
              )
            ],
          );
        });
  }
}
