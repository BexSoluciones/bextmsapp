import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'dart:io' show Platform;

import '../../locator.dart';
import '../../services/remote_config.dart';

final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();

class UpgraderDialog extends StatefulWidget {
  final Widget child;
  const UpgraderDialog({super.key, required this.child});

  @override
  State<UpgraderDialog> createState() => _UpgraderDialogState();
}

class _UpgraderDialogState extends State<UpgraderDialog> {
  String? message;
  bool force = false;

  @override
  void initState() {
    message = _remoteConfigService.getString('message');
    force = _remoteConfigService.getBool('force') ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
        upgrader: Upgrader(
            debugDisplayAlways: true,
            debugLogging: true,
            showReleaseNotes: true,
            dialogStyle: Platform.isAndroid
                ? UpgradeDialogStyle.material
                : UpgradeDialogStyle.cupertino,
            // messages: UpgraderMessages(code: message),
            canDismissDialog: force),
        child: widget.child);
  }
}
