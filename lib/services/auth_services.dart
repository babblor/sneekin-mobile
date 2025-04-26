import 'dart:convert';
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
import 'package:sneekin/models/user_virtual_account.dart' as UserVirtualAccount;
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

  List<UserVirtualAccount.VirtualAccount> _userVirtualAccounts = [];
  List<UserVirtualAccount.VirtualAccount> get userVirtualAccounts => _userVirtualAccounts;

  UserVirtualAccount.VirtualAccountResponse _virtualAccountsResp =
      UserVirtualAccount.VirtualAccountResponse(totalPages: 0, groups: []);

  UserVirtualAccount.VirtualAccountResponse get virtualAccountsResp => _virtualAccountsResp;

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
        baseUrl: dotenv.env["MAIN_API_URL"]!,
        receiveTimeout: const Duration(seconds: 200),
        connectTimeout: const Duration(seconds: 200),
      ),
    );
  }

  void logFormData(FormData formData) async {
    StringBuffer postmanFormat = StringBuffer();

    postmanFormat.writeln('FormData: {');

    for (var field in formData.fields) {
      postmanFormat.writeln('  "${field.key}": ${field.value},');
    }

    for (var file in formData.files) {
      postmanFormat.writeln('  "${file.key}": File("${file.value.filename}"),');
    }

    postmanFormat.writeln('}');

    log(postmanFormat.toString());
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
        _dio!.options.headers['Authorization'] = null;
        // passKey = null;
        notifyListeners();
        showToast(message: "Some error occurred", type: ToastificationType.error);
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      _dio!.options.headers['Authorization'] = null;
      // passKey = null;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    } catch (e) {
      _isLoading = false;
      _dio!.options.headers['Authorization'] = null;
      // passKey = null;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    }
  }

  // Send Email OTP Function

  sendEmailOTP({required String email}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }

      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      final resp = await _dio!.post(
        "/send-email-otp?email=$email",
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in sendEmailOTP: ${resp.data}");

      if (resp.statusCode == 200) {
        log("sendEmailOTP resp: ${resp.data}");
        _isLoading = false;
        notifyListeners();
        // showToast(message: "${resp.data["message"]}", type: ToastificationType.success);
        return true;
      } else {
        _isLoading = false;
        // _dio!.options.headers['Authorization'] = null;
        // passKey = null;
        notifyListeners();
        showToast(message: "Some error occurred", type: ToastificationType.error);
        log("could not received OTP");
        return false;
      }
    } on DioException catch (e) {
      _isLoading = false;
      // _dio!.options.headers['Authorization'] = null;
      // passKey = null;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    } catch (e) {
      _isLoading = false;
      // _dio!.options.headers['Authorization'] = null;
      // passKey = null;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: $e");
      return false;
    }
  }

  // Verify Email OTP

  verifyEmailOTP({required String email, required String otp, required bool isOrg}) async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      final resp = await _dio!.post(
        "/verify-email-otp?email=$email&otp=$otp&isOrg=$isOrg",
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      log("resp.data in verifyEmailOTP: ${resp.data}");

      if (resp.statusCode == 200 && resp.data["status"] == true) {
        log("verifyEmailOTP resp: ${resp.data}");
        _isLoading = false;
        notifyListeners();
        return {
          'status': resp.data["status"],
          'emailexist': resp.data["emailexist"],
        };
      } else if (resp.statusCode == 400 && resp.data["status"] == false) {
        _isLoading = false;
        notifyListeners();
        showToast(message: resp.data["message"] ?? "Invalid OTP!", type: ToastificationType.error);
        log("could not received OTP");
        return {
          'status': resp.data["status"],
          'emailexist': resp.data["emailexist"],
        };
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: e.response?.data["message"] ?? "Invalid OTP!", type: ToastificationType.error);
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
    log("executing verifyOTP function in authServices with _isLoading value: $_isLoading phone: $phone otp: $otp");
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      notifyListeners();

      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }

      // _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      FormData data = FormData.fromMap({"phone": phone, "otp": otp, "countryCode": "+91"});

      log("verifyotp phone: $phone");
      log("verifyotp otp: $otp");

      log("verifyotp body: $data");

      final resp = await _dio!.post(
        "/auth/verifyotp",
        data: data,
        // options: Options(
        //   contentType: Headers.jsonContentType,
        // ),
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
      log("error in DioException: ${e.message}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error in catch: $e");
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

  Future<bool> createUser(
      {required String email,
      required String name,
      required int age,
      required String gender,
      // required File image,
      required bool isemailverified}) async {
    if (_isLoading) {
      return false;
    }

    try {
      log("Calling createUser with email: $email, name: $name, gender: $gender, age: $age , isEmailVerified: $isemailverified");
      log("passkey: $passKey");

      _isLoading = true;
      notifyListeners();

      // await removeAuthToken();
      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

// Upload the image if the file path is valid
      // if (image.path.isNotEmpty) {
      //   bool imageURL = await uploadFile(file: image, uploadFileType: "profile");
      //   log("imageURL bool value in createUser(): $imageURL");
      //   if (!imageURL) {
      //     return false; // Return early if upload fails
      //   }
      // }

      // Prepare the request payload
      Map<String, dynamic> userData = {
        "email": email,
        "name": name,
        "age": age,
        "gender": gender,
        "isEmailVerified": isemailverified
      };

      // Add the image URL to the payload if available
      // if (imageURL != null && imageURL.isNotEmpty) {
      //   userData["profileImageUrl"] = imageURL;
      // }

      log("userData after uploading to GCP Bucket: $userData");

      log("endpoint URL: ${dotenv.env["BASE_API_URL"]!}/users");

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
      // required File logo,
      // required File panFile,
      // required File cinFile,
      required String address,
      // required File gstnInFile,
      required bool isemailverified}) async {
    if (_isLoading) {
      return;
    }
    try {
      log("Calling createOrg with $email, $name, $cin, $pan, $gstin, $address, $isemailverified");
      log("passkey: $passKey");
      _isLoading = true;
      notifyListeners();

      // await removeAuthToken();

      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Initialize imageURL as null
// Upload files and generate URLs
      // if (logo.path.isNotEmpty) {
      //   bool imageURL = await uploadFile(file: logo, uploadFileType: "logo");
      //   if (!imageURL) {
      //     return false; // Return early if upload fails
      //   }
      // }

      // if (panFile.path.isNotEmpty) {
      //   bool panUrl = await uploadFile(file: panFile, uploadFileType: "pan");
      //   if (!panUrl) {
      //     return false; // Return early if upload fails
      //   }
      // }

      // if (gstnInFile.path.isNotEmpty) {
      //   bool gstInUrl = await uploadFile(file: gstnInFile, uploadFileType: "gstin");
      //   if (!gstInUrl) {
      //     return false; // Return early if upload fails
      //   }
      // }

      // if (cinFile.path.isNotEmpty) {
      //   bool cinUrl = await uploadFile(file: cinFile, uploadFileType: "cin");
      //   if (!cinUrl) {
      //     return false; // Return early if upload fails
      //   }
      // }

      // Prepare the request payload
      Map<String, dynamic> orgData = {
        "email": email,
        "name": name,
        "gstIn": gstin,
        "pan": pan,
        "cin": cin,
        "isEmailVerified": isemailverified
      };

      if (address.isNotEmpty) orgData["address"] = address;

      // Add the image URL to the payload if available
      // if (imageURL != null && imageURL.isNotEmpty) {
      //   orgData["logo"] = imageURL;
      // }

      // if (panUrl != null && panUrl.isNotEmpty) {
      //   orgData["panUrl"] = panUrl;
      // }

      // if (gstInUrl != null && gstInUrl.isNotEmpty) {
      //   orgData["cinUrl"] = cinUrl;
      // }

      // if (gstInUrl != null && gstInUrl.isNotEmpty) {
      //   orgData["gstInUrl"] = gstInUrl;
      // }

      log("orgData after uploading to GCP Bucket: $orgData");

      // FormData _data = FormData.fromMap({"email": email, "name": name, "age": age, "gender": gender});
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

  Future<bool> getUserVirtualAccounts() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (appStore.app?.accessToken == null) {
        await appStore.initializeAppData();
      }

      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      Map<int, List<UserVirtualAccount.VirtualAccount>> groupedVirtualAccounts =
          {}; // Map to group by mobileId
      int currentPage = 0;
      int totalPages = 1;

      do {
        final response = await _dio!.get(
          "/virtual-accounts",
          queryParameters: {"page": currentPage},
          options: Options(
            contentType: Headers.jsonContentType,
          ),
        );

        if (response.statusCode == 200) {
          // Parse response using the VirtualAccountResponse model
          log("response.data in userVirtualAccounts Resp: ${response.data}");
          final data = UserVirtualAccount.VirtualAccountResponse.fromJson(response.data);

          if (currentPage == 1) {
            totalPages = data.totalPages;
          }

          // Group virtual accounts by mobileId
          for (var group in data.groups) {
            if (!groupedVirtualAccounts.containsKey(group.mobileId)) {
              groupedVirtualAccounts[group.mobileId] = [];
            }
            groupedVirtualAccounts[group.mobileId]!.addAll(group.userVirtualAccounts);
          }

          currentPage++;
        } else {
          log("Error fetching virtual accounts: ${response.statusCode}");
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } while (currentPage <= totalPages);

      // Convert the grouped map into a list of groups for mergedResponse
      List<UserVirtualAccount.Group> mergedGroups = []; // Using Group class
      log("mergedGroups after calling getUserVirtualAccounts: $mergedGroups");
      groupedVirtualAccounts.forEach((mobileId, virtualAccounts) {
        mergedGroups.add(UserVirtualAccount.Group(
          mobileId: mobileId,
          countryCode: '', // You can set this to an appropriate value if needed
          userVirtualAccounts: virtualAccounts,
        ));
      });

      // Update state with the merged results
      _virtualAccountsResp = UserVirtualAccount.VirtualAccountResponse(
        totalPages: totalPages,
        groups: mergedGroups,
      );

      // Flatten all virtual accounts into a single list
      _userVirtualAccounts = groupedVirtualAccounts.values.expand((x) => x).toList();

      _isLoading = false;
      notifyListeners();
      log("Total virtual accounts fetched: ${_userVirtualAccounts.length}");
      return true;
    } on DioException catch (e) {
      log("DioException in getUserVirtualAccounts: $e");
      _isLoading = false;
      _userVirtualAccounts = [];
      notifyListeners();
      return false;
    } catch (e) {
      log("Exception in getUserVirtualAccounts: $e");
      _isLoading = false;
      _userVirtualAccounts = [];
      notifyListeners();
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

  Future<bool> createUserTaxProfile({
    required String pan_number,
    required String name,
    required String address,
    required String gender,
    required File file,
  }) async {
    if (_isLoading) {
      return false;
    }

    try {
      log("Calling createUserTaxProfile with pan_number: $pan_number, name: $name, gender: $gender, address: $address, file: ${file.path}");

      _isLoading = true;
      notifyListeners();

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Convert file to MultipartFile
      String fileName = file.path.split('/').last;
      MultipartFile multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );

// Prepare the request payload
      FormData formData = FormData.fromMap({
        "file": multipartFile,
        "taxProfileUser": jsonEncode({
          "panNumber": pan_number,
          "name": name,
          "address": address,
          "gender": gender,
        }),
      });

      // Log the formData for debugging
      log("Request Payload: ${formData.fields}");

      // Make the POST request
      final Response resp = await _dio!.post(
        "/users/tax-profile",
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
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

  Future<bool> updateUserTaxProfile({
    required String pan_number,
    required String name,
    required String address,
    required String gender,
    required File file,
  }) async {
    if (_isLoading) return false;

    // Check if the file exists and is valid
    if (!file.existsSync()) {
      log("Error: File does not exist - ${file.path}");
      showToast(
        message: "Invalid file. Please upload a valid file.",
        type: ToastificationType.error,
      );
      return false;
    }

    try {
      log("Calling updateUserTaxProfile with file: ${file.path}");

      _isLoading = true;
      notifyListeners();

      // Set Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';
      log("Authorization Header: Bearer ${appStore.app?.accessToken}");

      // Convert file to MultipartFile
      String fileName = file.path.split('/').last;
      MultipartFile multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      );

// Prepare tax profile data, only adding non-empty fields
      Map<String, dynamic> taxProfileUser = {};

      if (pan_number.isNotEmpty) taxProfileUser["panNumber"] = pan_number;
      if (name.isNotEmpty) taxProfileUser["name"] = name;
      if (address.isNotEmpty) taxProfileUser["address"] = address;
      if (gender.isNotEmpty) taxProfileUser["gender"] = gender;

      FormData formData = FormData.fromMap({
        "file": multipartFile,
        "taxProfileUser": jsonEncode(taxProfileUser),
      });

      log("Request Payload: ${formData.fields}");
      log("taxProfileUser: ${jsonEncode(taxProfileUser)}");
      log("Headers: ${_dio!.options.headers}");

      // Send the PUT request
      final Response resp = await _dio!.put(
        "/users/tax-profile",
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      log("Response data: ${resp.data}");

      // Handle response
      if (resp.statusCode == 200) {
        log("User tax profile updated successfully: ${resp.data}");

        _isLoading = false;
        notifyListeners();

        // showToast(
        //   message: "Tax profile has been updated successfully.",
        //   type: ToastificationType.success,
        // );

        return true;
      } else {
        log("Failed to update tax profile: ${resp.data}");
        showToast(
          message: resp.data["message"] ?? "Something went wrong. Please try again.",
          type: ToastificationType.error,
        );

        return false;
      }
    } on DioException catch (e) {
      log("DioException: ${e.message}");
      showToast(message: "Network Error! Please try again later.", type: ToastificationType.error);
      return false;
    } catch (e) {
      log("Unexpected Error: $e");
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // updateUserTaxProfile(
  //     {required String pan_number,
  //     required String name,
  //     required String address,
  //     required String gender,
  //     required File file}) async {
  //   if (_isLoading) {
  //     return;
  //   }

  //   try {
  //     log("Calling updateUserTaxProfile with pan_number: $pan_number, name: $name, gender: $gender, address: $address");

  //     _isLoading = true;
  //     notifyListeners();

  //     bool? newPanUrl;

  //     // Prepare the request payload
  //     Map<String, dynamic> data = {};

  //     if (name != "") data["name"] = name;
  //     if (pan_number != "") data["panNumber"] = pan_number;
  //     if (address != "") data["address"] = address;
  //     if (gender != "") data["gender"] = gender;

  //     if (file.path != "") {
  //       newPanUrl = await uploadFile(file: file, uploadFileType: "pan");
  //     }

  //     if (newPanUrl != null && newPanUrl != "") data["panUrl"] = newPanUrl;

  //     log("final body for tax-profile PUT: $data");

  //     // Set the Authorization header
  //     _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

  //     // Make the POST request
  //     final resp = await _dio!.put(
  //       "/users/tax-profile",
  //       data: data,
  //       options: Options(
  //         contentType: Headers.jsonContentType,
  //       ),
  //     );

  //     log("Response data in updateUserTaxProfile: ${resp.data}");

  //     // Handle the response
  //     if (resp.statusCode == 200 && resp.data != null) {
  //       log("User created successfully: ${resp.data}");

  //       _isLoading = false;
  //       notifyListeners();
  //       // showToast(
  //       //   message: "Tax profile has been updated successfully.",
  //       //   type: ToastificationType.success,
  //       // );
  //       return true;
  //     } else {
  //       _isLoading = false;
  //       notifyListeners();
  //       String errorMessage = resp.data["message"] ?? "Something went wrong. Please try again.";
  //       showToast(message: errorMessage, type: ToastificationType.error);
  //       log("Failed to updateUserTaxProfile: $errorMessage");
  //       return false;
  //     }
  //   } on DioException catch (e) {
  //     _isLoading = false;
  //     notifyListeners();
  //     showToast(
  //       message: e.response?.data["message"] ?? "Network Error! Please try again later.",
  //       type: ToastificationType.error,
  //     );
  //     log("DioException updateUserTaxProfile: ${e.response?.data ?? e.toString()}");
  //     return false;
  //   } catch (e) {
  //     _isLoading = false;
  //     notifyListeners();
  //     showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
  //     log("Error updateUserTaxProfile: $e");
  //     return false;
  //   }
  // }

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
// Upload files and generate URLs
      if (logoFile.path.isNotEmpty) {
        bool logoUrl = await uploadFile(file: logoFile, uploadFileType: "logo");
        if (!logoUrl || logoUrl == "") {
          return false; // Return early if upload fails
        }
      }

      if (cinFile.path.isNotEmpty) {
        bool cinUrl = await uploadFile(file: cinFile, uploadFileType: "cin");
        if (!cinUrl || cinUrl == "") {
          return false; // Return early if upload fails
        }
      }

      if (panFile.path.isNotEmpty) {
        bool panUrl = await uploadFile(file: panFile, uploadFileType: "pan");
        if (!panUrl || panUrl == "") {
          return false; // Return early if upload fails
        }
      }

      if (gstInFile.path.isNotEmpty) {
        bool gstInUrl = await uploadFile(file: gstInFile, uploadFileType: "gstin");
        if (!gstInUrl || gstInUrl == "") {
          return false; // Return early if upload fails
        }
      }

      // Attach file URLs to the data body if they are not null
      // if (logoUrl != null) data['logo'] = logoUrl;
      // if (cinUrl != null) data['cinUrl'] = cinUrl;
      // if (panUrl != null) data['panUrl'] = panUrl;
      // if (gstInUrl != null) data['gstInUrl'] = gstInUrl;

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
      // removeAuthToken();
      _isLoading = true;
      notifyListeners();

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Upload profile image and generate URL
      if (profileImage.path.isNotEmpty) {
        bool isProfileImageUploaded = await uploadFile(file: profileImage, uploadFileType: "profile");
        log("Profile image upload success: $isProfileImageUploaded");

        if (!isProfileImageUploaded) {
          _isLoading = false;
          notifyListeners();
          return false; // Return early without showing another toast
        }
      }

      log("Still executing after failing of uploadFile :(");

      // Initialize an empty data map
      Map<String, dynamic> data = {};

      // Conditionally add fields if they are not empty
      if (name.isNotEmpty) data['name'] = name;
      if (email.isNotEmpty) data['email'] = email;
      data['age'] = age;
      if (gender.isNotEmpty) data['gender'] = gender;

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

      log("resp.statusCode in updateUser: ${resp.statusCode}");

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
      data['isMobileApp'] = isMobile;

      // Attach the profile image URL to the data body if it's not null
      // if (logoUrl != null) data['logo'] = logoUrl;

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

      log("resp.data in createOrgAppsAccount: ${resp.data}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
// Upload profile image and generate URL
        if (logo.path.isNotEmpty) {
          bool logoUrl = await uploadOrgAppAccountLogo(file: logo, orgappid: resp.data["id"]);

          if (!logoUrl || logoUrl == "") {
            showToast(message: "Failed to upload Org-App-Account logo", type: ToastificationType.warning);
          }
        }
        await getOrgAppsAccounts();
        await getOrgProfile(accessToken: appStore.app?.accessToken ?? "");
        // await appStore.initializeOrgData();
        notifyListeners();
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

// Upload profile image and generate URL
      if (logo.path.isNotEmpty) {
        bool logoUrl = await uploadOrgAppAccountLogo(file: logo, orgappid: id);

        if (!logoUrl || logoUrl == "") {
          return false; // Return early without showing another toast
        }
      }

      // Attach the profile image URL to the data body if it's not null
      // if (logoUrl != null) data['logo'] = logoUrl;

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

  verifyQR({required String mobileID, required String qrCode}) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      notifyListeners();
      Map<String, dynamic> data = {};

      log("qrCode data in authServices: $qrCode");
      log("mobileID data in authServices: $mobileID");
      log("appClientID data in authServices: ${dotenv.env["SNEEK_CLIENT_ID"]!}");

      // Conditionally add fields if they are not empty
      if (mobileID.isNotEmpty) data['mobileID'] = int.parse(mobileID);
      data['appClientID'] = dotenv.env["SNEEK_CLIENT_ID"]!;
      if (qrCode.isNotEmpty) data['qrCode'] = qrCode;

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      // Make the POST request
      final resp = await _dio!.post(
        "/qr-code/verify-sneek-qr",
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await getUserVirtualAccounts();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        showToast(message: resp.data["message"] ?? "Failed to login", type: ToastificationType.error);
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
      log("DioException in verifyQR(): ${e.response?.data ?? e.toString()}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "An unexpected error occurred.", type: ToastificationType.error);
      log("Error in verifyQR(): $e");
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

  Future<bool> uploadFile({required String uploadFileType, required File file}) async {
    try {
      // Ensure dio is initialized
      if (dio == null) {
        log("Dio instance is null");
        showToast(message: "Network Error! Please try again later.", type: ToastificationType.error);
        return false;
      }

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      log("Uploading $uploadFileType with file ${file.path}");

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      final String endpoint = "/upload/$uploadFileType";

      final response = await dio!.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
        ),
      );

      log("Response of file uploading: ${response.toString()}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("File uploaded successfully!");
        return true;
      } else {
        showToast(
          message: response.data?["error"] ?? "Couldn't upload image. Try again later.",
          type: ToastificationType.error,
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      log("DioError: ${e.toString()}");
      showToast(
        message: e.response?.data?["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      log("Error uploading file: $e");
      showToast(message: "Something went wrong. Please try again later.", type: ToastificationType.error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadOrgAppAccountLogo({required File file, required int orgappid}) async {
    try {
      log("Getting orgappid: $orgappid for uploading org-app-logo");
      // Ensure dio is initialized
      if (dio == null) {
        log("Dio instance is null");
        showToast(message: "Network Error! Please try again later.", type: ToastificationType.error);
        return false;
      }

      // Set the Authorization header
      _dio!.options.headers['Authorization'] = 'Bearer ${appStore.app?.accessToken}';

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      final String endpoint = "/org-app-accounts/upload/$orgappid";

      final response = await dio!.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
        ),
      );

      log("Response of file uploading: ${response.toString()}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("File uploaded successfully!");
        return true;
      } else {
        showToast(
          message: response.data?["error"] ?? "Couldn't upload image. Try again later.",
          type: ToastificationType.error,
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      log("DioError: ${e.toString()}");
      showToast(
        message: e.response?.data?["message"] ?? "Network Error! Please try again later.",
        type: ToastificationType.error,
      );
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      log("Error uploading file: $e");
      showToast(message: "Something went wrong. Please try again later.", type: ToastificationType.error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
