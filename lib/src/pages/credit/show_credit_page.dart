import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/utils.dart' show loader, renderError, renderNotFoundData, money;
import 'package:paycapp/src/models/show_credit_model.dart';
class ShowCreditPage extends StatefulWidget {

  final int id;

  ShowCreditPage({Key key, this.id}) : super(key: key);

  @override
  _ShowCreditPageState createState() => _ShowCreditPageState();
}

class _ShowCreditPageState extends State<ShowCreditPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         appBar: AppBar(
           title: Text("Ver Crédito")           
         ),
         body: FutureBuilder(
           future: CreditProvider().getById(widget.id),
           builder: (context, snapshot) {
              if (snapshot.hasError) {
                return renderError(snapshot.error, () {}); //TODO: agregar la función para reintentar
              }
              if (!snapshot.hasData) return loader(text: "Cargando crédito...");
              
              ShowCredit credit = snapshot.data;
              
              if (credit == null) {
                return renderNotFoundData("No hay creditos para mostrar");
              }
              
              return _builderCredit(credit);
           }
         ),
       ),
    );
  }

  Widget _builderCredit(ShowCredit credit) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            _boxes(info: "Total", value: money(credit.total))
          ],
        ),
      ),
    );
  }

  Widget _boxes({info: "", value: ""}) {
    return Container(
      
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(7)),
        color: Colors.red,
      ),
      child: Column(
        children: <Widget>[
          Text("$value", style: TextStyle(color: Colors.white),),
          Text("$info", style: TextStyle(color: Colors.white60),)
        ],
      )
    );   
  }
}