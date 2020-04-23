  

import 'dart:ui';
import 'package:permission_handler/permission_handler.dart';

import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:get_it/get_it.dart';
import 'package:paycapp/src/brain.dart';
import 'package:paycapp/src/config.dart' show appName, colors;
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/providers/auth_provider.dart';
import 'package:paycapp/src/utils/local_storage.dart';
import 'package:paycapp/src/pages/home_page.dart';
import 'package:paycapp/src/pages/login_page.dart';
import 'package:paycapp/src/routes.dart';
import 'package:paycapp/src/utils/navigator.service.dart';
//Para el manejo de idiomas de la app
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux_logging/redux_logging.dart';

//import 'package:laravel_echo/laravel_echo.dart';
//import 'package:flutter_pusher_client/flutter_pusher.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);

  final store = Store<AppState>(
      reducer,
      initialState: new AppState(user: null),
      middleware: [thunkMiddleware, new LoggingMiddleware.printer()],    
  );  

  await LocalStorage().initPrefs();
  locator.registerLazySingleton(() => NavigationService());  

  runApp(
      StoreProvider(store: store, child: new AlertProvider(
        child: new MyApp(store: store),
        config: new AlertConfig(ok: "SI", cancel: "CANCELAR", useIosStyle: false),
      )
  ));
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;
  MyApp({Key key, this.store}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefs = new LocalStorage();

  @override
  void initState() {    
    _initUser();
    _subscribe();
    _checkPermission();    
    super.initState();
  }

  Future<bool> _checkPermission() async {
    if(await Permission.storage.isDenied) {
      await Permission.storage.request();
    }        
    return false;
  }
  
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
        home: (_prefs.token != null) ?
          HomePage() :
          LoginPage(),
        // initialRoute: 'login',
        routes: getAppRoutes(),
    );
  }

  _initUser() async{    
    if(_prefs.token == null) return;

    try{
      Auth auth = await AuthProvider().getCompleteAuth();
      widget.store.dispatch(new AddUserAction(auth));
    }
     catch(e) {
      print(e);
     }
  }

  _subscribe() {
      //TODO: Mejorar esta implementación de pusher combinado con el server
      if(_prefs.token == null) return;
      
      /* var options = PusherOptions(host: '192.168.1.60', port: 6001, encrypted: false);
      FlutterPusher pusher = FlutterPusher('ba32e61a4ec931ef457b', options, enableLogging: true);

      Echo echo = new Echo({
        'broadcaster': 'pusher',
        'client': pusher,
      });

      echo.channel('home').listen('.my-event', (e) {
        print(e);
      }); */
      //echo.socket.on('connect', (_) => print('connect'));
      //echo.socket.on('disconnect', (_) => print('disconnect')); 
  }      
}
