import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/work.dart';

//helpers
import '../../../../../utils/constants/colors.dart';

//features
import 'item_work.dart';

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
              separatorBuilder: (context, index) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final work = _filters[index];
                return ItemWork(work: work);
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
                return ItemWork(work: work);
              },
            )));
  }
}
