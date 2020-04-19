import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/pages/client/search_client_delegate.dart';

class CreditClientComponent extends StatefulWidget {
  final ValueChanged<Person> onChange; // onChange Prop
  final Person client;

  const CreditClientComponent({Key key, /* onChange init*/ this.onChange, this.client}) : super(key: key);
  @override
  _CreditClientComponentState createState() => _CreditClientComponentState();
}

class _CreditClientComponentState extends State<CreditClientComponent> {
  Person _client;
  TextEditingController _userField = TextEditingController();
  TextEditingController _dir = TextEditingController();
  TextEditingController  _tel = TextEditingController();
  TextEditingController  _telB = TextEditingController();
  TextEditingController  _mail = TextEditingController();

  @override
  void initState() {
    this._client = widget.client;
    this.rellenarDatos();
    super.initState();
  }

  @override
  void didUpdateWidget(CreditClientComponent oldWidget) {
    this._client = widget.client;
    this.rellenarDatos();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _clientField(context),
        _field(_dir, "Dirección", FontAwesomeIcons.solidAddressCard, maxLines: 2),
        _field(_tel, "Telefono Personal", FontAwesomeIcons.mobile),
        _field(_telB, "Telefono Trabajo", FontAwesomeIcons.phone),
        _field(_mail, "Email", FontAwesomeIcons.solidEnvelope),
        SizedBox(height: 20,),
        _info(),
      ],);
  }

  Widget _info () {
    if(_client == null) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _circleInfo("Puntos", (_client.rank == null ? 0 : _client.rank), Colors.blue),
        _circleInfo("Mora", (_client.mora == 1 ? 'SI' : 'NO'), ( _client.mora == 1 ? Colors.red:  Colors.green))
      ],
    );
  }

  Widget _circleInfo(String title, Object info, MaterialColor color){
    return Column(
      children: <Widget>[
        Text("$title", style: TextStyle(color: Colors.black45)),
        SizedBox(height: 10,),
        CircleAvatar(
          backgroundColor: color,
          foregroundColor: Colors.white,
          radius: 30,
          child: Text("$info",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
        ),
      ],
    );
  }

  _clientField(context) {
    return TextFormField(
      controller: _userField,
      //enabled: false,
      readOnly: true,
      textCapitalization: TextCapitalization.words,
      decoration: (_client != null)
          ? InputDecoration(
        labelText: 'Cliente',
        icon: Icon(FontAwesomeIcons.solidUser, color: Colors.orangeAccent,),
      )
          : InputDecoration(
        labelText: 'Seleccione cliente',
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        icon: Icon(FontAwesomeIcons.search, color: Colors.orangeAccent,),
      ),
      onTap: () {
        searchClient(context);
      },
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Seleccione un cliente';
        }
        return null;
      },
    );
  }

  _field(TextEditingController controller, label, IconData icon, {int maxLines: 1}){
    return TextFormField(
      readOnly: true,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        icon: Icon(icon, color: Colors.orangeAccent,),
      ),
    );
  }

  searchClient(context) async {
    var search = await showSearch(context: context, delegate: SearchClientDelegate());
    if (search == null) return;
    _client = search;
    widget.onChange(_client);
    this.rellenarDatos();
  }

  void rellenarDatos () {
    if (_client == null) return; // si no se tiene nada en cliente no se llena
    String name = "${_client.name} ${_client.surname}".toUpperCase();
    _userField.value = TextEditingValue(text: name);
    _dir.value = TextEditingValue(text: (_client.address ?? 'Ninguna' ));
    _tel.value = TextEditingValue(text: (_client.phones ?? '000000000' ));
    _telB.value = TextEditingValue(text: (_client.phones_b ?? '000000000' ));
    _mail.value = TextEditingValue(text: (_client.email ?? '' ));
    setState(() {});
  }  
}
