import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/config.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/utils/utils.dart';
import 'package:intl/intl.dart';

class CreditCalcComponent extends StatefulWidget {

  final Credit credit;

  CreditCalcComponent({Key key, this.credit});

  @override
  _CreditCalcComponentState createState() => _CreditCalcComponentState();
}

class _CreditCalcComponentState extends State<CreditCalcComponent> {
  DateFormat formatter = new DateFormat('yyyy-MM-dd');
  TextEditingController _txtMonto = TextEditingController();
  TextEditingController _txtDate = new TextEditingController();
  Credit _credit;

  FocusNode _inputMonto = new FocusNode();
  FocusNode _node = new FocusNode();

  @override
  void initState() {
    _credit = widget.credit;
    _txtMonto.value = TextEditingValue(text: (_credit.monto != 0 ) ? _credit.monto.toString() : '0'); //
    if(_credit.fInicio != null)
      _txtDate.value = TextEditingValue(text: formatter.format(_credit.fInicio));
    _inputMonto.addListener(() {
      if(_inputMonto.hasFocus) {
        _txtMonto.selection = TextSelection(baseOffset:0, extentOffset:_txtMonto.text.length);
      }
    });
    super.initState();
  }

  void _calcular() {
    setState(() {
      _credit.calcular();
    });
  }

  Widget _montoField() {
    return TextFormField(
      controller: _txtMonto,    
      autovalidate: true,
      focusNode: _inputMonto,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Monto ${money("")} *',
        hintText: money("0.0"),
        icon: Icon(FontAwesomeIcons.dollarSign, color: Colors.orange),
      ),
      onFieldSubmitted: (v) {},
      onSaved: (v) => this._credit.monto = double.parse(v),
      onChanged: (v) {
        if (isNumeric(v)) {
          this._credit.monto = double.parse(v);
          _calcular();
        }
      },
      validator: (v) {
        if (!isNumeric(v)) {
          return "El monto ingresado no es válido";
        }
        if (double.parse(v) < 0) {
          return 'El monto debe ser mayor a 0';
        }
        return null;
      },
    );
  }

  // Plazo
  Widget _comboPlazo(context) {
    return _focus(
            child: DropdownButtonFormField(
              value: _credit.plazo,
              isDense: true,
              items: listItems(plazos),              
              itemHeight: 50.0,
              decoration: InputDecoration(
                icon: Icon(FontAwesomeIcons.calendarWeek, color: Colors.orange,),
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
                  //_changeCobro = true;
                });
                _calcular();
              },
        )
    );
  }

  // Cobro
  Widget _comboCobro(context) {
    return _focus(
      child: DropdownButtonFormField(
        value: _credit.cobro,
        // hint: new Text("Tipo de cobro"),
        items: listItems(cobros),
        isDense: true,
        decoration: InputDecoration(
            icon: Icon(FontAwesomeIcons.calendarTimes, color: Colors.orange,), labelText: 'Recaudación'),
        onSaved: (v) => _credit.cobro = v,
        validator: (v) {
          if (v == null || v == '') return 'Selecciona un periodo de recaudación';
          return null;
        },
        onChanged: (opt) {
          setState(() {
            _credit.cobro = opt;
            //_changeCobro = false;
          });
          _calcular();
        },
      ),
    );
  }

  // utilidad
  Widget _comboUtilidad(context) {
        return _focus(
          child: DropdownButtonFormField(
            value: _credit.utilidad,
            isDense: true,
            items: listItemsNormal(utilidad, '%'),
            decoration: InputDecoration(
                icon: Icon(FontAwesomeIcons.percent, size: 19, color: Colors.orange), labelText: 'Utilidad %'),
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
        );
  }

  // fecha
  Widget _crearInputDate(BuildContext context) {
    return Stack(
      alignment: const Alignment(1.0, 0),    
      children: <Widget>[
        TextField(
          enableInteractiveSelection: false,
          controller:  _txtDate,
          decoration: InputDecoration(
              labelText: 'Fecha de Inicio',
              helperText: (_credit.fInicio != null ? "El día que iniciarán los cobros" : "Dejar en blanco, si el prestamo se hace hoy"),
              hintText: "Fecha ",
              icon: Icon(FontAwesomeIcons.calendarDay, color: Colors.orange),               
          ),    
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            _datePicker(context);
          },
        ),
        IconButton(
        onPressed: _credit.fInicio != null ? () {
          _credit.fInicio = null;
          _txtDate.clear();
          _credit.dateEnd();
          setState(() {});
        }: null,
        icon: Icon(Icons.clear),
        iconSize: 20.0,
        )
      ],
    );
  }

  _datePicker(BuildContext context) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: _credit.fInicio == null ? DateTime.now() : _credit.fInicio,
      firstDate: new DateTime.now().subtract(new Duration(days: 3)),
      lastDate: new DateTime(2030),
      locale: Locale('es', 'ES'),
    );
    if (picked != null) {
        _credit.fInicio = picked;
        _txtDate.value = TextEditingValue(text: formatter.format(_credit.fInicio));
       _credit.dateEnd();
    }
  }

  /*CÁLCULOS*/
  Widget _calcContainer(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _circleInfo("# Pagos", _credit.npagos, Colors.red[900]),              
            _circleInfo("T. Utilidad", money(_credit.totalUtilidad), Colors.blueGrey[600]),
            _circleInfo("Fecha de Fin", dateForHumans(_credit.fFin), Colors.black38),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _circleInfo("Cuotas", money(_credit.pagosDe), Colors.blue,
                extra: (_credit.pagosDeLast!=null) ? "${money(_credit.pagosDeLast)}" : ''
            ),
            _circleInfo("Total", money(_credit.total), Colors.green)
          ],
        ),
      ],
    );
  }

  Widget _circleInfo(String title, Object info, Color color, {String extra: ''}){
    return
        Container(
          padding: EdgeInsets.all(2.5),
          margin: EdgeInsets.only(top: 2, bottom: 2),
          constraints: BoxConstraints.tightFor(width: 120, height: 62),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(7))
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("$title", style: TextStyle(color: Colors.black45)),
              Text("$info",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: color),
              ),
              (extra != '\$ 0.00') ? Text("$extra", style: TextStyle(fontSize: 10)) : Container(child: null,)
            ],
          ),
        );
  }

  // focus
  Widget _focus ({Widget child}) {
    return Focus(
      focusNode: _node,
      onFocusChange: (bool focus) {setState((){});},
      child: Listener(
        onPointerDown: (_) { FocusScope.of(context).requestFocus(_node);},
        child: child
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
       child: Column(
         children: <Widget>[
           _montoField(),
           SizedBox(height: 12),
           _comboPlazo(context),
           SizedBox(height: 12),
           _comboCobro(context),
           SizedBox(height: 12),
           _comboUtilidad(context),
           SizedBox(height: 12),
           _crearInputDate(context),
           SizedBox(height: 5),
           _calcContainer(context),           
         ],
       ),
    );
  }
}
