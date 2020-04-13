// Flutter code sample for ExpansionPanelList

// Here is a simple example of how to implement ExpansionPanelList.

import 'package:flutter/material.dart';
import 'package:paycapp/src/pages/payments/payments_widgets.dart';

// stores ExpansionPanel state information
class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List.generate(numberOfItems, (int index) {
    return Item(
      headerValue: 'Panel $index',
      expandedValue: 'This is item number $index',
    );
  });
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  List<Item> _data = generateItems(4);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body:
          Container(child: 
          ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: 4,
          itemBuilder: (context, index) {
            // var payment = results['diario'][index];
            // print("${payment['client_name']}");
            return slideableForPyments(
                idPago: "1",
                name: "payment['client_name']",
                surname: "payment['client_surname']",
                addres: "payment['address']",
                state: "payment['status'].toString()",
                value: "payment['total'].toString()",
                retry: null,
                context: context,
                scaffoldKey: null,
                showDetail: true);
          },
        )
          ),
          //  ListTile(
          //     title: Text(item.expandedValue),
          //     subtitle: Text('To delete this panel, tap the trash can icon'),
          //     trailing: Icon(Icons.delete),
          //     onTap: () {
          //       setState(() {
          //         _data.removeWhere((currentItem) => item == currentItem);
          //       });
          //     }),



          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}