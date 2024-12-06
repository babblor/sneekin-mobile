import 'dart:developer';

import 'package:flutter/foundation.dart';

class DataServices with ChangeNotifier {
  String? _newProfileName;
  String? get newName => _newProfileName;

  changeProfileName(String value) {
    log("new data getting in changeProfileName(): $value");
    _newProfileName = value;
    notifyListeners();
    log("new data setter in changeProfileName(): $value");
  }

  String? _newAddressName;
  String? get newAddress => _newAddressName;

  changeAddress(String value) {
    log("new data getting in changeAddress(): $value");
    _newAddressName = value;
    notifyListeners();
    log("new data setter in changeAddress(): $value");
  }

  double? _newAge;
  double? get newAge => _newAge;

  changeAge(double value) {
    log("new data getting in changeAge(): $value");
    _newAge = value;
    notifyListeners();
    log("new data setter in changeAge(): $value");
  }
}
