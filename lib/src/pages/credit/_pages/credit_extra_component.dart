import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:paycapp/src/brain.dart';
import 'package:paycapp/src/models/auth_model.dart';
import 'package:paycapp/src/models/credit_model.dart';

class CreditExtraComponent extends StatefulWidget {
  final Credit credit;
  CreditExtraComponent({Key key, this.credit}) : super(key: key);
  @override
  _CreditExtraComponentState createState() => _CreditExtraComponentState();
}

class _CreditExtraComponentState extends State<CreditExtraComponent> {
  Credit _credit;

  @override
  void initState() {
    _credit = widget.credit;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StoreConnector<AppState, dynamic>(
          converter: (store) => store.state.user,
          builder: (context, user) {
            return new Text(
              "${user.username}",
              style: Theme.of(context).textTheme.display1,
            );
          },
        ),/*
        new StoreConnector (
          converter: (store) {
            // Return a `VoidCallback`, which is a fancy name for a function
            // with no parameters. It only dispatches an Increment action.
            return () => store.dispatch(MyActions.Increment);
          },
          builder: (context, callback) {
            return new RaisedButton(
              // Attach the `callback` to the `onPressed` attribute
              onPressed: callback,
              child: new Icon(Icons.add),
            );
          },
        ),*/
      ],
    );
  }
}
