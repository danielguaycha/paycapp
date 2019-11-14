import 'package:flutter/material.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/providers/client_provider.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/utils/messages_util.dart' show notify, errMessage;
import 'package:paycapp/src/utils/progress_loader.dart';


class AddClientPage extends StatefulWidget {
  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {

  final _focusSurname = FocusNode();
  final _focusAddress = FocusNode();
  final _focusPhone = FocusNode();
  final _focusEmail = FocusNode();
  final _formKey = GlobalKey<FormState>();

  Person _client = new Person();
  ClientProvider _clientProvider = new ClientProvider();
  ProgressLoader _loader;
  String _msg = '';

  @override
  Widget build(BuildContext context) {

    _loader = new ProgressLoader(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar Cliente"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _nameField(context),
                _surnameField(),
                _addressField(),
                _phoneField(),
                _emailField(),
                SizedBox(height: 15),
                errMessage(msg: _msg)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Guardar Cliente',
        child: Icon(Icons.save, color: Colors.white),
        onPressed: () {
          if (!_formKey.currentState.validate()) return;
          _formKey.currentState.save();
          onSubmitClient(context);
        },
      ),
    );
  }

  /*Send Form for register client*/

  void onSubmitClient(context) async{
    setState(() => _msg = '');
    _loader.show(msg: 'Guardando cliente, espere...');
    Responser res = await _clientProvider.store(_client);
    if(res.ok) {  
      final _prefs = LocalStorage();
      _prefs.person = Person.fromJson(res.data);
      Navigator.of(context).pop();
    } else {
     setState(() {
       _msg = res.message;
     });
    }
    _loader.hide();
  }

  /*--------------------- fields ---------------------*/

  _nameField(context) {
    return TextFormField(
      initialValue: '',
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Nombre *',
        icon: Icon(Icons.account_circle),
      ),
      onFieldSubmitted: (v){ FocusScope.of(context).requestFocus(_focusSurname);},
      onSaved: (value) => _client.name = value,
      validator: (value) {
        if (value.trim() == '') {
          return 'Ingrese su nombre';
        }
        return null;
      },
    );
  }

  _surnameField() {
    return TextFormField(
      initialValue: '',
      focusNode: _focusSurname,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (v){ FocusScope.of(context).requestFocus(_focusAddress);},
      onSaved: (value) => _client.surname = value,
      validator: (value) {
        if (value.trim() == '') {
          return 'Ingrese apellido del cliente';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Apellido *',
        icon: Icon(Icons.perm_contact_calendar),
      ),
    );
  }

  _addressField() {
    return TextFormField(
      initialValue: '',
      focusNode: _focusAddress,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      keyboardType: TextInputType.multiline,
      onFieldSubmitted: (v){ FocusScope.of(context).requestFocus(_focusPhone);},
      onSaved: (value) => _client.address = value,
      validator: (value) {
        if (value.trim() == '') {
          return 'Ingrese dirección del cliente';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Dirección *',
        icon: Icon(Icons.room),
      ),
    );
  }

  _phoneField() {
    return TextFormField(
      initialValue: '',
      focusNode: _focusPhone,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (v){ FocusScope.of(context).requestFocus(_focusEmail);},
      onSaved: (value) => _client.phones = value,
      decoration: InputDecoration(
        labelText: 'Telf/Celular',
        icon: Icon(Icons.phone),
      ),
    );
  }

  _emailField() {
    return TextFormField(
      initialValue: '',
      focusNode: _focusEmail,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => _client.email = value,
      decoration: InputDecoration(
        labelText: 'Correo',
        icon: Icon(Icons.email),
      ),
    );
  }

}