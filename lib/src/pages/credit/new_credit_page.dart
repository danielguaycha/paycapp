import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/responser.dart';
import 'package:paycapp/src/pages/client/add_client_page.dart';
import 'package:paycapp/src/pages/client/search_client_delegate.dart';
import 'package:paycapp/src/pages/credit/_components/credit_calc_component.dart';
import 'package:paycapp/src/pages/credit/_components/credit_client_component.dart';
import 'package:paycapp/src/pages/credit/_components/credit_extra_component.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/messages_util.dart';
import 'package:paycapp/src/utils/progress_loader.dart';
import 'package:paycapp/src/utils/utils.dart';
class NewCreditPage extends StatefulWidget {
  @override
  _NewCreditPageState createState() => _NewCreditPageState();
}

class _NewCreditPageState extends State<NewCreditPage> {
  int _currentStep = 0;
  bool _completeStep = false;
  List<Step> spr = <Step>[];

  Person _client;
  Credit _credit;
  bool _geoloc;
  final _scaffoldKey = GlobalKey<ScaffoldState>();    
  List<bool> _stepError = [false, false, false];
  ProgressLoader _loader;

  _setClient(Person client) {    
    if(client == null) return;    
    setState(() {
      _client = client;
      _credit.address = (client.address == null ? "": client.address);
    });
  }

  @override
  void initState() {
    this._credit = new Credit();
    this._geoloc = true;    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _loader = new ProgressLoader(context);
    return  Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Agregar Crédito'),
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Stepper(
              steps: _getSteps(context),
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) {                
                _markState(step);
                goTo(step);
              },              
              controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Row(children: <Widget>[Container(child: null,), Container(child: null,),],);
              },
            ),
          ),
        ]),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only( bottom: 10.0, right: 0),
          child: _floatings(context),
        )
    );
  }

  void _submitCredit(context) async {      
      if(!_validateFrm()) return;  
      int isOk = await Alert.confirm(context,
        title: "Confirmar",
        content: "¿Está seguro que desea guardar este crédito?\nMonto: ${money(_credit.monto)} | Utilidad: ${_credit.utilidad}\nPlazo: ${_credit.plazo}\nCobro: ${_credit.cobro}\nCliente: ${_client.name} ");
      if (isOk == 1) {
        return;
      }   
      _loader.show(msg: "Procesando crédito, espere");

    if (_geoloc) {
      final loc = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _credit.geoLat = loc.latitude;
      _credit.geoLon = loc.longitude;
    }

    _credit.personId = _client.id;

    Responser res = await CreditProvider().store(_credit);

    if (res.ok) {
      _credit = new Credit();
      _client = null;
      _scaffoldKey.currentState
          .showSnackBar(customSnack("Crédito procesao con exito"));
        goTo(0);
    } else {
      _scaffoldKey.currentState
          .showSnackBar(customSnack(res.message, type: 'err'));
    }
    _loader.hide();
  }

  //? Función de validación
  bool _validateFrm() {
    if(_client == null || _client.id == null) {
      _showErrorTo("Seleccione un cliente", 0);
      return false;
    }

    if(_credit.monto == null) {
      _showErrorTo("Ingrese un monto", 1);
      return false;
    }    

    if(_credit.monto  <= 0) {
      _showErrorTo("El monto debe ser mayor a 0", 1);
      return false;
    }
    
    if(_credit.plazo == null) {
      _showErrorTo("Ibgrese el plazo del crédito", 1);
      return false;
    }

    if(_credit.cobro == null) {
      _showErrorTo("Seleccione el periodo de recaudación", 1);
      return false;
    }

    if(_credit.utilidad == null) {
      _showErrorTo("Seleccione la utilidad", 1);
      return false;
    }

    if(_credit.rutaId == null || _credit.rutaId == 0) {
      _showErrorTo("Escoja una ruta/zona", 2);
      return false;
    }

    return true;
  }

  // Mostrar Errores

  void _showErrorTo(String msg, int step, {String type: "err"}) {
     _scaffoldKey.currentState
          .showSnackBar(customSnack("$msg", seconds: 3,
                          type: '$type', action: SnackBarAction(label: "Ir", textColor: Colors.white, onPressed: () => goTo(0)  )));
  }

  Widget _floatings(context) {
    if (_currentStep == 0) {
      return _floatingForClient(context);
    }
    else if (_currentStep == 1) {
      return _floatingForCredit();
    }
    else {
      return _floatingForExtra(context);
    }

  }

  Widget _floatingForCredit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _minBtn(
            onPressed: () {goTo(0);},
            tooltip: "Regresar a clientes",
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
              _markState(_currentStep+1);
              next();
          },
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child:  Icon(Icons.done),
          tooltip: 'Siguiente',
        )
      ],
    );
  }

  // botones flotantes para el paso de clientes
  Widget _floatingForClient(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _minBtn(
            tooltip: "Agregar cliente",
            icon: FontAwesomeIcons.userPlus,
            onPressed: () async {
              var client = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddClientPage()));
              if(client != null)
                _setClient(client);
            }
        ),
        SizedBox(height: 15),
        FloatingActionButton(
          onPressed: () async {
            if (_client == null) {
              var client = await showSearch(context: context, delegate: SearchClientDelegate());              
              if(client!=null)
                _setClient(client);
            }
            else{
              _markState(_currentStep+1);
              next();
            }
          },
          tooltip: _client != null ? 'Siguiente': 'Buscar cliente',
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: (_client != null) ? Icon(Icons.done) : Icon( Icons.search),
        )
      ],
    );
  }

  // botones Flotantes para Extra
  Widget _floatingForExtra(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _minBtn(
            tooltip: "Regresar a crédito",
            onPressed: () {goTo(1);}
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
            _submitCredit(context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          tooltip: 'Guardar Crédito',
          child:  Icon(FontAwesomeIcons.solidPaperPlane),
        )
      ],
    );
  }

  Widget _minBtn({IconData icon: FontAwesomeIcons.arrowLeft, @required Function onPressed, String tooltip: '' }) {
    return Tooltip(
      message: tooltip,
      child: RawMaterialButton(
        onPressed: onPressed,
        child: new Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 17.0,        
        ),  
        shape: new CircleBorder(),
        constraints: BoxConstraints(minHeight: 35, minWidth: 35),
        elevation: 7,
        fillColor: Colors.grey[300],
        padding: const EdgeInsets.all(10.0),
      ),
    );
  }

  List<Step> _getSteps(BuildContext context) {
    spr = <Step>[
      Step(
          title: const Text('Cliente'),
          content: CreditClientComponent(
            client: _client,
            onChange: _setClient,
          ),
          state: _getState(0),
          isActive: _currentStep >= 0  ),
      Step(
          title: const Text('Credito'),
          content: CreditCalcComponent(          
              credit: _credit,
          ),
          state: _getState(1),
          isActive: _currentStep >= 1),
      Step(
          title: const Text('Referencia'),
          subtitle: Text('Prenda'),
          content: CreditExtraComponent(credit: _credit, geoLoc: _geoloc),
          state: _getState(2),
          isActive: _currentStep == 2),
    ];
    return spr;
  }

  // *teeps Fucntions
  
  StepState _getState(int i) {
    if(_currentStep == i)
      return StepState.editing;
    if (_currentStep >= i){
      if(_stepError[i] == true) {
        return StepState.error;
      }
      return StepState.complete;
    }      
    else
      return StepState.indexed;
  }
  
  _markState(step) {
    if(step >= 1 && _client == null) {
      _stepError[0] = true;                  
    } else {
      _stepError[0] = false;
    }

    if(step == 2 && _credit.monto == null || _credit.plazo == null || _credit.utilidad == null || _credit.cobro == null || _credit.monto <= 0) {                  
      _stepError[1] = true;
    } else {
      _stepError[1] = false;
    }
  }

  next() {
    _currentStep + 1 != spr.length
        ? goTo(_currentStep + 1)
        : setState(() => _completeStep = true);
  }
  
  cancel() {
    if (_currentStep > 0) {
      goTo(_currentStep - 1);
    }
  }
  
  goTo(int step) {
    setState(() => _currentStep = step);
  }
}
