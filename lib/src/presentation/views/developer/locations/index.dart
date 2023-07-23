import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../domain/models/location.dart';

//bloc
import '../../../blocs/location/location_bloc.dart';

//features
import 'features/item.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';
import '../../../../../plugins/charger_status.dart';

final NavigationService _navigationService = locator<NavigationService>();
final ChargerStatus _chargerStatus = locator<ChargerStatus>();

class LocationsView extends StatelessWidget {
  const LocationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LocationBloc>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => _navigationService.goBack(),
        ),
        title: const Text('Localizaciones'),
        actions: [
          FutureBuilder<String?>(
              future: _chargerStatus.getBatteryLevel(),
              builder: (context, snapshot) {

                print(snapshot.data);
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
      body: StreamBuilder<List<Location>>(
        stream: bloc.locations,
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
