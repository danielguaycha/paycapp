import 'package:paycapp/src/models/clientCredit_model.dart';

class DataForPayment {
  List<DataClient> cliente;
  bool isListPayments;

  DataForPayment(List<DataClient> cliente, bool isListPayments) {
    this.cliente = cliente;
    this.isListPayments = isListPayments;
  }
}
