import 'package:flutter/material.dart';
import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/providers/client_provider.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/utils/utils.dart'
    show loader, renderError, renderNotFoundData;

class SearchClientDelegate extends SearchDelegate<Person> {
  final ClientProvider c = new ClientProvider();
  final _prefs = LocalStorage();

  SearchClientDelegate()
      : super(
            searchFieldLabel: 'Buscar Cliente',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);

    return ThemeData(
        primaryColor: Theme.of(context).primaryColor,
        inputDecorationTheme: InputDecorationTheme(
            hintStyle: TextStyle(color: Colors.white60),
            fillColor: Colors.white),
        textTheme:
            TextTheme(title: TextStyle(color: Colors.white, fontSize: 17)),
        appBarTheme: AppBarTheme(color: Theme.of(context).primaryColor));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if(query.isNotEmpty)
            query = '';
          else close(context, null);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {

      return Center(
        child: FutureBuilder(
          future: c.search(query),
          builder: (context, snapshot) {

            if (snapshot.hasError) {
              return renderError(snapshot.error, null);
            }

            if (!snapshot.hasData)
              return loader(text: "Buscando cliente, espere...");

            var results = snapshot.data.data;

            if (results != null && results.length <= 0) {
              return renderNotFoundData(
                  "No se encontró resultados para tu busqueda!");
            }

            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var person = Person.fromJson(results[index]);
                return ListTile(
                  leading: Icon(Icons.person,
                      size: 30, color: Theme.of(context).accentColor),
                  trailing:
                      Icon(Icons.add, color: Theme.of(context).primaryColor),
                  title: Text(
                    "${person.name} ${person.surname}".toUpperCase(),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text("${person.address}"),
                  onTap: () {
                    close(context, person);
                  },
                );
              },
            );
          },
        ),
      );
    }
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: <Widget>[
        _getLastClient(context),
        ListTile(
          leading: Icon(Icons.person_add),
          title: Text('Nuevo Cliente'),
          onTap: () {
            Navigator.of(context).pushNamed('client_add');
          },
        ),
        ListTile(
          leading: Icon(Icons.arrow_back),
          title: Text('Regresar'),
          onTap: () {
            close(context, null);
          },
        ),
      ],
    );
  }

  Widget _getLastClient(context) {
    final Person person = _prefs.person;
    if (person != null)
      return ListTile(
        leading:
            Icon(Icons.person, size: 30, color: Theme.of(context).accentColor),
        trailing: Icon(Icons.add, color: Theme.of(context).primaryColor),
        title: Text(
          "${person.name} ${person.surname}".toUpperCase(),
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text("${person.address}"),
        onTap: () {
          close(context, person);
        },
      );
    else
      return Center();
  }


}
