import 'dart:async';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/models/ruta_model.dart';
import 'package:paycapp/src/pages/client/search_client_delegate.dart';
import 'package:paycapp/src/pages/routes/route_selection_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart' show customSnack;
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart'
    show listItems, isNumeric, listItemsNormal;
import 'package:paycapp/src/config.dart'
    show plazos, utilidad, cobros, defaultUtility;

import '../map_only_page.dart';
import 'package:path/path.dart';

class AddCreditPage extends StatefulWidget {
  @override
  _AddCreditPageState createState() => _AddCreditPageState();
}

class _AddCreditPageState extends State<AddCreditPage> {
  // Variables para el mapa
  final Set<Marker> _markers = Set();

  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(26.8206, 30.8025), zoom: 100.0);
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  double latSelected = 0.0;
  double longSelected = 0.0;

  Color _btnColor = Colors.grey;
  // Fin de variables para el mapa
  Person _client;
  Credit _credit;
  Ruta _route;
  LatLng _latLng;
  ProgressLoader _loader;

  final _frmKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _userField = TextEditingController();
  TextEditingController _routeField = TextEditingController();
  TextEditingController _addressFieldController = TextEditingController();

  bool _prenda;
  bool _geoloc;
  bool _enabled;

  @override
  void initState() {
    super.initState();
    _credit = new Credit();
    _client = null;
    _enabled = false;
    _prenda = false;
    _geoloc = true;
  }

  @override
  Widget build(BuildContext context) {
    _loader = new ProgressLoader(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Nuevo Crédito'),
        actions: <Widget>[
          IconButton(
            tooltip: "Buscar un cliente",
            icon: Icon(Icons.search),
            onPressed: () {
              searchClient(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 35),
        child: _form(context),
      ),
      bottomNavigationBar: new BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              onPressed: () => _clearCredit(context),
              icon: Icon(Icons.clear_all),
              tooltip: 'Limpiar Formulario',
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Guardar Crédito',
        child: Icon(
          Icons.done_all,
          color: Colors.white,
        ),
        onPressed: !_enabled
            ? () {
                Alert.toast(context, "Seleccione un cliente",
                    position: ToastPosition.center);
              }
            : () {
                saveCredit(context);
              },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  //================= SUBMIT FORM
  saveCredit(context) async {
    if (!_frmKey.currentState.validate()) return;
    _frmKey.currentState.save();

    int isOk = await Alert.confirm(context,
        title: "Confirmar",
        content: "¿Está seguro que desea guardar este crédito?");
    if (isOk == 1) {
      return;
    }

    _loader.show(msg: "Procesando crédito, espere");

    if (_geoloc) {
      final loc = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _credit.geoLat = loc.latitude;
      _credit.geoLon = loc.longitude;
    }else{
      _credit.geoLat = latSelected;
      _credit.geoLon = longSelected;

    }

    Responser res = await CreditProvider().store(_credit);
    if (res.ok) {
      _clearCredit(context);
      _scaffoldKey.currentState
          .showSnackBar(customSnack("Crédito procesao con exito"));
    } else {
      _scaffoldKey.currentState
          .showSnackBar(customSnack(res.message, type: 'err'));
    }
    _loader.hide();
  }

  _clearCredit(context) {
    _credit = new Credit();
    _client = null;
    _enabled = false;
    _prenda = false;
    _geoloc = true;
    _route = null;

    _userField = TextEditingController();
    _routeField = TextEditingController();
    _addressFieldController = TextEditingController();
    _frmKey.currentState.reset();
    setState(() {});
  }

  //================== FORM
  _form(context) {
    return Form(
        key: _frmKey,
        child: Column(
          children: <Widget>[
            _cardBasicData(context),
            _cardUbicData(context),
            _cardPrenda(context),
          ],
        ));
  }

  // DATOS BÁSICOS
  _cardBasicData(context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Padding(
          padding: EdgeInsets.only(right: 10, left: 10, bottom: 15, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("DATOS BÁSICOS - CLIENTE - MONTO",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                  )),
              SizedBox(height: 2),
              //Visibility(visible: !_enabled, child: Text('Seleccione un cliente', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w700))),
              _clientField(context),
              SizedBox(height: 2),
              _montoField(),
              SizedBox(height: 2),
              _comboPlazo(context),
              SizedBox(height: 2),
              _comboCobro(context),
              SizedBox(height: 2),
              _comboUtilidad(context),
              SizedBox(height: 15),
              _calcContainer(context),
              //_zone(context)
            ],
          ),
        ));
  }

  // DATOS DE UBICACIÓN
  _cardUbicData(context) {
    return Card(
        margin: EdgeInsets.all(10),
        child: Padding(
            padding: EdgeInsets.only(right: 10, left: 10, bottom: 15, top: 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text("RUTA - UBICACIÓN - DIRECCIÓN",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      )),
                  SizedBox(height: 2),
                  _setGeoLocField(),
                  Center(
                    child: RaisedButton(
                    onPressed: _geoloc ? null : ()  {
                      
                       searchOnMap(context);
              
                    },
                    child: Text("Buscar ubicacion"),                    
                    color: _btnColor,
                  ),
                  ),
                  SizedBox(height: 5),
                  _zoneField(context),
                  _addressField(),
                  SizedBox(height: 20),
                  Text("REFERENCIA",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      )),
                  SizedBox(height: 5),
                  _referenceDetailField(),
                  SizedBox(height: 15),
                  _showImageRefence(),
                  _photosBtn(remove: 'Quitar Referencia'),
                ])));
  }

  // DATOS DE PRENDA
  _cardPrenda(context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Padding(
            padding: EdgeInsets.only(right: 10, left: 10, bottom: 2, top: 5),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text("PRENDA",
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 10))),
                      Checkbox(
                        onChanged: (val) {
                          setState(() {
                            _prenda = val;
                          });
                        },
                        value: _prenda,
                      )
                    ],
                  ),
                  Visibility(
                    visible: _prenda,
                    child: _prendaDetailField(),
                  ),
                  Visibility(
                    visible: _prenda,
                    child: SizedBox(height: 15),
                  ),
                  Visibility(
                    visible: _prenda,
                    child: _showImageRefence(prenda: true),
                  ),
                  Visibility(
                    visible: _prenda,
                    child: _photosBtn(prenda: true, remove: 'Quitar prenda'),
                  ),
                  Visibility(
                    visible: _prenda,
                    child: SizedBox(height: 12),
                  ),
                ])));
  }

  /*---- INPUTS  ---*/

  // Cliente
  _clientField(context) {
    return TextFormField(
      controller: _userField,
      //enabled: false,
      readOnly: true,
      textCapitalization: TextCapitalization.words,
      decoration: (_enabled)
          ? InputDecoration(
              labelText: 'Cliente',
              icon: Icon(Icons.person),
            )
          : InputDecoration(
              labelText: 'Seleccione cliente',
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              icon: Icon(Icons.search),
            ),
      onTap: () {
        searchClient(context);
      },
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Seleccione un cliente';
        }
        return null;
      },
    );
  }

  // Monto
  _montoField() {
    return TextFormField(
      initialValue: '',
      enabled: _enabled,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto \$ *',
        hintText: '\$ 0.00',
        icon: Icon(Icons.attach_money),
      ),
      onFieldSubmitted: (v) {},
      onSaved: (v) => _credit.monto = double.parse(v),
      onChanged: (v) {
        if (isNumeric(v)) {
          _credit.monto = double.parse(v);
          _calcular();
        }
      },
      validator: (v) {
        if (!isNumeric(v)) {
          return "El monto ingresado no es válido";
        }
        if (double.parse(v) <= 0) {
          return 'El monto debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  // Plazo
  _comboPlazo(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: DropdownButtonFormField(
          value: _credit.plazo,
          //hint: new Text("Plazo"),
          items: listItems(plazos),
          decoration: InputDecoration(
            icon: Icon(Icons.query_builder),
            labelText: 'Plazo',
          ),
          onSaved: (v) {},
          validator: (v) {
            if (v == null || v == '') return 'Selecciona un plazo';
            return null;
          },
          onChanged: (opt) {
            setState(() {
              _credit.plazo = opt;
            });
            _calcular();
          },
        ),
      ),
    );
  }

  // Utilidad
  _comboUtilidad(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: DropdownButtonFormField(
          value: _credit.utilidad,
          //hint: new Text("Utilidad %"),
          items: listItemsNormal(utilidad, '%'),
          decoration: InputDecoration(
              icon: Icon(Icons.trending_up), labelText: 'Utilidad %'),
          onChanged: (opt) {
            setState(() {
              _credit.utilidad = opt;
            });
            _calcular();
          },
          validator: (v) {
            if (_credit.utilidad == null) {
              return 'Seleccione una utilidad';
            }
            return null;
          },
        ),
      ),
    );
  }

  // Tiempo de cobro
  _comboCobro(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: IgnorePointer(
        ignoring: !_enabled,
        child: DropdownButtonFormField(
          value: _credit.cobro,
          // hint: new Text("Tipo de cobro"),
          items: listItems(cobros),
          decoration: InputDecoration(
              icon: Icon(Icons.calendar_today), labelText: 'Tipo de cobro'),
          onSaved: (v) => _credit.cobro = v,
          validator: (v) {
            if (v == null || v == '') return 'Selecciona un cobro';
            return null;
          },
          onChanged: (opt) {
            setState(() {
              _credit.cobro = opt;
            });
            _calcular();
          },
        ),
      ),
    );
  }

  // Zona o ruta
  _zoneField(context) {
    return TextFormField(
      controller: _routeField,
      //enabled: false,
      readOnly: true,
      textCapitalization: TextCapitalization.words,
      decoration: (_route != null)
          ? InputDecoration(
              labelText: 'Zona o ruta',
              suffixIcon: Icon(FontAwesomeIcons.mapMarkerAlt),
            )
          : InputDecoration(
              labelText: 'Seleccione zona o ruta',
              labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              suffixIcon: Icon(FontAwesomeIcons.mapMarker),
            ),
      validator: (v) {
        if (v.isEmpty) {
          return 'Seleccione una zona';
        }
        return null;
      },
      onTap: () {
        searchZone(context);
      },
    );
  }

  // GeoLoc
  _setGeoLocField() {
    return CheckboxListTile(
        dense: true,
        value: _geoloc,
        onChanged: (value) {
          setState(() {
            _geoloc = value;
            if(_geoloc){
            _btnColor = Colors.grey;
            }else{
            _btnColor = Colors.orange;
            }
          });
        },
        title: Text("Ubicación actual"),
        subtitle: Text(
          '¿Esta ubicación es la dirección del cliente?',
          style: TextStyle(fontSize: 11),
        ));
  }

  // Dirección
  _addressField() {
    return TextFormField(
      controller: _addressFieldController,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      minLines: 1,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Dirección',
        suffixIcon: Icon(FontAwesomeIcons.addressCard),
      ),
      onSaved: (v) => _credit.address = v,
      validator: (v) {
        if (v.isEmpty) {
          return 'Ingrese una dirección';
        }
        return null;
      },
    );
  }

  //Detalle Referencia
  _referenceDetailField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Detalle | Observación',
        suffixIcon: Icon(FontAwesomeIcons.eye),
      ),
      onSaved: (v) => _credit.refDetail = v,
    );
  }

  // Detalle Prenda
  _prendaDetailField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Detalle',
        suffixIcon: Icon(FontAwesomeIcons.box),
      ),
      onSaved: (v) => _credit.prendaDetail = v,
    );
  }

  // Botones para imagenes y tomar foto
  _photosBtn(
      {String select: 'Seleccionar',
      String take: 'Capturar',
      String remove: 'Quitar',
      bool prenda: false}) {
    final img = prenda ? _credit.prendaImg : _credit.refImg;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: (img == null)
          ? <Widget>[
              FlatButton.icon(
                icon: Icon(FontAwesomeIcons.image, color: Colors.black38),
                label: Text(select, style: TextStyle(color: Colors.black45)),
                onPressed: () {
                  _openGallery(prenda: prenda);
                },
              ),
              FlatButton.icon(
                icon: Icon(FontAwesomeIcons.camera, color: Colors.black38),
                label: Text(take, style: TextStyle(color: Colors.black45)),
                onPressed: () => _takePhoto(prenda: prenda),
              )
            ]
          : <Widget>[
              FlatButton.icon(
                onPressed: () {
                  setState(() {
                    prenda ? _credit.prendaImg = null : _credit.refImg = null;
                  });
                },
                icon: Icon(FontAwesomeIcons.times, color: Colors.red[300]),
                label: Text(remove, style: TextStyle(color: Colors.red[300])),
              ),
            ],
    );
  }

  // Buscar Zona
  searchZone(context) async {
    _route = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => RouteSelectionPage()));
    
    if (_route == null) return;
    _routeField.value = TextEditingValue(text: _route.name);
    setState(() {
      _credit.rutaId = _route.id;
    });
  }

  // Buscar clientes
  searchClient(context) async {
    _client =
        await showSearch(context: context, delegate: SearchClientDelegate());
    if (_client == null) return;

    _credit.utilidad = defaultUtility;
    _credit.personId = _client.id;

    String name = "${_client.name} ${_client.surname}".toUpperCase();
    _userField.value = TextEditingValue(text: name);
    _addressFieldController.value = TextEditingValue(text: _client.address);
    _enabled = true;
    setState(() {});
  }

    // Buscar Ubicacion en el mapa
  searchOnMap(context) async {
    _latLng = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapOnlyPage()));
    if (_latLng == null) {
      //Si retorna y NO hubo cambios, desactiva el boton
      _geoloc = true;
      _btnColor = Colors.grey;
      return;
    }
    setState(() {
      //Si retorna y hubo cambios, estos los envia a las variables
      _geoloc = false;
      _btnColor = Colors.orange;
      latSelected = _latLng.latitude;
      longSelected = _latLng.longitude;      
      //_credit.rutaId = _route.id;
    });
  }

  Future _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
          
            contentPadding: EdgeInsets.all(0.0),
            content: mapa(context),
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

// codigo para el mapa

  Future<Position> _getLoc() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  FutureBuilder<Position> mapa(BuildContext context) {
    return FutureBuilder<Position>(
        future: _getLoc(),
        builder: (context, snapshot) {          
          if (!snapshot.hasData) {
            return Container(
              child: Column(                
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Cargando mapa...')
                ],
              ),
            );
          } else {

                if (latSelected==0.0) {
                  latSelected = snapshot.data.latitude;
                  longSelected = snapshot.data.longitude;
                }
            _initialPosition = CameraPosition(
                target: LatLng(latSelected, longSelected),
                zoom: 15.5);
            // _markers.add(
            //   Marker(
            //       markerId: MarkerId('Mi localización'),
            //       position:
            //           LatLng(snapshot.data.latitude, snapshot.data.longitude),
            //       infoWindow: InfoWindow(title: 'Cliente')),
            // );
            return _map();
          }
        });
  }

  _map() {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialPosition,
          rotateGesturesEnabled: false,
          markers: Set<Marker>.of(_markers),
          onTap: (LatLng value){
            _markers.clear();
              _markers.add(
                Marker(
                    draggable: true,
                    markerId: MarkerId('$value'),
                    position: new LatLng(value.latitude, value.longitude),
                    infoWindow: InfoWindow(
                      title: 'Ubicacion Cliente',
                    )),
              );
           
            latSelected = value.latitude;
            longSelected = value.longitude;
            print("Coordenadas: $latSelected - $longSelected");
             setState(() {
              
            });
          },
        ),
      ],
    );
  }

  //=================== CÁLCULOS
  _calcContainer(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: Text(
                  'Utilidad \$: ${_credit.totalUtilidad.toStringAsFixed(2)}'),
            ),
            Container(
              child: Text('Total \$: ${_credit.total}'),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Container(
              child: Text('Pagos de \$ ${_credit.pagosDe.toStringAsFixed(2)}'),
            ),
            Container(
              child: Text('Numero de pagos ${_credit.npagos}'),
            ),
          ],
        ),
      ],
    );
  }

  // Calcular Valores
  _calcular() {
    setState(() {
      _credit.calcular();
    });
  }

  // camera and gallery

  _showImageRefence({bool prenda: false}) {
    final img = (prenda) ? _credit.prendaImg : _credit.refImg;
    if (img != null) {
      return Center(
        child: Image.file(img),
      );
    } else {
      return Center();
    }
  }

  _openGallery({bool prenda: false}) async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    File endImg = await compressImg(img);
    if (!prenda)
      _credit.refImg = endImg;
    else
      _credit.prendaImg = endImg;

    setState(() {});
  }

  _takePhoto({bool prenda: false}) async {
    final img = await ImagePicker.pickImage(source: ImageSource.camera);
    File endImg = await compressImg(img);
    if (!prenda)
      _credit.refImg = endImg;
    else
      _credit.prendaImg = endImg;

    setState(() {});
  }

  Future<File> compressImg(File file) async {

    if(file == null) return null;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    String name = basename(file.path);
    String fileName = 'compress-'+name.split('.')[0];
    String ext = name.split('.')[1];
    String finalPath = appDocPath+'/'+fileName+'.'+ext;

    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, finalPath,
        quality: 88
      );    
    print(file.lengthSync());
    print(result.lengthSync());
    return result;
  }
}
