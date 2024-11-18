import 'package:flutter/material.dart';

class HelperServices with ChangeNotifier {
  final GlobalKey<ScaffoldState> _globalScaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get globalScaffoldKey => _globalScaffoldKey;
}
