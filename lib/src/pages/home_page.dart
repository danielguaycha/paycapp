import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/pages/credit/list_credit_page.dart';
import 'package:paycapp/src/pages/expense/listInfinitaTest.dart';
import 'package:paycapp/src/pages/expense/list_expense_page.dart';
import 'package:paycapp/src/pages/index_page.dart';
import 'package:paycapp/src/pages/user/user_page.dart';
import 'package:paycapp/src/utils/local_storage.dart';

import 'client/list_client_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  final prefs = new LocalStorage();
  TabController _tabController;
  @override
  void initState() {  
    super.initState();
    _tabController = new TabController(length: 4, initialIndex: 0, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          IndexPage(),
          ListCreditPage(),
          ListExpensePage(),
          UserPage(),
        ],
      ),
      bottomNavigationBar: new Material(      
        color: Theme.of(context).primaryColor,      
        child: new TabBar(
          isScrollable: false,                    
          tabs: <Widget>[
            new Tab(icon: Icon(FontAwesomeIcons.home)),
            new Tab(icon: Icon(Icons.payment)),
            new Tab(icon: Icon(Icons.monetization_on)),
            new Tab(icon: Icon(Icons.settings)),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}