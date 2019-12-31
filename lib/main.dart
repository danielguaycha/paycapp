import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:paycapp/src/config.dart' show appName, colors;
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/pages/home_page.dart';
import 'package:paycapp/src/pages/login_page.dart';
import 'package:paycapp/src/routes.dart';
import 'package:paycapp/src/utils/navigator.service.dart';
//Para el manejo de idiomas de la app
import 'package:flutter_localizations/flutter_localizations.dart';

GetIt locator = GetIt.instance;

void main() async {
  await LocalStorage().initPrefs();
  locator.registerLazySingleton(() => NavigationService());

  runApp(new AlertProvider(
    child: new MyApp(),
    config: new AlertConfig(ok: "SI", cancel: "CANCELAR"),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefs = new LocalStorage();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: colors['primaryDark']));

    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: locator<NavigationService>().navigatorKey,
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('es'), // Spanish
        // ... other locales the app supports
      ],
      theme: ThemeData(
        primaryColor: colors['primary'],
        accentColor: Colors.orange,
        fontFamily: 'Montserrat',
        cursorColor: Colors.orange[900],
        selectedRowColor: colors['accent'],
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          //headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //title: TextStyle(fontSize: 10.0, fontStyle: FontStyle.italic),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
        appBarTheme: AppBarTheme(
            elevation: 5,
            textTheme: TextTheme(title: TextStyle(fontSize: 16.5))),
      ),
      home: (_prefs.token != null) ? HomePage() : LoginPage(),
      // initialRoute: 'login',
      routes: getAppRoutes(),
    );
  }
}
