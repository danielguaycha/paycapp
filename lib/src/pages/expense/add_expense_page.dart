import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AddExpensePage extends StatefulWidget {
  AddExpensePage({Key key}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  //Variables
  String _fecha = "";
  String _importe = "";
  String _descripcion = "";
  TextEditingController _inputFieldDateController = new TextEditingController();
  bool _cargarFechaActual = true;
  static List<String> _categorias = [
    'Comida',
    'Combustible',
  ];
  String _opcionSeleccionada = _categorias[0];
  @override
  Widget build(BuildContext context) {
  if(_cargarFechaActual){
  _inputFieldDateController.text = _currentTime();
  }

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Gastos'),
      ),
      //floatingActionButton: _btnSave(),
      body: Container(
        child: Column(          
          children: <Widget>[
            // Campo fecha
            Divider(),
            _crearInputDate(context),
            //Campo Categoria
            Divider(),
            _crearComboBoxCategoria(),
            //Campo Importe
            Divider(),
            _crearInputNumber(),
            //Campo descripcion
            Divider(),
              Row(
              children: <Widget>[
                Expanded(
                child: _crearInputTextDescription(),
                ),
                Divider(indent: 10.0,),
                //_boton(),
                ],
            ),
          ],
        ),
      ),
    );
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
            _cargarFechaActual = false;
        _inputFieldDateController.text = _fecha;
      });
    }
  }


List<DropdownMenuItem<String>> getOpcions() {
    List<DropdownMenuItem<String>> lista = new List();
    _categorias.forEach((cat) {
      lista.add(DropdownMenuItem(
        child: Text(cat),
        value: cat,
      ));
    });
    return lista;
  }

  Widget _crearComboBoxCategoria() {
    return Row(
      children: <Widget>[
        Icon(Icons.all_inclusive),
        SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.0, style: BorderStyle.solid, color: Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            child: DropdownButton(
              icon: Icon(Icons.arrow_drop_down),
              value: _opcionSeleccionada,
              items: getOpcions(),
              onChanged: (opt) {
                setState(() {
                  _opcionSeleccionada = opt;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _crearInputTextDescription() {
    return TextField(
      
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(        
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: "Descripcion",
          icon: Icon(Icons.comment)),
      onChanged: (valor) {
        setState(() {
          _descripcion = valor;
        });
      },
    );
  }
  
  Widget _crearInputNumber() {
    return TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: "Importe",
          icon: Icon(Icons.attach_money)),
      onChanged: (valor) {
        setState(() {
          _importe = valor;
        });
      },
    );
  }

  String _currentTime(){
    var date = new DateTime.now();
    return date.year.toString() + "-" + date.month.toString() + "-" + date.day.toString();

  }

  Widget _boton(){    
    return FloatingActionButton.extended(
      label: Icon(Icons.camera_alt),
      foregroundColor: Colors.white,
      elevation: 0.0,
      backgroundColor: Colors.orangeAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
      onPressed: (){
        //Abrir galeria
      },
    );
  }

  FloatingActionButton _btnSave(){
    return FloatingActionButton(
      child: Icon(Icons.save),      
      onPressed: (){
        // Guardar datos
        print("Valores: $_fecha - $_importe - $_opcionSeleccionada - $_descripcion");
      },
    );
  }
}