import 'package:flutter/material.dart';
import 'package:paycapp/src/models/auth_model.dart';

// state initial
@immutable
class AppState {
  final Auth user;
  AppState({@required this.user});
}


// actions
class AddUserAction {
  Auth user;
  AddUserAction(this.user);
}



// reducers
AppState reducer(AppState prev, action) {
  print(action);
  if(action is AddUserAction) {
    return new AppState(user: action.user);
  }
  return prev;
}