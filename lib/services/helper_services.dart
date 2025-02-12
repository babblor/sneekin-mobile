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

  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  bool _hasReachedOrgAppAccountPage = false;

  bool get hasReachedOrgAppAccountPage => _hasReachedOrgAppAccountPage;

  changeScreen(int index) {
    _activeIndex = index;
    notifyListeners();
  }

  changeHasReachedOrgAppAccountPage(bool value) {
    _hasReachedOrgAppAccountPage = value;
    notifyListeners();
  }

  void resetHasReachedOrgAppAccountPage() {
    _hasReachedOrgAppAccountPage = false;
    notifyListeners();
  }

  final ImagePicker _picker = ImagePicker();
}
