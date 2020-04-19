import 'package:flutter/material.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/pages/credit/_components/credit_calc_component.dart';

class CalcCreditPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora de créditos"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CreditCalcComponent(credit: new Credit()),
        ),
      ),
    );
  }
}
