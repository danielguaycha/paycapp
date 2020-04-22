import 'package:paycapp/src/models/person_model.dart';
import 'package:paycapp/src/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = new LocalStorage._internal();

  factory LocalStorage () {
    return _instance;
  }

  LocalStorage._internal();
  SharedPreferences _prefs;

  initPrefs() async{
    _prefs = await SharedPreferences.getInstance();
  }

  // token
  get token {
    return _prefs.getString("token") ?? null;
  }

  set token (String token) {
    _prefs.setString("token", token);
  }

  set update(bool haveUpdate) {
    _prefs.setBool("update", haveUpdate);
  }

  get update {
    return _prefs.getBool("update") ?? false;
  }

  set user (User u) {
    if(u == null)
      _prefs.remove('user');
    else
      _prefs.setString("user", u.toRawJson());
  }

  get user {
    if(_prefs.containsKey("user") && _prefs.getString("user") != null)
      return  User.fromRawJson(_prefs.getString("user"));
    else return null;
  }

  set person (Person p) {
    if(p == null)
      _prefs.remove("person");
    else
      _prefs.setString("person", p.toRawJson());
  }

  get person {
    if(_prefs.containsKey("person") && _prefs.getString("person") != null)
      return  Person.fromRawJson(_prefs.getString("person"));
    else return null;
  }
}