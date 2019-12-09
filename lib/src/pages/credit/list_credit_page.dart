import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/credit/show_credit_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart'
    show renderError, loader, renderNotFoundData;

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
      appBar: AppBar(title: Text("Créditos")),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowCreditPage(id: credit['id'])));
                  },
                ),
                actions: <Widget>[                 
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
}
