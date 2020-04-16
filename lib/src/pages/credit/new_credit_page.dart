import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/credit_model.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/pages/client/add_client_page.dart';
import 'package:paycapp/src/pages/client/search_client_delegate.dart';
import 'package:paycapp/src/pages/credit/_pages/credit_calc_component.dart';
import 'package:paycapp/src/pages/credit/_pages/credit_client_component.dart';
import 'package:paycapp/src/pages/credit/_pages/credit_extra_component.dart';
class NewCreditPage extends StatefulWidget {
  @override
  _NewCreditPageState createState() => _NewCreditPageState();
}

class _NewCreditPageState extends State<NewCreditPage> {
  int _currentStep = 0;
  bool _completeSteps = false;
  List<Step> spr = <Step>[];

  Person _client;
  Credit _credit;

  _setClient(Person client) {
    setState(() {
      _client = client;
    });
  }

  @override
  void initState() {
    this._credit = new Credit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: Text('Agregar Crédito'),
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Stepper(
              steps: _getSteps(context),
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => goTo(step),
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

  Widget _floatings(context) {
    if (_currentStep == 0) {
      return _floatingForClient(context);
    }
    else if (_currentStep == 1) {
      return _floatingForCredit();
    }
    else {
      return Container();
    }

  }

  Widget _floatingForCredit() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _minBtn(
            onPressed: () {goTo(0);}
        ),
        SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () {
              next();
          },
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child:  Icon(Icons.done),
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
            icon: FontAwesomeIcons.userPlus,
            onPressed: () async {
              _client = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddClientPage()));
              _setClient(_client);
            }
        ),
        SizedBox(height: 15),
        FloatingActionButton(
          onPressed: () async {
            if (_client == null) {
              _client = await showSearch(context: context, delegate: SearchClientDelegate());
              _setClient(_client);
            }
            else
              next();
          },
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          child: (_client != null) ? Icon(Icons.done) : Icon( Icons.search),
        )
      ],
    );
  }

  Widget _minBtn({IconData icon: FontAwesomeIcons.arrowLeft, @required Function onPressed }) {
    return RawMaterialButton(
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
          isActive: _currentStep == 0 ),
      Step(
          title: const Text('Credito'),
          content: CreditCalcComponent(
            credit: _credit,
          ),
          state: _getState(1),
          isActive: _currentStep == 1),
      Step(
          title: const Text('Referencia'),
          subtitle: Text('Prenda'),
          content: CreditExtraComponent(credit: _credit),
          state: _getState(2),
          isActive: _currentStep == 2),
    ];
    return spr;
  }

  /*Steeps Fucntions*/
  StepState _getState(int i) {
    if(_currentStep == i)
      return StepState.editing;
    if (_currentStep >= i)
      return StepState.complete;
    else
      return StepState.indexed;
  }
  next() {
    _currentStep + 1 != spr.length
        ? goTo(_currentStep + 1)
        : setState(() => _completeSteps = true);
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
