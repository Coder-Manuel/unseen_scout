import 'dart:developer';

import 'package:get_storage/get_storage.dart';

enum StorageKeys { onBoardKey, userDataKey, emailKey, passwordKey }

class StorageService {
  static late GetStorage _storage;

  /// Initialize [StorageService]
  ///
  /// Uses [GetStorage] as the provider
  static Future<void> init([String container = 'unseen_client']) async {
    await GetStorage.init(container);

    _storage = GetStorage(container);

    log('Storage Service Initialized');
  }

  static Future<void> save<T>(StorageKeys key, {required T value}) {
    return _storage.write(key.name, value);
  }

  static Future<T?> get<T>(StorageKeys key) async {
    return _storage.read<T>(key.name);
  }

  static Future<void> remove(StorageKeys key) {
    return _storage.remove(key.name);
  }

  static Future<bool> contains<T>(StorageKeys key) async {
    final value = await get<T>(key);
    if (value == null) return false;
    if (value is String) {
      if (value.isEmpty) return false;
    }

    return true;
  }

  static Future<void> removeAll() async {
    for (var key in StorageKeys.values) {
      await remove(key);
    }
  }
}
