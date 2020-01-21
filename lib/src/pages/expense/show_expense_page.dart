import 'package:flutter/material.dart';

class ShowExpensePage extends StatefulWidget {
  int id;
  ShowExpensePage({Key key, @required this.id}) : super(key: key);

  @override
  _ShowExpensePageState createState() => _ShowExpensePageState();
}

class _ShowExpensePageState extends State<ShowExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

       body: Center(child: Text("${widget.id}"),),
    );
  }
}