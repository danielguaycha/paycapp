import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paycapp/src/brain.dart';
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/pages/maps/map_only_page.dart';
import 'package:paycapp/src/utils/utils.dart';

class CreditExtraComponent extends StatefulWidget {

  final Credit credit;
  final bool geoLoc;

  CreditExtraComponent({Key key, this.credit, this.geoLoc}) : super(key: key);

  @override
  _CreditExtraComponentState createState() => _CreditExtraComponentState();
}

class _CreditExtraComponentState extends State<CreditExtraComponent> {
  Credit _credit;
  TextEditingController _txtAdress = TextEditingController();
  TextEditingController _txtPrenda = TextEditingController();
  TextEditingController _txtRef = TextEditingController();

  bool _geoloc = true;

  // Mostrar loaders al cargar imagenes
  bool _loaderRef = false;
  bool _loaderPrenda = false;

  @override
  void initState() {
    _credit = widget.credit;
    _geoloc = (_credit.geoLat == null ) ? widget.geoLoc : false;    
    _txtAdress.value = TextEditingValue(text: (_credit.address != null ? _credit.address : ''));
    _txtPrenda.value = TextEditingValue(text: (_credit.prendaDetail != null) ? _credit.prendaDetail: '');
    _txtRef.value = TextEditingValue(text: (_credit.refDetail != null) ? _credit.refDetail: '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        _zones(),
        SizedBox(height: 5),
        _addressField(),
        SizedBox(height: 10),        
        _switchGeoLoc(),
        Divider(height: 2),
        _fieldReference(),
        Divider(height: 5),
        _fieldPrenda(),
        _customGeoLoc(context),
      ]
    );
  }

  Widget _customGeoLoc(context) {
    return Visibility(
      visible: !_geoloc,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Column(
        children: <Widget>[
          Divider(height: 10),
          ListTile(
            onTap: () {
              _searchOnMap(context);
            },
            contentPadding: EdgeInsets.all(0),          
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(FontAwesomeIcons.mapMarked, color: (_credit.geoLat == null ? Colors.grey : Colors.orange)),       
                SizedBox(width: 17),       
                Text((_credit.geoLon == null ? "Especificar ubicación": "Ubicación seleccionada"))
              ],
            ),
            subtitle: _subtitle(text: _credit.geoLat == null ? "Abre el mapa y busca tu ubicación": "lat: ${_credit.geoLat}, Lng: ${_credit.geoLon}"),
          )
        ],
      ),
    );
  }

  //* Geolocalización
  Widget _switchGeoLoc() {
    return SwitchListTile(
      value: _geoloc, 
      contentPadding: EdgeInsets.symmetric(vertical: 2),
      title: _swicthTitle(
        title: "Ubicación actual",        
        icon: FontAwesomeIcons.mapMarkerAlt,
        swicthed: _geoloc
      ),
      subtitle: _subtitle(text: "¿Esta ubicación es la dirección del cliente?"),
      onChanged: (value) {
        setState(() {
          _geoloc = value;
          _credit.geoLat = null;
          _credit.geoLon = null;
        });
      },
    );
  }

  //* panel de prenda
  Widget _fieldPrenda(){
    return _expandPanel(
      header: "Agregar prenda",
      iconHeader: FontAwesomeIcons.dolly,
      child: Container(
        padding: EdgeInsets.only(left: 40),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _txtPrenda,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Detalle',      
              ),
              onSaved: (v) => _credit.prendaDetail = v,
              onChanged: (v) => _credit.prendaDetail = v,
            ),
            SizedBox(height: 5),
            _showPrenda(context)
          ],
        ),
      ),
    );
  }

  //* panel referencia

  Widget _fieldReference() {
    return _expandPanel(
      header: "Agregar referencia",
      iconHeader: FontAwesomeIcons.solidAddressBook,
      child: Container(
        padding: EdgeInsets.only(left: 40),
        child: Column(
          children: <Widget>[            
              TextFormField(    
                controller: _txtRef,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Detalle'                  
                ),
                onSaved: (v) => _credit.refDetail = v,
                onChanged: (v) => _credit.refDetail = v,
              ),
              SizedBox(height: 5),
              _showReference(context),
          ],          
        ),
        
      ),     
    );    
  }


  Widget _expandPanel({Widget child, Widget collapChild, header: "", IconData iconHeader: Icons.place }) {
    return ExpandablePanel(          
          theme: ExpandableThemeData(
            alignment: Alignment.center,
            iconColor: Colors.grey, 
            expandIcon: Icons.arrow_drop_up,
            collapseIcon: Icons.arrow_drop_down,
            iconSize: 25,        
            bodyAlignment: ExpandablePanelBodyAlignment.center,
            headerAlignment: ExpandablePanelHeaderAlignment.center,        
            iconPadding: EdgeInsets.symmetric(vertical: 15),
            animationDuration: const Duration(milliseconds: 600),                                  
          ),
          header: _swicthTitle(title: '$header', icon: iconHeader, swicthed: true),
          expanded: child == null ? SizedBox.shrink(): child,                    
          collapsed: collapChild == null ? SizedBox.shrink(): collapChild,                    
        );
  }
  
  
  Widget _swicthTitle({title: '', IconData icon, bool swicthed : false}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(icon, color: (swicthed ? Colors.orange: Colors.grey) ),
          SizedBox(width: 15),
          Text("$title", style: TextStyle(color: Colors.black87, fontSize: 16))
        ],
      );
  }

  Widget _subtitle ({text: ''}) {
    return Row(
      children: <Widget>[
        SizedBox(width: 5),
        Text("$text", style: TextStyle(fontSize: 12))
      ],
    );
  }


  //*=== Dirección ===

  _addressField() {
    return TextFormField(
      controller: _txtAdress,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      minLines: 1,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Dirección',
        icon: Icon(FontAwesomeIcons.solidAddressCard, color: Colors.orange),
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


  //*=== Zonas ===

  Widget _zones () {
    return StoreConnector<AppState, dynamic>(
        onInit: (store) => {

        },  
        converter: (store) => store.state.user,
        builder: (context, user) { 
          if(user.zones == null) {
            return Center(child: Text("No hay rutas disponibles", style: TextStyle(color: Colors.red)));
          }          

          return DropdownButtonFormField(          
            value: _credit.rutaId == null ? 0 : _credit.rutaId,
            itemHeight: 80,
            isDense: true,                    
            decoration: InputDecoration(
                icon: Icon(FontAwesomeIcons.route, color: Colors.orange,), labelText: 'Zona/Ruta'),
            onChanged: (v) {                     
              setState(() {
                _credit.rutaId = v;  
              });
            },          
            items: _renderZones(user.zones),
          );
        },
    );
  }

  List _renderZones (List<Zone> zones) {
    List<DropdownMenuItem<int>> lista = new List();
    lista.add(DropdownMenuItem(
      child: Text("Seleccione...", style: TextStyle(color: Colors.black26)),
      value: 0,
    ));
    zones.forEach((z) {
      lista
      ..add(DropdownMenuItem(
        child: Text('${z.name}'),
        value: z.id,
      ));
    });
    return lista;
  }

  // * WidgetImagen
  Widget _showReference(context) {
    
    if (_credit.refImg == null && !_loaderRef) { //? si no esta cargado nada
      return _showButtons(
        onCamera: (){
          _loadReference(source: ImageSource.camera);
        },
        onGallery: (){
          _loadReference(source: ImageSource.gallery);
        }
      );
    } 
    else if(_credit.refImg == null && _loaderRef){ //? Si la imagen esta cargando
      return miniLoader();
    }
    else { //? Si ya esta cargada
      return _showTumbnail(
        tag: "Referencia",
        img: _credit.refImg,
        onRemove: () {          
          setState(() {
            _credit.refImg = null;
          });          
      });
    } 
  }

  Widget _showPrenda(context) {
    
    if (_credit.prendaImg == null && !_loaderPrenda) { //? si no esta cargado nada
      return _showButtons(
        onCamera: (){
          _loadPrenda(source: ImageSource.camera);
        },
        onGallery: (){
          _loadPrenda(source: ImageSource.gallery);
        }
      );
    } 
    else if(_credit.prendaImg == null && _loaderPrenda){ //? Si la imagen esta cargando
      return miniLoader();
    }
    else { //? Si ya esta cargada
      return _showTumbnail(
        tag: "Prenda",
        img: _credit.prendaImg,
        onRemove: () {          
          setState(() {
            _credit.prendaImg = null;
          });          
      });
    } 
  }

  _showButtons({Function onCamera, Function onGallery}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton.icon(
            onPressed: onCamera,           
            label: Text("Cámara"),
            icon: Icon(Icons.camera),
          ),
          FlatButton.icon(
            onPressed: onGallery,           
            label: Text("Galeria"),
            icon: Icon(Icons.image),
          ),
        ],
      );
  }

  _showTumbnail({tag: '', Function onRemove, @required File img}) {
    return ListTile(
        contentPadding: EdgeInsets.all(0),        
        trailing: IconButton(
          onPressed: onRemove, 
          icon: Icon(Icons.delete)
        ),
        leading: Image.file(img),
        title: Text("$tag cargada"),
        subtitle: Text("${(img.lengthSync() / 1024).roundToDouble()} kb"),
      );
  }
  
  // * Funciones de imagenes

  _loadReference({ @required ImageSource source }) async {
    setState(() {_loaderRef = true;});
    File img = await ImagePicker.pickImage(source: source);
    if(img != null)
      _credit.refImg = await compressImg(img);    
    setState(() {_loaderRef = false;});
  }

  _loadPrenda({ @required ImageSource source }) async{
    setState(() {_loaderPrenda = true;});
    File img = await ImagePicker.pickImage(source: source);
    if(img != null)
      _credit.prendaImg = await compressImg(img);    
    
    setState(() {_loaderPrenda = false;});
  }

  //* functiones de mapas

  _searchOnMap(context) async {
    LatLng latLng = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MapOnlyPage()));
    if(latLng!=null) {
      _credit.geoLat = latLng.latitude;
      _credit.geoLon = latLng.longitude;
    }
    setState(() {});
  }

}




/*StoreConnector<AppState, dynamic>(
  converter: (store) => store.state.user,
  builder: (context, user) {
    return new Text(
      "${user.username}",
      style: Theme.of(context).textTheme.display1,
    );
  },
), 
*/
/*
new StoreConnector (
  converter: (store) {
    // Return a `VoidCallback`, which is a fancy name for a function
    // with no parameters. It only dispatches an Increment action.
    return () => store.dispatch(MyActions.Increment);
  },
  builder: (context, callback) {
    return new RaisedButton(
      // Attach the `callback` to the `onPressed` attribute
      onPressed: callback,
      child: new Icon(Icons.add),
    );
  },
),*/