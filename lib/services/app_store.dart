import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:sneekin/models/organization.dart';
import 'package:sneekin/models/user.dart';

class AppStore with ChangeNotifier {
  late Box<User> _userBox;
  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSignedIn = false;
  Box<User> get box => _userBox;
  bool get isSignedIn => _isSignedIn;

  bool _isOrgSignedIn = false;

  bool get isOrgSignedIn => _isOrgSignedIn;

  late Box<Organization> _orgBox;
  Organization? _org;
  Organization? get org => _org;

  Box<Organization> get orgBox => _orgBox;

  Future<void> checkAuth(BuildContext context) async {
    Future.delayed(const Duration(seconds: 0), () {
      if (_isSignedIn || _isOrgSignedIn) {
        context.go("/root");
      } else {
        context.go("/auth");
      }
    });
  }

  Future<void> initializeUserData() async {
    log("Initializing user data");

    // Initialize Hive box for the user
    try {
      _isLoading = true;
      notifyListeners();
      _userBox = await Hive.openBox<User>('user');
      log("UserBox opened: ${_userBox.isOpen}");
    } catch (e) {
      log("Error opening user box: $e");
      _isLoading = false;
      notifyListeners();
      return; // Return early if there's an error
    }

    // Fetch user data
    _user = _userBox.get('user') ?? User();
    log("User data initialized: ${_user?.name}");

    // Determine if user is signed in
    _isSignedIn = _user?.name != null && _user?.user_id != null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initializeOrgData() async {
    log("Initializing org data");

    // Initialize Hive box for the user
    try {
      _isLoading = true;
      notifyListeners();
      _orgBox = await Hive.openBox<Organization>('org');
      log("OrgBox opened: ${_orgBox.isOpen}");
    } catch (e) {
      log("Error opening org box: $e");
      _isLoading = false;
      notifyListeners();
      return; // Return early if there's an error
    }

    // Fetch user data
    _org = _orgBox.get('org') ?? Organization();
    log("org data initialized: ${_org?.org_name}");

    // Determine if user is signed in
    _isOrgSignedIn = _org?.org_name != null && _org?.org_id != null;

    _isLoading = false;
    notifyListeners();
  }

  storeUserData({required User user}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      if (_userBox.isNotEmpty) {
        await _userBox.clear();
      }
      _user = user;
      await _userBox.put('user', user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  storeOrgData({required Organization org}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      if (_orgBox.isNotEmpty) {
        await _orgBox.clear();
      }
      _org = org;
      await _orgBox.put('org', org);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      log("Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  signOut() async {
    try {
      // Clear the user data
      _userBox.clear();
      _orgBox.clear();
      // _appBox.clear();
      // _virtualAcBox.clear();
      _org = null;
      _isOrgSignedIn = false;
      _user = null;
      _isSignedIn = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void refresh() {
    notifyListeners();
  }
}
