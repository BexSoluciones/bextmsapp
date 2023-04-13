import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

//model
import '../../domain/models/work.dart';
import '../../domain/models/location.dart';

//service
import '../../locator.dart';
import '../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

Future<Widget?> showMapDirection(BuildContext context, Work work, Location? locationData, String type) async {
  final availableMaps = await MapLauncher.installedMaps;

  if (context.mounted) {
    if (availableMaps.length == 1) {
      if (type == 'summary') {
        //locationData = await _locationService.getLocation();
      }

      await availableMaps.first.showDirections(
        destination: Coords(
          double.parse(work.latitude!),
          double.parse(work.longitude!),
        ),
        destinationTitle: work.customer,
        origin: Coords(locationData!.latitude, locationData.longitude),
        originTitle: 'Origen',
        waypoints: null,
        directionsMode: DirectionsMode.driving,
      );

      return null;
    } else if (type == 'navigation') {
      return await MapsSheet.show(
          context: context,
          onMapTap: (map) {
            map.showDirections(
              destination: Coords(
                double.parse(work.latitude!),
                double.parse(work.longitude!),
              ),
              destinationTitle: work.customer,
              origin: Coords(locationData!.latitude, locationData.longitude),
              originTitle: 'Origen',
              waypoints: null,
              directionsMode: DirectionsMode.driving,
            );
          });
    } else {
      // await _navigationService.goTo(navigationSummaryRoute,
      //     arguments: NavigationSummaryArguments(
      //       work: work,
      //     ));
    }
  }

  return null;
}

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
            onWillPop: () async => false,
            child: SafeArea(
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
                              leading: const Icon(Icons.map),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
