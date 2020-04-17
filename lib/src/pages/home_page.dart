import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:paycapp/src/pages/credit/list_credit_page.dart';
import 'package:paycapp/src/pages/expense/listInfinitaTest.dart';
import 'package:paycapp/src/pages/expense/list_expense_page.dart';
import 'package:paycapp/src/pages/index_page.dart';
import 'package:paycapp/src/pages/payments/list_payments_page.dart';
import 'package:paycapp/src/pages/payments/show_payments_page.dart';
import 'package:paycapp/src/pages/payments/test.dart';
import 'package:paycapp/src/pages/user/user_page.dart';
import 'package:paycapp/src/utils/local_storage.dart';

import 'client/list_client_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  final prefs = new LocalStorage();
  int _currentIndex = 0;
  PageController _pageController;

  final List<Widget> _children = [
    IndexPage(),
    ListCreditPage(),
    ShowPaymentsPage(),
    ListExpensePage(),
    UserPage(),
  ];

  @override
  void initState() {  
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //body: _children[_currentIndex], // new
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: _children
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.orangeAccent,
        elevation: 12,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped, // new
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _currentIndex, // new
        items:<BottomNavigationBarItem> [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.payment),
            title: new Text('Créditos'),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.pages),
              title: Text('Cobros')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              title: Text('Gastos')
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('Usuario')
          )
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 10), curve: Curves.decelerate);
    });
  }
}