import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/client_provider.dart';
import 'package:paycapp/src/utils/utils.dart';
class IndexClientPage extends StatefulWidget {
  @override
  _IndexClientPageState createState() => _IndexClientPageState();
}

class _IndexClientPageState extends State<IndexClientPage> {

  int _page = 0;
  int _limit = 20;

  List<dynamic> _clients = new List();
  ClientProvider _provider = new ClientProvider();
  ScrollController _scontroller = new ScrollController(); // controlar el scroll

  bool _loaderPaginate = false;
  bool _loader = false;

  @override
  void initState() {
    super.initState();
    _addClients(paginate: false);
    _scontroller.addListener((){
      if (_scontroller.position.pixels == _scontroller.position.maxScrollExtent) {
        if (_loaderPaginate == false) {
          _addClients( paginate: true);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Lista clientes'),
          actions: <Widget>[
            _crearLoader(),
          ],
        ),
        body: Stack(children: <Widget>[
          _crearListaClientes(),
        ],)
    );
  }

  Widget _crearListaClientes () {
    if(_loader) return loader(text: "Cargando clientes");
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        controller: _scontroller,
        itemCount: _clients.length,
        itemBuilder: (BuildContext context, int index) {
          var client = (_clients[index]);
          return ListTile(
            title: Text("$index - ${client['id']} - ${client['name']}"),
          );
        },
      ),
    );
  }

  _addClients ({paginate: false}) async{
      _page++;
      if(paginate)
        _loaderPaginate = true; //? Si se está paginando activa su loader
      else
        _loader = true; // Si no, activa el loader normal

      setState(() {});

      Responser res = await _provider.list(page: _page, limit: _limit);
      if(res.ok) {
        var data = res.data;
        for(var i = 0; i<data.length; i++) {
          _clients.add(data[i]);
        }
      }
      if(paginate) {
          _loaderPaginate = false;
          _scontroller.animateTo(
              _scontroller.position.pixels+150,
              curve: Curves.fastOutSlowIn,
              duration: new Duration(milliseconds: 240)
          );
      } else {
        _loader = false;
      }
      setState(() {});
  }

  Widget _crearLoader() {
    if (_loaderPaginate) {
      return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Future refresh() async {
    Completer<Null> completer = new Completer<Null>();
    _page=0;
    _clients.clear();
    await _addClients(paginate: false);
    completer.complete();
    return completer.future;
  }
}
