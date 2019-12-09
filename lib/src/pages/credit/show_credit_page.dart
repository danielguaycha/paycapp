import 'package:flutter/material.dart';

class ShowCreditPage extends StatefulWidget {
  final int id;
  ShowCreditPage({Key key, @required this.id}) : super(key: key);

  @override
  _ShowCreditPageState createState() => _ShowCreditPageState();
}

class _ShowCreditPageState extends State<ShowCreditPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ver crédito'),
      ),
      body: Center(
        child: Text('${widget.id}'),
      ),
    );
  }
}