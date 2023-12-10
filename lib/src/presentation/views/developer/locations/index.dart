import 'package:bexdeliveries/src/presentation/blocs/gps/gps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:charger_status/charger_status.dart';
import 'package:geolocator/geolocator.dart';

//domain
import '../../../../domain/models/location.dart';

//bloc
import '../../../blocs/location/location_bloc.dart';

//features
import 'features/item.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});

  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {


  @override
  Widget build(BuildContext context) {
    final gpsBloc = context.read<GpsBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _navigationService.goBack(),
        ),
        title: const Text('Localizaciones'),
        actions: [
          FutureBuilder<String?>(
              future: ChargerStatus.instance.getBatteryLevel(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  if(snapshot.data != null){
                    return Row(
                      children: [
                        Text(snapshot.data!),
                        const Icon(Icons.battery_0_bar)
                      ],
                    );
                  }
                  return const Icon(Icons.battery_alert_sharp);
                }

                return const Icon(Icons.battery_full);
              }
          )
        ],
      ),
      body: StreamBuilder<GpsState?>(
        stream: gpsBloc.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if(snapshot.data.isEmpty){
            return const Center(child: Text('No hay localizaciones'));
          }

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              return LocationCard(
                location: snapshot.data[index],
              );
            },
          );
        },
      ),
    );
  }
}
