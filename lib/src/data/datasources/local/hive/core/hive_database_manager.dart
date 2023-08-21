import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

//utils
import '../../../../../domain/models/user.dart';
import '../../../../../utils/resources/file_operations.dart';

abstract class IDatabaseManager {
  Future<void> start();
  Future<void> clear();
}

@immutable
class HiveDatabaseManager implements IDatabaseManager {
  final String _subDirectory = 'vb10';
  @override
  Future<void> start() async {
    await _open();
    initialOperation();
  }

  @override
  Future<void> clear() async {
    await Hive.deleteFromDisk();
    await FileOperation.instance.removeSubDirectory(_subDirectory);
  }

  /// Open your database connection
  /// Now using [Hive]
  Future<void> _open() async {
    final subPath =
    await FileOperation.instance.createSubDirectory(_subDirectory);
    Hive.init(subPath);
  }

  /// Register your generic model or make your operation before start
  void initialOperation() {
    Hive.registerAdapter(User());
  }
}

class Directory {}