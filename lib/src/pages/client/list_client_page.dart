import 'package:flutter/material.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/providers/client_provider.dart';
import 'package:paycapp/src/utils/utils.dart';

class ListClient extends StatefulWidget {
  ListClient({Key key}) : super(key: key);

  @override
  _ListClientState createState() => _ListClientState();
}

class _ListClientState extends State<ListClient> {
  // List cliente = [];
  // List filtrosClientes = [];

  bool isSearching = false;
  String valueTosearch = "null";
  
  // getClients() async {
  //   var response = await ClientProvider().listOrSearch();
  //   return response.data;
  // }
  
  // void _filterClients(value) {
  //   setState(() {
  //     filtrosClientes = cliente
  //         .where((cliente) =>
  //             cliente['name'].toLowerCase().contains(value.toLowerCase()))
  //         .toList();
  //   });
  // }

  // @override
  // void initState() { 
  //   // getClients().then((data){
  //   //   setState(() {
  //   //     cliente = filtrosClientes = data;
  //   //   });
  //   // });
  //   super.initState();
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Clientes')
            : TextField(
                onSubmitted: (v) {},
                onChanged: (value) {

                  valueTosearch = value;
                  setState(() {
                    
                  });
                  // _filterCountries(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.white,),
                    hintText: "Buscar cliente",
                    hintStyle: TextStyle(color: Colors.white)),
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      valueTosearch = "null";
                      //llenar los datos con la busqueda
                      // filteredCountries = countries;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                )
        ],
      ),
      body: _creditList(),
    );
  }

  Widget _creditList() {
    return FutureBuilder(
      //lista del servidor
      future: ClientProvider().listOrSearch(search: isSearching, textToSearch: valueTosearch),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return renderError(snapshot.error, _retry);
        }

        if (!snapshot.hasData) return loader(text: "Cargando créditos...");

        var results = snapshot.data.data;

        if (results != null && results.length <= 0) {
          return renderNotFoundData("No hay creditos para mostrar");
        }

        return ListView.separated(
          separatorBuilder: (context, index) => Container(
            color: Colors.grey,
            height: 1.0,
            width: 0.0,
          ),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            var person = Person.fromJson(results[index]);
            return ListTile(
              leading: Icon(Icons.person,
                  size: 30, color: Theme.of(context).accentColor),
              title: Text(
                "${person.name} ${person.surname}".toUpperCase(),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text("${person.address}"),
              onTap: () {
                Navigator.pop(context, person);
                //close(context, person);
              },
            );
          },
        );
      },
    );
  }

  void _retry() {
    //locations.clear();
    setState(() {});
  }
}
