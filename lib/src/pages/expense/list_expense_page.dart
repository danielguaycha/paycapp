import 'package:backdrop/backdrop.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/expense/show_expense_page.dart';
import 'package:paycapp/src/providers/expense_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart';
import 'package:intl/intl.dart';
import '../../config.dart';

//Variables
String _dateFrom = "null";
String _dateTo = "null";
DateFormat formatter = new DateFormat('yyyy-MM');
TextEditingController _inputDateFrom = new TextEditingController();
TextEditingController _inputDateTo = new TextEditingController();
 
class ListExpensePage extends StatefulWidget {
  ListExpensePage({Key key}) : super(key: key);

  @override
  _ListExpensePageState createState() => _ListExpensePageState();
}

class _ListExpensePageState extends State<ListExpensePage> {
  bool _actualizar = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textEditingController = new TextEditingController();
  String _reason = "";
  ProgressLoader _loader;
  //Lista infinita
  List<dynamic> gastosObjeto = new List();

  @override
  Widget build(BuildContext context) {
    double heightDevice = MediaQuery.of(context).size.height;
    _loader = new ProgressLoader(context);
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _addExpense(),
      body: BackdropScaffold(
        stickyFrontLayer: true,
        headerHeight: heightDevice / 3,
        title: Text("Lista de gastos"),
        backLayer: _backLayer(),
        frontLayer: _expenseList(),
        iconPosition: BackdropIconPosition.action,
        frontLayerBorderRadius: BorderRadius.only(
          topLeft: Radius.circular(0.0),
          topRight: Radius.circular(0.0),
        ),
      ),
    );
  }

  Widget _expenseList() {
    return FutureBuilder(
      //lista del servidor
      future: _actualizar
          ? ExpenseProvider()
              .list(page: 1, dateFrom: _dateFrom, dateTo: _dateTo)
          : null,
      builder: (context, snapshot) {
        _actualizar = false;

        if (snapshot.hasError) {
          return renderError(snapshot.error, _retry);
        }

        if (!snapshot.hasData) return loader(text: "Cargando gastos...");

        var results = snapshot.data.data;
        if (results != null && results.length <= 0) {
          return renderNotFoundData("No hay gastos para mostrar");
        }
        return ListView.separated(
          separatorBuilder: (context, index) => Container(
            height: 0.0,
            width: 0.0,
          ),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            var expense = (results[index]);
            return _elements(context, expense);
          },
        );
      },
    );
  }

  Slidable _elements(context, expense) {
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        child: _tarjeta(
            date: DateTime.parse(expense["date"]),
            value: double.parse(expense["monto"]),
            category: expense["category"],
            expense: expense),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Anular',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {
              _actualizar = await _invalidateExpense(expense["id"], _reason, context);
              _retry();
            },
          ),
        ]);
  }

  ListTile _tarjeta({DateTime date, String category, double value, var expense}) {
    return ListTile(
      leading: Text(
        "${DateFormat("dd").format(date)}",
        style: TextStyle(
          fontSize: 35,
          color: Colors.orange,
        ),
      ),
      title: Text(
        "${formatter.format(date)}",
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
      ),
      subtitle: Text(
        "$category",
        style: TextStyle(
          fontSize: 20,
          color: Colors.black87,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            money(value),
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Icon(Icons.keyboard_arrow_right,
              color: Theme.of(context).primaryColor),
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowExpensePage(expenseValue: expense)));
      },
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
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _crearInputDate(context, dateOld: true),
              Divider(),
              _crearInputDate(context, dateOld: false),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _raisedButton(label: "Aceptar", reset: false),
                  ),
                  Divider(
                    indent: 10.0,
                  ),
                  Expanded(
                    child: _raisedButton(label: "Resetear" , reset: true),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton _raisedButton({label = "", reset = true}) {
    return RaisedButton(
      child: Text( "$label",
      style: TextStyle(
        color: Colors.white, fontSize: 18.0, wordSpacing: 20.0, fontWeight: reset ? FontWeight.bold : FontWeight.normal ,),
        textAlign: TextAlign.center,
          ),
      elevation: 0.0,
      disabledTextColor: Colors.white,
      color: reset ? Colors.transparent : colors['primaryDark'],
      onPressed: reset ? _funcionReset : _funcionAceptar,
    );
  }

  void _funcionAceptar(){
        if (_dateTo != "null" && _dateFrom != "null") {
          if (_dateTo == _dateFrom ||
              DateTime.parse(_dateTo).isAfter(DateTime.parse(_dateFrom))) {
            ExpenseProvider()
                .list(page: 1, dateTo: _dateTo, dateFrom: _dateFrom);
            _actualizar = true;
            _scaffoldKey.currentState
                .showSnackBar(customSnack("Filtro aplicado"));
            _retry();
          } else {
            _scaffoldKey.currentState.showSnackBar(customSnack(
                "La fecha maxima no puede ser inferior a la minima",
                type: 'err'));
          }
        } else {
          _scaffoldKey.currentState.showSnackBar(customSnack(
              "Debe seleccionar fechas para aplicar el filtro",
              type: 'err'));
        }
  }

  void _funcionReset(){
    _dateFrom = _dateTo = "null";
    _inputDateFrom.text = _inputDateTo.text = "";
    _actualizar = true;
    _retry();
  }

  Widget _crearInputDate(BuildContext context, {dateOld = true}) {
    return Card(
      elevation: 0.0,
      color: Colors.transparent,
      shape: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      child: TextField(
        style: TextStyle(color: Colors.white),
        enableInteractiveSelection: false,
        controller: dateOld ? _inputDateFrom : _inputDateTo,
        decoration: new InputDecoration(
            labelText: dateOld ? "Filtro desde" : "Filtro hasta",
            labelStyle: TextStyle(color: Colors.white),
            icon: Icon(
              Icons.calendar_today,
              color: Colors.white,
            )),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
          _selecionarFecha(context, dateOld: dateOld);
        },
      ),
    );
  }

  _selecionarFecha(BuildContext context, {dateOld = true}) async {
    DateTime picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2000),
      lastDate: new DateTime.now(),
      locale: Locale('es', 'ES'),
    );

    if (picked != null) {
      if (dateOld) {
        _dateFrom = new DateFormat("yyyy-MM-dd").format(picked);
        _inputDateFrom.text = _dateFrom;
      } else {
        _dateTo = new DateFormat("yyyy-MM-dd").format(picked);
        _inputDateTo.text = _dateTo;
      }
      _retry();
    }
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

  // Anular gastos
  Future<bool> _invalidateExpense(expenseId, reason, context) async {
    int isOk = await Alert.confirm(context,
        title: "Anular Gasto",
        content: "¿Está seguro que desea anular este gasto?");
    if (isOk == 1) {
      return false;
    }
    if (expenseId <= 0) {
      Scaffold.of(context).showSnackBar(
          customSnack("No se ha podido anular este pago", type: 'err'));
      return false;
    }

    await _displayDialog(context);
    _loader.show(msg: "Anulando gasto");
    print("Fura de la peticion: $_reason");
    Responser res = await ExpenseProvider().invalidate(expenseId, _reason);
    if (res.ok) {
      Scaffold.of(context)
          .showSnackBar(customSnack("Gasto anulado con exito"));
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

  _retry() {
    setState(() {});
  }
}
