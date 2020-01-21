import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:paycapp/src/pages/expense/show_expense_page.dart';
import 'package:paycapp/src/providers/expense_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
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
  @override
  Widget build(BuildContext context) {
    double heightDevice = MediaQuery.of(context).size.height;

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
            return _elements(context, expense, results, index);
          },
        );
      },
    );
  }

  Slidable _elements(context, expense, results, index) {
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        child: _tarjeta(
            date: DateTime.parse(expense["date"]),
            value: double.parse(expense["monto"]),
            category: expense["category"],
            index: expense["id"]),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Anular',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () async {},
          ),
        ]);
  }

  ListTile _tarjeta({DateTime date, String category, double value, int index}) {
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
            "\$ $value",
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Icon(Icons.keyboard_arrow_right,
              color: Theme.of(context).primaryColor),
        ],
      ),
      onTap: () {
        //print("Posicion: $index");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowExpensePage(id: index)));
      },
    );
  }

  Container _tarjeta2({DateTime date, String category, double value}) {
    return Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
          )
        ]),
        child: ClipRRect(
            child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    Text(
                      // "${date.day}",
                      "${DateFormat("dd").format(date)}",
                      style: TextStyle(
                        fontSize: 35,
                        color: Colors.orange,
                      ),
                    ),
                    Divider(
                      indent: 3.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${formatter.format(date)} ",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "$category",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    )
                  ],
                )),
            Expanded(
              flex: 1,
              child: Text(
                "\$ $value",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          ],
        )));
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
                    child:                   RaisedButton(
                    elevation: 0.0,
                    disabledTextColor: Colors.white,
                    color: colors['primaryDark'],
                    onPressed: () {
                      if (_dateTo == _dateFrom ||
                          DateTime.parse(_dateTo)
                              .isAfter(DateTime.parse(_dateFrom))) {
                        ExpenseProvider().list(
                            page: 1, dateTo: _dateTo, dateFrom: _dateFrom);
                        _actualizar = true;
                        _scaffoldKey.currentState
                            .showSnackBar(customSnack("Filtro aplicado"));
                        _retry();
                      } else {
                        _scaffoldKey.currentState.showSnackBar(customSnack(
                            "La fecha maxima no puede ser inferior a la minima",
                            type: 'err'));
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Aceptar",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              wordSpacing: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  ),
                  Divider(indent:  10.0,),
                  Expanded(
                    child:                   RaisedButton(
                    elevation: 0.0,
                    disabledTextColor: Colors.white,
                    color: colors['primaryDark'],
                    onPressed: () {
                      _dateFrom =_dateTo = "null";
                      _inputDateFrom.text = _inputDateTo.text = "";
                      _actualizar = true;
                      _retry();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Resetear",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              wordSpacing: 20.0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
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

  _retry() {
    setState(() {});
  }
}
