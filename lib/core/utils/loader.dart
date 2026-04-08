import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/utils/size.util.dart';

class Loader {
  static bool _isShowing = false;

  static void show({String? message}) {
    if (_isShowing) return;

    _isShowing = true;

    Get.dialog(
      Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.white.setOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 5,
                  constraints: BoxConstraints(minHeight: 50, minWidth: 50),
                  strokeCap: StrokeCap.round,
                ),
                if (message?.isNotEmpty == true) ...[
                  25.verticalSpace,
                  Text(
                    message ?? '',
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void dismiss() {
    if (_isShowing && (Get.isDialogOpen ?? false)) {
      Get.back();
      _isShowing = false;
    }
  }

  static bool get isShowing => _isShowing;
}
