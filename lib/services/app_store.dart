import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:sneekin/models/organization.dart';
import 'package:sneekin/models/user.dart';
import 'package:sneekin/services/auth_services.dart';

import '../models/app.dart';

class AppStore with ChangeNotifier {
  late Box<User> _userBox;
  User? _user;
  User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isSignedIn = false;
  Box<User> get box => _userBox;
  bool get isSignedIn => _isSignedIn;

  // AuthServices _authServices = AuthServices();

  bool _isOrgSignedIn = false;

  bool get isOrgSignedIn => _isOrgSignedIn;

  late Box<Organization> _orgBox;
  Organization? _org;
  Organization? get org => _org;

  App? _app;

  late Box<App> _appBox;

  App? get app => _app;
  Box<Organization> get orgBox => _orgBox;

  checkAuthToken(BuildContext context) async {
    if (app?.accessToken == null) {
      await initializeAppData();
    } else {
      try {
        bool hasExpired = JwtDecoder.isExpired(app?.accessToken! ?? "");
        log("Auth Token Status: $hasExpired");
        if (hasExpired) {
          // final resp = await signOut(context);
          // if (resp == true) {
          return true;
        }
      } catch (e) {
        log("Error checking token expiration: $e");
        // showToast(
        //   message: "Invalid session token. Please login again!",
        //   type: ToastificationType.error,
        // );
        // await signOut(context);
        // // context.go('/auth');
        return true;
      }
    }
  }

  Future<void> checkAuth(BuildContext context) async {
    log("running checkAuth()");
    if (_isSignedIn || _isOrgSignedIn) {
      context.go("/root");
    } else {
      context.go("/auth");
    }
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
    _user = _userBox.get('user');
    log("User data initialized: ${_user?.name}");

    // Determine if user is signed in
    _isSignedIn = _user?.name != null && _user?.id != null;

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
    _org = _orgBox.get('org') ?? Organization(mobileNumbers: []);
    log("org data initialized: ${_org?.name}");

    // Determine if user is signed in
    _isOrgSignedIn = _org?.name != null && _org?.id != null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> initializeAppData() async {
    log("Initializing app data");

    // Initialize Hive box for the app
    try {
      _isLoading = true;
      notifyListeners();
      _appBox = await Hive.openBox<App>('app');
      log("AppBox opened: ${_appBox.isOpen}");
    } catch (e) {
      log("Error opening app box: $e");
      _isLoading = false;
      notifyListeners();
      return; // Return early if there's an error
    }

    // Fetch app data

    _app = _appBox.get('app');

    log("App data initialized: ${_app?.accessToken}");

    _isLoading = false;
    notifyListeners();
  }

  Future<void> storeAccessToken({required String accessToken}) async {
    // If the app exists, delete the existing app
    if (_appBox.isNotEmpty) {
      await _appBox.clear();
    }
    _app = App(accessToken: accessToken);
    await _appBox.put('app', _app!);
    notifyListeners();
    log("Access token stored: ${app?.accessToken}");
  }

// For Hive
  Future<bool> storeUserData({required User user}) async {
    if (_isLoading) {
      return false;
    }
    try {
      _isLoading = true;
      notifyListeners();

      // Clear previous data if it exists
      if (_userBox.isNotEmpty) {
        await _userBox.clear();
      }

      _user = user;
      await _userBox.put('user', user); // Save serialized User object
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // For Hive
  Future<bool> storeData({required User user}) async {
    if (_isLoading) {
      return false;
    }
    try {
      _isLoading = true;
      notifyListeners();

      // Clear previous data if it exists
      if (_userBox.isNotEmpty) {
        await _userBox.clear();
      }

      _user = user;
      await _userBox.put('user', user); // Save serialized User object
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

  signOut(BuildContext context) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      notifyListeners();
      // Clear the user data
      Provider.of<AuthServices>(context, listen: false).removeAuthToken();
      Provider.of<AuthServices>(context, listen: false).clearCache();
      _userBox.clear();
      _orgBox.clear();
      _appBox.clear();

      // _virtualAcBox.clear();
      _org = null;
      _isOrgSignedIn = false;
      _user = null;
      _isSignedIn = false;
      _app = null;
      // context.go("/auth");
      _isLoading = false;
      notifyListeners();
      log("Current Appdata accessToken status: ${app?.accessToken}");
      return true;
    } catch (e) {
      log("logout error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // signOut() async {
  //   try {
  //     _userBox.clear();
  //     _orgBox.clear();
  //     _appBox.clear();
  //     _org = null;
  //     _user = null;
  //     _isSignedIn = false;
  //     _isOrgSignedIn = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     notifyListeners();
  //     return false;
  //   }
  // }

  void refresh() {
    notifyListeners();
  }
}
