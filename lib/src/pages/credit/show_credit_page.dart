import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/models/clientCredit_model.dart';
import 'package:paycapp/src/pages/maps/map_with_route.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/providers/credit_provider.dart';
import 'package:paycapp/src/utils/utils.dart' show loader, renderError, renderNotFoundData, money, dateForHumans, showImage;
import 'package:paycapp/src/models/show_credit_model.dart';
class ShowCreditPage extends StatefulWidget {

  final int id;

  ShowCreditPage({Key key, this.id}) : super(key: key);

  @override
  _ShowCreditPageState createState() => _ShowCreditPageState();
}

class _ShowCreditPageState extends State<ShowCreditPage> {
  ShowCredit _credit;
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         appBar: AppBar(
           title: Text("Crédito")           
         ),
         body: FutureBuilder(
           future: CreditProvider().getById(widget.id),
           builder: (context, snapshot) {
              if (snapshot.hasError) {
                return renderError(snapshot.error, () {}); //TODO: agregar la función para reintentar
              }
              if (!snapshot.hasData) return loader(text: "Cargando crédito...");
              
              _credit = snapshot.data;
              
              if (_credit == null) {
                return renderNotFoundData("No hay creditos para mostrar");
              }
              
              return _builderCredit(_credit, context);
           }
         ),
       ),
    );
  }

  Widget _builderCredit(ShowCredit credit, context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _boxes(info: "Monto I.", value: money(credit.monto), color: Theme.of(context).primaryColor),
                _boxes(info: "Utilidad", value: "${credit.utilidad.toStringAsFixed(0)}%", color: Colors.green),
                _boxes(info: "T. Utilidad", value: money(credit.totalUtilidad), color: Colors.blue[600]),
                _boxes(info: "Total", value: money(credit.total), color: Colors.purple),
              ],
            ),
            SizedBox(height: 5),
            _status(),            
            _payData(),  
            _creditData(),
            SizedBox(height: 10),
            _headerTitle("Credito creado: ${dateForHumans(_credit.createdAt)}"),
          ],
        ),
      ),
    );
  }


  Widget _status() {    
    Color c = Colors.blue[900];
    if(_credit.status == 0) c = Colors.red;
    if(_credit.status == 2) c = Colors.green;

    return Card(
      elevation: 0.5,
      child: Row(
        children: <Widget>[        
          Expanded(          
            child: Container(                                
              padding: EdgeInsets.all(8) ,
              child: Text("El credito esta: ${_credit.getStatus()}", style: TextStyle(color: c),),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(width: 1.0, color: Colors.grey[300]),
                )
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,               
            ),
            width: 100,
            child: Text("# Pagos: ${_credit.nPagos}", style: TextStyle(fontWeight: FontWeight.w600),)
          )
        ],
      ),
    );
  }

  Widget _payData() {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(        
          children: <Widget>[
            _headerTitle("DATOS DE PAGOS, COBROS y CLIENTE"),
            Row(
              children: <Widget>[
                Flexible(child: _input("Plazo", _credit.plazo)),
                SizedBox(width: 10),
                Flexible(child: _input("Cobro", _credit.cobro))
              ],
            ),
            _input("Detalle", _credit.description, lines: 2),
            SizedBox(height: 5),        
            _input("Cliente", "${_credit.clientName} ${_credit.clientSurname}"),
            _input("Dirección", _credit.address, lines: 2),
          ],
         
        ),
      ),
    );
  }

  Widget _creditData() {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(          
          children: <Widget>[
            _headerTitle("DATOS DEL CRÉDITO"),
            Row(
              children: <Widget>[
                Flexible(child: _input("F. Inicio", dateForHumans(_credit.fInicio))),
                SizedBox(width: 10),
                Flexible(child: _input("F. Fin", dateForHumans(_credit.fFin))),
              ],
            ),
            Row(
              children: <Widget>[
                Flexible(child: _input("Ruta", _credit.ruta)),
                Tooltip(
                  message: "Ver ubicación",
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.mapMarkerAlt), color: Colors.red, 
                    onPressed: _credit.geoLat == null ? null : () {
                      //TODO: Este código se repite con el de listar créditos: Revisar
                       List<DataClient> _dataClient = new List<DataClient>();
                      _dataClient.add(new DataClient( _credit.geoLat, _credit.geoLon,"${_credit.clientName} ${_credit.clientSurname}" , _credit.address, zone: _credit.ruta ));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapRoutePage(cliente: _dataClient)));
              
                    }
                  ),
                ),
                SizedBox(width: 10),
                Tooltip(
                  message: "Historial de pagos",
                  child: IconButton(
                    icon: Icon(FontAwesomeIcons.dollarSign), 
                    onPressed: () {
                         Navigator.push(context,MaterialPageRoute(builder: (context) => ListPaymentsPage(id: _credit.id)));
                    }
                  ),
                )
              ],
            ),
            SizedBox(height: 7),
            _referencia(),
            SizedBox(height: 7),
            _prenda()
          ],

        ),
      ),
    );
  }


  //* PARTIALS

  Widget _referencia() {
    if(_credit.refDetail == null && _credit.refImg == null) 
      return Container();

    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Container(
        width: 50.0,
        height: 50.0,
        child: showImage(_credit.refImg)
      ),
      title: Text("${(_credit.refDetail != null ? _credit.refDetail : 'Ninguna')}"),
      subtitle: Text("Referencia"),
      onTap: () {
          //TODO: Poner el visor de imagen aquí
      },
    );
  }

  Widget _prenda() {

    if(_credit.prenda != null && _credit.prenda.length > 0){
      return ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: Container(
          width: 50.0,
          height: 50.0,
          child: showImage(_credit.prenda[0].img),
        ),
        title: Text("${_credit.prenda[0].detail}"),
        subtitle: Text("Prenda"),
        onTap: () {
          // TODO: Poner el visor de imagen aqui 
        },
      );
    }    
    return Container();
  }

  Widget _boxes({info: "", value: "", color: Colors.grey}) {
    return Container(      
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: color,
      ),
      child: Column(
        children: <Widget>[
          Text("$value", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: Theme.of(context).textTheme.subhead.fontSize)),
          Text("$info", style: TextStyle(color: Colors.white60),)
        ],
      )
    );   
  }

  Widget _input(String label, dynamic value, {lines: 1}) {
    return  TextFormField( 
        autofocus: false,               
        readOnly: true,
        initialValue: value,
        minLines: 1,
        maxLines: lines,
        style: TextStyle(fontSize: Theme.of(context).textTheme.body1.fontSize),
        decoration: InputDecoration(labelText: "$label", isDense: true),    
    );
  }

  Widget _headerTitle(String title) {
    return Text("$title",style: TextStyle(color: Colors.black54, fontSize: Theme.of(context).textTheme.overline.fontSize));
  }
}