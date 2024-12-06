import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:sneekin/models/org_app_account.dart';
import 'package:sneekin/models/organization.dart';
import 'package:path/path.dart';
import 'package:sneekin/models/user.dart';
import 'package:sneekin/models/virtual_account.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

class AuthServices with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Dio? _dio;

  Dio? get dio => _dio;

  AppStore appStore = AppStore();

  final String bucketName = "sneek-images";

  AuthServices() {
    appStore.initializeUserData();
    appStore.initializeOrgData();
    appStore.initializeAppData();
  }

  // For Tax Profile of User

  Map<String, dynamic> _userTaxProfile = {};
  Map<String, dynamic> get userTaxProfile => _userTaxProfile;

  String? passKey;

  List<VirtualAccount> _userVirtualAccounts = [];
  List<VirtualAccount> get userVirtualAccounts => _userVirtualAccounts;

  List<VirtualAccount> _websiteVirtualAccounts = [];
  List<VirtualAccount> get websiteVirtualAccounts => _websiteVirtualAccounts;

  List<OrgAppAccount> _orgAppsAccount = [];
  List<OrgAppAccount> get orgAppsAccount => _orgAppsAccount;

  clearCache() {
    _userTaxProfile = {};
    _userVirtualAccounts = [];
    _websiteVirtualAccounts = [];
    _orgAppsAccount = [];
    notifyListeners();
  }

  initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env["BASE_API_URL"]!,
        receiveTimeout: const Duration(seconds: 50),
        connectTimeout: const Duration(seconds: 50),
      ),
    );
  }

  // Send OTP Function

  sendOTP({required String phone}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      FormData data = FormData.fromMap({"phone": phone, "countryCode": "+91"});

      final resp = await _dio!.post(
        "/auth/sendotp",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in sendOTP: ${resp.data}");

      if (resp.statusCode == 200) {
        log("sendOTP resp: ${resp.data}");
        _isLoading = false;
        notifyListeners();
        // showToast(message: "${resp.data["message"]}", type: ToastificationType.success);
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        showToast(message: "Some error occurred", type: ToastificationType.error);
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    }
  }

  // Verify OTP Function

  verifyOTP({required String phone, required String otp}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      FormData data = FormData.fromMap({"phone": phone, "otp": otp, "countryCode": "+91"});

      final resp = await _dio!.post(
        "/auth/verifyotp",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in verifyOTP: ${resp.data}");
      // log("resp.statusCode in verifyOTP: ${resp.statusCode}");

      if (resp.statusCode == 200) {
        log("verifyOTP resp: ${resp.data["userStatus"]}");

        _dio!.options.headers['Authorization'] = 'Bearer ${resp.data['accessToken']}';
        log("BASE HEADER VALUE: ${_dio!.options.headers['Authorization']}");
        await appStore.storeAccessToken(accessToken: resp.data['accessToken']);
        log("BASE HEADER VALUE IN HIVE: ${appStore.app?.accessToken}");
        if (resp.data["userStatus"] == "EXISTING_USER") {
          log("calling getProfile() in verifyOTP");
          // getProfile(accessToken: resp.data['accessToken']);
          _isLoading = false;
          notifyListeners();

          showToast(message: "OTP verified successfully", type: ToastificationType.success);
          return "EXISTING_USER";
        } else if (resp.data["userStatus"] == "NEW_USER") {
          passKey = resp.data["passKey"];
          log("passKey: $passKey");
          _isLoading = false;
          notifyListeners();
          showToast(message: "OTP verified successfully", type: ToastificationType.success);
          return "NEW_USER";
        } else {
          _isLoading = false;
          notifyListeners();
          showToast(message: "OTP verified successfully", type: ToastificationType.success);
          return "EXISTING_ORGANIZATION";
        }
      } else if (resp.statusCode == 400) {
        _isLoading = false;
        notifyListeners();
        showToast(message: "Invalid OTP!", type: ToastificationType.error);
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Invalid OTP!", type: ToastificationType.error);
      log("error: ${e.message}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    }
  }

  Future<bool> getProfile({required String accessToken}) async {
    log("calling getProfile()");
    try {
      _isLoading = true;
      notifyListeners();

      // Set Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make API call
      final response = await _dio!.get('/users/profile');
      log("response in getProfile() in auth_services: ${response.data}");

      // Parse response into User model
      final userData = User.fromJson(response.data);
      await appStore.storeUserData(user: userData).then((value) {
        log("Hive status: $value");
      }).catchError((err) {
        log("Hive error status: $err");
      }); // Save user data in Hive

      _isLoading = false;
      notifyListeners();
      return true;
    } on HiveError catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error on Hive getting user profile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } on PlatformException catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting user profile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting user profile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Some error occurred",
      //   type: ToastificationType.error,
      // );
      log("error: $e");
      return false;
    }
  }

  Future<bool> getOrgProfile({required String accessToken}) async {
    log("calling getOrgProfile()");
    try {
      _isLoading = true;
      notifyListeners();

      // Set Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make API call
      final response = await _dio!.get('/organizations/profile');
      log("response in getOrgProfile() in auth_services: ${response.data}");

      // Parse response into User model
      final orgData = Organization.fromJson(response.data);
      await appStore.storeOrgData(org: orgData).then((value) {
        log("Hive status: $value");
      }).catchError((err) {
        log("Hive error status: $err");
      }); // Save user data in Hive

      _isLoading = false;
      notifyListeners();
      return true;
    } on HiveError catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error on Hive getting getOrgProfile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } on PlatformException catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting getOrgProfile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting getOrgProfile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Some error occurred",
      //   type: ToastificationType.error,
      // );
      log("error: $e");
      return false;
    }
  }

  Future<bool> getUserTaxProfile() async {
    log("calling getUserTaxProfile()");
    try {
      _isLoading = true;
      notifyListeners();

      // Set Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make API call
      final response = await _dio!.get('/users/tax-profile');
      log("response in getUserTaxProfile() in auth_services: ${response.data}");

      _userTaxProfile = response.data;
      _isLoading = false;
      notifyListeners();
      return true;
    } on PlatformException catch (e) {
      _userTaxProfile = {};
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting getUserTaxProfile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } on DioException catch (e) {
      _userTaxProfile = {};
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Getting error while getting getUserTaxProfile!",
      //   type: ToastificationType.error,
      // );
      log("error: ${e.message}");
      return false;
    } catch (e) {
      _userTaxProfile = {};
      _isLoading = false;
      notifyListeners();
      // showToast(
      //   message: "Some error occurred",
      //   type: ToastificationType.error,
      // );
      log("error: $e");
      return false;
    }
  }

  // Send OTP Function

  Future<bool> createUser({
    required String email,
    required String name,
    required int age,
    required String gender,
    required File image,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      log("Calling createUser with email: $email, name: $name, gender: $gender, age: $age ,image: $image");
      log("passkey: $passKey");

      _isLoading = true;
      notifyListeners();

      await removeAuthToken();

      // Initialize imageURL as null
      String? imageURL;

      // Upload the image if the file path is valid
      if (image.path.isNotEmpty) {
        imageURL = await uploadImage(image: image);
      }

      // Prepare the request payload
      Map<String, dynamic> userData = {
        "email": email,
        "name": name,
        "age": age,
        "gender": gender,
      };

      log("imageURL after uploading to GCP Bucket: $imageURL");

      // Add the image URL to the payload if available
      if (imageURL != null && imageURL.isNotEmpty) {
        userData["profileImageUrl"] = imageURL;
      }

      log("userData after uploading to GCP Bucket: $userData");

      log("endpoint URL: ${dotenv.env["BASE_API_URL"]!}/users");

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      log(" _dio!.options.headers['Authorization']: ${_dio!.options.headers['Authorization']}");

      // Make the POST request
      final resp = await _dio!.post(
        "/users",
        data: userData,
        queryParameters: {'passkey': passKey},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("Response data in createUser: ${resp.data}");

      // Handle the response
      if (resp.statusCode == 200 && resp.data != null) {
        log("User created successfully: ${resp.data}");

        // Store the new access token if available
        if (resp.data["accessToken"] != null) {
          await appStore.storeAccessToken(accessToken: resp.data["accessToken"]);
        }

        _isLoading = false;
        notifyListeners();
        showToast(
          message: "User account has been created successfully.",
          type: ToastificationType.success,
        );
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        String errorMessage = resp.data["message"] ?? "Something went wrong. Please try again.";
        showToast(message: errorMessage, type: ToastificationType.error);
        log("Failed to create user: $errorMessage");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  createOrg(
      {required String email,
      required String name,
      required String cin,
      required String pan,
      required String gstin,
      required File logo,
      required File panFile,
      required File cinFile,
      required String address,
      required File gstnInFile}) async {
    if (_isLoading) {
      return;
    }
    try {
      log("Calling createOrg with $email, $name, $cin, $pan, $gstin, $logo, $address");
      log("passkey: $passKey");
      _isLoading = true;
      notifyListeners();

      await removeAuthToken();

      // Initialize imageURL as null
      String? imageURL;
      String? panUrl;
      String? gstInUrl;
      String? cinUrl;

      // Upload the image if the file path is valid
      if (logo.path.isNotEmpty) {
        imageURL = await uploadImage(image: logo);
      }
      if (panFile.path.isNotEmpty) {
        panUrl = await uploadImage(image: panFile);
      }
      if (gstnInFile.path.isNotEmpty) {
        gstInUrl = await uploadImage(image: gstnInFile);
      }
      if (cinFile.path.isNotEmpty) {
        cinUrl = await uploadImage(image: cinFile);
      }

      // Prepare the request payload
      Map<String, dynamic> orgData = {"email": email, "name": name, "gstIn": gstin, "pan": pan, "cin": cin};

      if (address.isNotEmpty) orgData["address"] = address;

      log("imageURL after uploading to GCP Bucket: $imageURL");

      // Add the image URL to the payload if available
      if (imageURL != null && imageURL.isNotEmpty) {
        orgData["logo"] = imageURL;
      }

      if (panUrl != null && panUrl.isNotEmpty) {
        orgData["panUrl"] = panUrl;
      }

      if (gstInUrl != null && gstInUrl.isNotEmpty) {
        orgData["cinUrl"] = cinUrl;
      }

      if (gstInUrl != null && gstInUrl.isNotEmpty) {
        orgData["gstInUrl"] = gstInUrl;
      }

      log("orgData after uploading to GCP Bucket: $orgData");

      // FormData _data = FormData.fromMap({"email": email, "name": name, "age": age, "gender": gender});
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      final resp = await _dio!.post(
        "/organizations",
        data: orgData,
        queryParameters: {'passkey': passKey},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in createOrg: ${resp.data}");

      if (resp.statusCode == 200) {
        log("createOrg resp: ${resp.data}");
        await appStore.storeAccessToken(accessToken: resp.data["accessToken"]);
        _isLoading = false;
        notifyListeners();
        showToast(
            message: "Organization account has created successfully.", type: ToastificationType.success);
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        showToast(message: resp.data["error"], type: ToastificationType.error);
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
          message: e.response?.data["message"] ?? "Network Error! Try again later.",
          type: ToastificationType.error);
      log("error: $e");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    }
  }

  // get user virtual accounts

  getUserVirtualAccounts() async {
    try {
      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      final resp = await _dio!.get(
        "/virtual-accounts",
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      if (resp.statusCode == 200) {
        log("getUserVirtualAccounts resp: ${resp.data}");
        log("virtual account data: ${resp.data["userVirtualAccounts"]}");
        _userVirtualAccounts = (resp.data["userVirtualAccounts"] as List)
            .map((account) => VirtualAccount.fromJson(account))
            .toList();
        _isLoading = false;
        notifyListeners();
        log("virtual account length: ${userVirtualAccounts.length}");
        return true;
      } else {
        _userVirtualAccounts = [];
        _isLoading = false;
        notifyListeners();
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _userVirtualAccounts = [];
      _isLoading = false;
      notifyListeners();
      log("error getUserVirtualAccounts: $e");
      return false;
    } catch (e) {
      _userVirtualAccounts = [];
      _isLoading = false;
      notifyListeners();
      log("error getUserVirtualAccounts: $e");
      return false;
    }
  }

  // get org apps accounts

  getOrgAppsAccounts() async {
    try {
      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      final resp = await _dio!.get(
        "/org-app-accounts",
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      if (resp.statusCode == 200) {
        log("getOrgAppsAccounts resp: ${resp.data}");
        log("getOrgAppsAccounts data: ${resp.data["orgAppAccounts"]}");
        _orgAppsAccount =
            (resp.data["orgAppAccounts"] as List).map((account) => OrgAppAccount.fromJson(account)).toList();
        _isLoading = false;
        notifyListeners();
        log("getOrgAppsAccounts length: ${orgAppsAccount.length}");
        return true;
      } else {
        _orgAppsAccount = [];
        _isLoading = false;
        notifyListeners();
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _orgAppsAccount = [];
      _isLoading = false;
      notifyListeners();
      log("error: $e");
      return false;
    } catch (e) {
      _orgAppsAccount = [];
      _isLoading = false;
      notifyListeners();
      log("error: $e");
      return false;
    }
  }

  // remove header code

  removeAuthToken() {
    _dio!.options.headers['Authorization'] = null;
    notifyListeners();
  }

  getVirtualAccountsByOrgAppAccount({required String id}) async {
    //endpoint org-app-accounts/34/virtual-accounts
    try {
      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      final resp = await _dio!.get(
        "/org-app-accounts/$id/virtual-accounts",
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      if (resp.statusCode == 200) {
        log("getVirtualAccountsByOrgAppAccount resp: ${resp.data}");
        log("_websiteVirtualAccounts data: ${resp.data["userVirtualAccounts"]}");
        _websiteVirtualAccounts = (resp.data["userVirtualAccounts"] as List)
            .map((account) => VirtualAccount.fromJson(account))
            .toList();
        log("_websiteVirtualAccounts : $_websiteVirtualAccounts");
        _isLoading = false;
        notifyListeners();

        log("_websiteVirtualAccounts length: ${_websiteVirtualAccounts.length}");
        return true;
      } else {
        _websiteVirtualAccounts = [];
        _isLoading = false;
        notifyListeners();
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _websiteVirtualAccounts = [];
      _isLoading = false;
      notifyListeners();
      log("error getVirtualAccountsByOrgAppAccount: $e");
      return false;
    } catch (e) {
      _websiteVirtualAccounts = [];
      _isLoading = false;
      notifyListeners();
      log("error getVirtualAccountsByOrgAppAccount: $e");
      return false;
    }
  }

  Future<String?> uploadImage({required File image}) async {
    try {
      removeAuthToken();
      // Generate upload URL
      final String fileName = basename(image.path);
      final String uploadUrl =
          "https://storage.googleapis.com/upload/storage/v1/b/$bucketName/o?uploadType=media&name=$fileName";

      // Read file bytes
      final fileBytes = await image.readAsBytes();

      log("fileBytes: $fileBytes");

      // Make the Dio POST request
      final response = await _dio!.post(
        uploadUrl,
        data: fileBytes,
      );

      log("response: ${response.data}");

      if (response.statusCode == 200) {
        log("Image uploaded successfully!");
        return "https://storage.googleapis.com/$bucketName/$fileName";
      } else {
        return "";
      }
    } catch (e) {
      log("Error uploading image: $e");
      return "";
    }
  }

  createUserTaxProfile(
      {required String pan_number,
      required String name,
      required String address,
      required String gender,
      required File file}) async {
    if (_isLoading) {
      return;
    }

    try {
      log("Calling createUserTaxProfile with pan_number: $pan_number, name: $name, gender: $gender, address: $address");
      // log("passkey: $passKey");

      _isLoading = true;
      notifyListeners();

      String? newPanUrl;

      // Prepare the request payload
      Map<String, dynamic> data = {
        "panNumber": pan_number,
        "name": name,
        "address": address,
        "gender": gender,
      };

      if (file.path != "") {
        newPanUrl = await uploadImage(image: file);
      }

      if (newPanUrl != null && newPanUrl != "") data["panUrl"] = newPanUrl;

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.post(
        "/users/tax-profile",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("Response data in createUserTaxProfile: ${resp.data}");

      // Handle the response
      if (resp.statusCode == 200 && resp.data != null) {
        log("User created successfully: ${resp.data}");

        _isLoading = false;
        notifyListeners();
        showToast(
          message: "Tax profile has been created successfully.",
          type: ToastificationType.success,
        );
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        String errorMessage = resp.data["message"] ?? "Something went wrong. Please try again.";
        showToast(message: errorMessage, type: ToastificationType.error);
        log("Failed to create user: $errorMessage");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  updateUserTaxProfile(
      {required String pan_number,
      required String name,
      required String address,
      required String gender,
      required File file}) async {
    if (_isLoading) {
      return;
    }

    try {
      log("Calling updateUserTaxProfile with pan_number: $pan_number, name: $name, gender: $gender, address: $address");

      _isLoading = true;
      notifyListeners();

      String? newPanUrl;

      // Prepare the request payload
      Map<String, dynamic> data = {};

      if (name != "") data["name"] = name;
      if (pan_number != "") data["panNumber"] = pan_number;
      if (address != "") data["address"] = address;
      if (gender != "") data["gender"] = gender;

      if (file.path != "") {
        newPanUrl = await uploadImage(image: file);
      }

      if (newPanUrl != null && newPanUrl != "") data["panUrl"] = newPanUrl;

      log("final body for tax-profile PUT: $data");

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.put(
        "/users/tax-profile",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("Response data in updateUserTaxProfile: ${resp.data}");

      // Handle the response
      if (resp.statusCode == 200 && resp.data != null) {
        log("User created successfully: ${resp.data}");

        _isLoading = false;
        notifyListeners();
        // showToast(
        //   message: "Tax profile has been updated successfully.",
        //   type: ToastificationType.success,
        // );
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        String errorMessage = resp.data["message"] ?? "Something went wrong. Please try again.";
        showToast(message: errorMessage, type: ToastificationType.error);
        log("Failed to updateUserTaxProfile: $errorMessage");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException updateUserTaxProfile: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error updateUserTaxProfile: $e");
      return false;
    }
  }

  // update organization api

  Future<bool> updateOrganization({
    required String name,
    required String websiteName,
    required String email,
    required String cin,
    required String pan,
    required String gstIn,
    required String address,
    required File logoFile,
    required File cinFile,
    required File panFile,
    required File gstInFile,
  }) async {
    if (_isLoading) return false;

    try {
      // removeAuthToken();
      _isLoading = true;
      notifyListeners();

      // Initialize an empty data map
      Map<String, dynamic> data = {};

      // Conditionally add fields if they are not empty
      if (name.isNotEmpty || name != "") data['name'] = name;
      if (websiteName.isNotEmpty || websiteName != "") data['websiteName'] = websiteName;
      if (email.isNotEmpty || email != "") data['email'] = email;
      if (cin.isNotEmpty || cin != "") data['cin'] = cin;
      if (pan.isNotEmpty || pan != "") data['pan'] = pan;
      if (gstIn.isNotEmpty || gstIn != "") data['gstIn'] = gstIn;
      if (address.isNotEmpty || address != "") data['address'] = address;

      String? logoUrl;
      String? cinUrl;
      String? panUrl;
      String? gstInUrl;

      // Upload files and generate URLs
      if (logoFile.path.isNotEmpty) logoUrl = await uploadImage(image: logoFile);
      if (cinFile.path.isNotEmpty) cinUrl = await uploadImage(image: cinFile);
      if (panFile.path.isNotEmpty) panUrl = await uploadImage(image: panFile);
      if (gstInFile.path.isNotEmpty) gstInUrl = await uploadImage(image: gstInFile);

      // Attach file URLs to the data body if they are not null
      if (logoUrl != null) data['logo'] = logoUrl;
      if (cinUrl != null) data['cinUrl'] = cinUrl;
      if (panUrl != null) data['panUrl'] = panUrl;
      if (gstInUrl != null) data['gstInUrl'] = gstInUrl;

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      log("body for /organizations(PUT): $data");

      // Make the POST request
      final resp = await _dio!.put(
        "/organizations",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await getOrgProfile(accessToken: appStore.app?.accessToken ?? "");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        showToast(message: "Failed to update organization.", type: ToastificationType.error);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  // Update user api

  Future<bool> updateUser({
    required String name,
    required String email,
    required int age,
    required String gender,
    required File profileImage,
  }) async {
    if (_isLoading) return false;

    try {
      removeAuthToken();
      _isLoading = true;
      notifyListeners();

      // Initialize an empty data map
      Map<String, dynamic> data = {};

      // Conditionally add fields if they are not empty
      if (name.isNotEmpty) data['name'] = name;
      if (email.isNotEmpty) data['email'] = email;
      data['age'] = age;
      if (gender.isNotEmpty) data['gender'] = gender;

      String? profileImageUrl;

      // Upload profile image and generate URL
      if (profileImage.path.isNotEmpty) profileImageUrl = await uploadImage(image: profileImage);

      // Attach the profile image URL to the data body if it's not null
      if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.put(
        "/users",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      _isLoading = false;
      notifyListeners();

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await getProfile(accessToken: appStore.app?.accessToken ?? "");
        return true;
      } else {
        showToast(message: "Failed to update user.", type: ToastificationType.error);
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.message ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  createOrgAppsAccount(
      {required String name,
      required String mobile,
      required String email,
      required String clientWebsite,
      required File logo,
      required bool isMobile}) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      notifyListeners();
      Map<String, dynamic> data = {};

      // Conditionally add fields if they are not empty
      if (name.isNotEmpty) data['name'] = name;
      if (mobile.isNotEmpty) data['mobile'] = mobile;
      if (email.isNotEmpty) data['email'] = email;
      if (clientWebsite.isNotEmpty) data['clientWebsite'] = clientWebsite;
      data['isMobile'] = isMobile;

      String? logoUrl;

      // Upload profile image and generate URL
      if (logo.path.isNotEmpty) logoUrl = await uploadImage(image: logo);

      // Attach the profile image URL to the data body if it's not null
      if (logoUrl != null) data['logo'] = logoUrl;

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.post(
        "/org-app-accounts",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      _isLoading = false;
      notifyListeners();

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await getOrgAppsAccounts();
        return true;
      } else {
        showToast(message: "Failed to update org-apps-account.", type: ToastificationType.error);
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  updateOrgAppsAccount(
      {required int id,
      required String name,
      required String mobile,
      required String email,
      required String clientWebsite,
      required File logo}) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      notifyListeners();
      Map<String, dynamic> data = {};

      // Conditionally add fields if they are not empty
      if (name.isNotEmpty) data['name'] = name;
      if (mobile.isNotEmpty) data['mobile'] = mobile;
      if (email.isNotEmpty) data['email'] = email;
      if (clientWebsite.isNotEmpty) data['clientWebsite'] = clientWebsite;

      String? logoUrl;

      // Upload profile image and generate URL
      if (logo.path.isNotEmpty) logoUrl = await uploadImage(image: logo);

      // Attach the profile image URL to the data body if it's not null
      if (logoUrl != null) data['logo'] = logoUrl;

      log("body in /org-apps-account: $data");

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.put(
        "/org-app-accounts/$id",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("/org-app-accounts resp: ${resp.data}");

      _isLoading = false;
      notifyListeners();

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await getOrgAppsAccounts();
        return true;
      } else {
        showToast(message: "Failed to update org-apps-account.", type: ToastificationType.error);
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(
        message: e.response?.data["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      log("DioException: ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error: $e");
      return false;
    }
  }

  dummyCreateUser() async {
    try {
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      final resp = await _dio!.post(
        "/users",
        data: {
          "name": "Ankita",
          "email": "ankita8@gmail.com",
          "gender": "F",
          "age": 15,
          "profileImageUrl": "123141"
        },
        queryParameters: {'passkey': passKey},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      if (resp.statusCode == 200) {
        log("resp.statusCode: ${resp.statusCode}");
      } else {
        log("resp.statusCode: ${resp.statusCode}");
      }
    } catch (e) {
      log("e: $e");
    }
  }
}
