import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  TestPage({Key key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Stack(
         children: <Widget>[
           Container(
             child: Text("data"),
           ),
           DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
                color: Colors.blue,
                child: Column(
                  children: <Widget>[

                    
                    
                    ListTile(
                      leading: Icon(Icons.image),
                      title: Text("data"),
                    ),
                    
                  ],
                )
                );
          },
        ),

         ],
       ),
    );
  }
}