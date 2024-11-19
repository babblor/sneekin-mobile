import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast({required String message, required ToastificationType type}) {
  toastification.show(
    type: type,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    title: Text(message),
    alignment: Alignment.bottomCenter,
    direction: TextDirection.ltr,
    showIcon: true, // show or hide the icon
    primaryColor: Colors.white,
    backgroundColor: Colors.black45,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
    showProgressBar: true,
    closeButtonShowType: CloseButtonShowType.onHover,
    closeOnClick: false,
    pauseOnHover: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}
