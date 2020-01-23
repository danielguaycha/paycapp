import 'dart:io';
import 'package:intl/intl.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/expense_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import '../../utils/utils.dart';
import 'package:path/path.dart';
import 'package:paycapp/src/config.dart' show categorias;


class AddExpensePage extends StatefulWidget {
  AddExpensePage({Key key}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {

  //Variables
  double _monto = 0.0;
  String _opcionSeleccionada = 'COMIDA';
  String _description = "";
  String _fecha = "";
  File _image;
  bool _cargarFechaActual = true;
  bool _changeWidget = false;
  ProgressLoader _loader;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DateFormat formatter = new DateFormat('yyyy-MM-dd');
  TextEditingController _inputFieldDateController = new TextEditingController();
  TextEditingController _controllerMonto = new TextEditingController();
  TextEditingController _controllerCategoria = new TextEditingController();
  TextEditingController _controllerDescripcion = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    _loader = new ProgressLoader(context);
    if(_cargarFechaActual){
      _inputFieldDateController.text = _currentTime();
      _fecha = _currentTime();
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Registrar Gastos'),
      ),
      floatingActionButton: _btnSave(context),
      body: SingleChildScrollView(
        child: _cardBasicData(context),
      ),
    );
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
              SizedBox(height: 2),
            _crearInputDate(context),
            //Campo Categoria
              SizedBox(height: 2),
            _changeWidget ? _categoryField() : _comboCategorias(context),
            //Campo Importe
              SizedBox(height: 2),
            _montoField(),
            //Campo descripcion
              SizedBox(height: 2),
              _descriptionField(),
              SizedBox(height: 2),
              _photosBtn(remove: 'Quitar'),
              SizedBox(height: 2),
              _showImageRefence(),
            ],
          ),
        ));
  }


  Widget _crearInputDate(BuildContext context) {
    return TextField(
      enableInteractiveSelection: false,
      controller:  _inputFieldDateController,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: "Fecha",
          icon: Icon(Icons.calendar_today)),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        _selecionarFecha(context);
      },
    );
  }

  _selecionarFecha(BuildContext context) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(1990),
      lastDate: new DateTime.now(),
      locale: Locale('es', 'ES'),
    );
    if (picked != null) {
      setState(() {
        _fecha = formatter.format(picked);
        _cargarFechaActual = false;
        _inputFieldDateController.text = _fecha;
      });
    }
  }

  // Plazo
  Widget _comboCategorias(context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: DropdownButtonFormField(
          value: _opcionSeleccionada,
          //hint: new Text("Plazo"),
          items: listItems(categorias),
          decoration: InputDecoration(
            icon: Icon(Icons.category),
            labelText: 'Plazo',
          ),
          // onSaved: (v) {},
          // validator: (v) {
          //   if (v == null || v == '') return 'Selecciona un plazo';
          //   return null;
          // },
          onChanged: (opt) {
            if(opt == "OTROS"){

              _changeWidget = true;
              _opcionSeleccionada = "null";
            }else{
              _opcionSeleccionada = opt;
            }
            setState(() {
            });
          },
        ),
    );
  }

  // Monto
  Widget _montoField() {
    return TextFormField(
      //initialValue: "",
      controller: _controllerMonto,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto \$ *',
        hintText: '\$ 0.00',
        icon: Icon(Icons.attach_money),
      ),
      onChanged: (v) {
        if (isNumeric(v)) {
          _monto = double.parse(v);
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

  // Categoria Input
  Widget _categoryField() {
    return TextFormField(
      //initialValue: "",
      controller: _controllerCategoria,
      decoration: InputDecoration(
        labelText: 'Categoria',
        icon: Icon(Icons.category),
      ),      
      onChanged: (v) {
          _opcionSeleccionada = v;
      },
    );
  }
  
  // Descripcion
  _descriptionField() {
    return TextFormField(
      controller: _controllerDescripcion,
      //initialValue: "",
      decoration: InputDecoration(
        labelText: 'Descripción',
        icon: Icon(Icons.comment),
      ),      
      onChanged: (v) {
          _description = v;
      },
    );
  }

  // Botones para imagenes y tomar foto
  _photosBtn(
      {String select: 'Seleccionar',
      String take: 'Capturar',
      String remove: 'Quitar'}) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: (_image == null)
          ? <Widget>[
              FlatButton.icon(
                icon: Icon(FontAwesomeIcons.image, color: Colors.black38),
                label: Text(select, style: TextStyle(color: Colors.black45)),
                onPressed: () {
                  _openGalleryCamera(galeria: true);
                },
              ),
              FlatButton.icon(
                icon: Icon(FontAwesomeIcons.camera, color: Colors.black38),
                label: Text(take, style: TextStyle(color: Colors.black45)),
                onPressed: () => _openGalleryCamera(galeria: false),
              )
            ]
          : <Widget>[
              FlatButton.icon(
                onPressed: () {
                  setState(() {
                    _image = null;
                  });
                },
                icon: Icon(FontAwesomeIcons.times, color: Colors.red[300]),
                label: Text(remove, style: TextStyle(color: Colors.red[300])),
              ),
            ],
    );
  }
  
  _openGalleryCamera({bool galeria: false}) async {
    File img;
    if(galeria){
      img = await ImagePicker.pickImage(source: ImageSource.gallery);
    }else{
      img = await ImagePicker.pickImage(source: ImageSource.camera);
    }
    File endImg = await compressImg(img);
    _image = endImg;
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

  // camera and gallery
  _showImageRefence({bool prenda: false}) {
   if (_image != null) {
      return Center(
        child: Image.file(_image),
      );
    } else {
      return Center();
    }
  }

  String _currentTime(){
    var date = new DateTime.now();
    return formatter.format(date);
  }

  FloatingActionButton _btnSave(context){
    return FloatingActionButton(
      child: Icon(Icons.save, color: Colors.white,),      
      onPressed: () async {
        // Guardar datos
        if(_monto <= 0)
        {
            _scaffoldKey.currentState.showSnackBar(customSnack("El monto debe ser mayor a 0", type: 'err'));
            return;
        }
        if(_changeWidget && (_opcionSeleccionada == "null" || cadenaValida(_opcionSeleccionada) || _opcionSeleccionada.isEmpty))
        {
          _scaffoldKey.currentState.showSnackBar(customSnack("Debe ingresar una categoria", type: 'err'));
          return;
        }
          int isOk = await Alert.confirm(context,
          title: "Confirmar",
          content: "¿Está seguro que desea guardar este gasto?");
          
          if (isOk == 1) {
              return;
          }
          
          _loader.show(msg: "Procesando gasto, espere");
          
          Responser res = await ExpenseProvider().store(_monto, _opcionSeleccionada, _description, _fecha, _image);
          //print("Mensaje $res");
          if (res.ok) {
            _scaffoldKey.currentState.showSnackBar(customSnack("Gasto registrado con exito"));
            _limpiar();
          } else {
            _scaffoldKey.currentState.showSnackBar(customSnack(res.message, type: 'err'));
          }
          _loader.hide();
        
      });
  }

  void _limpiar(){
  _monto = 0.0;
  _opcionSeleccionada = 'COMIDA';
  _fecha = "";
  _cargarFechaActual = true;
  _description = "";
  _image = null;
  _changeWidget = false;
  _controllerMonto.text = "";
  _controllerDescripcion.text = "";
  _controllerCategoria.text = "";
  setState(() {});
  }

  bool cadenaValida(String cadena){
    for (var i = 0; i < cadena.length; i++) {
      if (cadena[i] != ' '){return false;}      
    }
    return true;

  }

}