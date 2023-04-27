import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapsSheet {
  static Future show({
    required BuildContext context,
    required Function(AvailableMap map) onMapTap,
  }) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (context.mounted) {
      return await showModalBottomSheet(
        enableDrag: false,
        useSafeArea: true,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => true,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: <Widget>[
                            for (var map in availableMaps)
                              ListTile(
                                onTap: () => onMapTap(map),
                                title: Text(map.mapName),
                                subtitle: Text(map.mapType.name),
                                leading: SvgPicture.asset(map.icon, height: 50, width: 50),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
