import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sneekin/services/app_store.dart';
import 'package:sneekin/utils/toast.dart';
import 'package:toastification/toastification.dart';

class AuthServices with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Dio? _dio;

  Dio? get dio => _dio;

  AppStore appStore = AppStore();

  AuthServices() {
    appStore.initializeUserData();
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

      FormData _data = FormData.fromMap({"phone": phone, "countryCode": "+91"});

      final resp = await _dio!.post(
        "/auth/sendotp",
        data: _data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in sendOTP: ${resp.data}");

      if (resp.statusCode == 200) {
        log("sendOTP resp: ${resp.data}");
        _isLoading = false;
        notifyListeners();
        showToast(message: "${resp.data["message"]}", type: ToastificationType.success);
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
      log("error: ${e}");
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showToast(message: "Some error occurred", type: ToastificationType.error);
      log("error: ${e}");
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

      FormData _data = FormData.fromMap({"phone": phone, "otp": otp, "countryCode": "+91"});

      final resp = await _dio!.post(
        "/auth/verifyotp",
        data: _data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      log("resp.data in verifyOTP: ${resp.data}");
      // log("resp.statusCode in verifyOTP: ${resp.statusCode}");

      if (resp.statusCode == 200) {
        log("verifyOTP resp: ${resp.data["userStatus"]}");
        if (resp.data["userStatus"] == "EXISTING_USER") {
          _isLoading = false;
          notifyListeners();
          showToast(message: "OTP verified successfully", type: ToastificationType.success);
          return "EXISTING_USER";
        } else if (resp.data["userStatus"] == "NEW_USER") {
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
      log("error: ${e}");
      return false;
    }
  }
}
