import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class BaseController extends GetxController {
  void notifySuccess({required String title}) {
    toastification.show(
      type: ToastificationType.success,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: Duration(seconds: 5),
      title: Text(title),
    );
  }

  void notifyError({required String errorMessage}) {
    toastification.show(
      type: ToastificationType.error,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
      title: Text(errorMessage),
    );
  }
}
