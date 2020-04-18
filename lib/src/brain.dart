import 'package:flutter/material.dart';
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/providers/auth_provider.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

// state initial
@immutable
class AppState {
  final Auth user;
  AppState({@required this.user});

  getUser() {
    return this.user;
  }
}

// actions
class AddUserAction {
  Auth user;
  AddUserAction(this.user);
}

ThunkAction<AppState> setUser = (Store<AppState> store) async {
  Auth auth = await AuthProvider().getCompleteAuth();
  store.dispatch(new AddUserAction(auth));
};
// reducers
AppState reducer(AppState prev, action) {
  if(action is AddUserAction) {
    return new AppState(user: action.user);
  }
  return prev;
}