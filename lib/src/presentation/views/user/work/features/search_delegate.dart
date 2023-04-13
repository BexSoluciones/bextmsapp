import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/work.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

//feature
import 'item_work.dart';

final NavigationService _navigationService = locator<NavigationService>();

class SearchWorkDelegate extends SearchDelegate<Work?> {
  SearchWorkDelegate(this.works);

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
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: ListView.builder(
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final work = _filters[index];
          return ItemWork(work: work);
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _filters = works.where((element) {
      return element.customer!
              .toLowerCase()
              .contains(query.trim().toLowerCase()) ||
          element.numberCustomer
              .toString()
              .toLowerCase()
              .contains(query.trim().toLowerCase()) ||
          element.address!.toLowerCase().contains(query.trim().toLowerCase()) ||
          element.summaries!
              .where((s) => s.orderNumber.contains(query.trim().toLowerCase()))
              .isNotEmpty;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: ListView.builder(
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final work = _filters[index];
          return ItemWork(work: work);
        },
      ),
    );
  }
}
