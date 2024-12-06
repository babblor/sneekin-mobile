import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HelperServices with ChangeNotifier {
  final GlobalKey<ScaffoldState> _globalScaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get globalScaffoldKey => _globalScaffoldKey;

  final String bucketName = "sneek-images";
  final String serviceAccountPath = "path-to-your-service-account-key.json";

  // void notifyListeners() {
  //   notifyListeners();
  // }

  final ImagePicker _picker = ImagePicker();
}
