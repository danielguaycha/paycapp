import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/pages/credit/list_credit_page.dart';
import 'package:paycapp/src/pages/index_page.dart';
import 'package:paycapp/src/pages/map_with_route.dart';
import 'package:paycapp/src/pages/payments/show_payments_page.dart';
import 'package:paycapp/src/pages/expense/show_expense_page.dart';
import 'package:paycapp/src/pages/user/user_page.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'credit/show_credit_page.dart';
import 'expense/add_expense_page.dart';

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
    _tabController = new TabController(length: 6, initialIndex: 0, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          IndexPage(),
          MapRoutePage(),          
          ListCreditPage(),
          //ShowCreditPage(),
          ShowCreditPage(id: 1),
          ShowExpensePage(),
          //ListPayments(),
          //RegistroGastos(),
          //Center( child: Text("Page 4")), 
          UserPage(),
        ],
      ),
      bottomNavigationBar: new Material(      
        color: Theme.of(context).primaryColor,      
        child: new TabBar(
          isScrollable: false,                    
          tabs: <Widget>[
            new Tab(icon: Icon(FontAwesomeIcons.home)),
            new Tab(icon: Icon(Icons.search)),
            new Tab(icon: Icon(Icons.payment)),
            new Tab(icon: Icon(Icons.monetization_on)),
            new Tab(icon: Icon(Icons.add_circle)),
            new Tab(icon: Icon(Icons.settings)),
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}