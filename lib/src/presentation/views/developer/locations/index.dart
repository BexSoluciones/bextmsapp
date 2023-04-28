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

final NavigationService _navigationService = locator<NavigationService>();

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
