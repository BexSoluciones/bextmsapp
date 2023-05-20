import 'dart:isolate';
import 'package:flutter/services.dart';

class IsolateService {
  static IsolateService? _instance;

  static Future<IsolateService?> getInstance() async {
    _instance ??= IsolateService();
    return _instance;
  }

  void isolateMain(RootIsolateToken rootIsolateToken) async {
    // Register the background isolate with the root isolate.
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    // You can now use the shared_preferences plugin.

    // BackgroundIsolateBinding.initializeBackgroundIsolate(binding);
  }
}