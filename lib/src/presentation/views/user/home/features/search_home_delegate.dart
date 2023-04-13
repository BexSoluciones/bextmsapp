import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/work.dart';

//helpers
import '../../../../../utils/constants/colors.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class SearchHomeDelegate extends SearchDelegate<Work?> {
  SearchHomeDelegate(this.works);

  List<Work> _filters = [];
  final List<Work> works;

  @override
  String get searchFieldLabel => 'Buscar';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_ios_new),
        color: kPrimaryColor);
  }

  @override
  Widget buildResults(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: ListView.separated(
              itemCount: _filters.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final work = _filters[index];

                return Material(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      //enabled: !snapshot.data,
                      onTap: null,
                      title: Text(
                        'Servicio: ${work.workcode}',
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Clientes: ${works[index].count}',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            ' Atendidos: ${work.right ?? '0'} Pendientes: ${work.left ?? '0'}',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filters = works.where((element) {
      return element.workcode!
          .toLowerCase()
          .contains(query.trim().toLowerCase());
    }).toList();

    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: ListView.separated(
              itemCount: _filters.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final work = _filters[index];

                return Material(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      //enabled: !snapshot.data,
                      onTap: null,
                      title: Text(
                        'Servicio: ${work.workcode}',
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Clientes: ${works[index].count}',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          ),
                          Text(
                            ' Atendidos: ${work.right ?? '0'} Pendientes: ${work.left ?? '0'}',
                            style: const TextStyle(
                                fontSize: 14.0, fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            )));
  }
}
