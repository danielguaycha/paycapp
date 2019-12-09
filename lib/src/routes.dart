import 'package:flutter/material.dart';
import 'package:paycapp/src/pages/credit/add_credit_page.dart';
import 'package:paycapp/src/pages/home_page.dart';
import 'package:paycapp/src/pages/login_page.dart';
import 'package:paycapp/src/pages/client/add_client_page.dart';

Map<String, WidgetBuilder> getAppRoutes() {

  return <String, WidgetBuilder>{
    'login': (BuildContext context) => LoginPage(),
    'home': (BuildContext context) => HomePage(),
    'client_add': (BuildContext context) => AddClientPage(),
    'credit_add': (BuildContext context) => AddCreditPage(),
  };

}