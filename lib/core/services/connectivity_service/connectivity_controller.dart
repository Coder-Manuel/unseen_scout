import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';

class ConnectivityController extends GetxController {
  ConnectivityController({required this.strategy});
  final InternetObservingStrategy strategy;

  Rx<bool> isInitialAppOpen = true.obs;
  Rx<bool> showConnectedIndicator = false.obs;
  Rx<ConnectivityStatus> connectivity = ConnectivityStatus.pending.obs;

  bool get isConnected {
    return connectivity.value != ConnectivityStatus.disconnected;
  }

  void onConnectionUpdate(BuildContext? _, bool status) {
    if (status) {
      connectivity.value = ConnectivityStatus.connected;
    } else {
      connectivity.value = ConnectivityStatus.disconnected;
    }
    update();

    if (!isInitialAppOpen.value && status) {
      showConnectedIndicator.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        showConnectedIndicator.value = false;
      });
    }

    isInitialAppOpen.value = false;
  }
}

enum ConnectivityStatus { pending, connected, disconnected }
