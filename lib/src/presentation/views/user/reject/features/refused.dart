import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/reason.dart';

//feature
import 'body_reasons_section.dart';
import 'build_reasons_textfield.dart';

//service
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class RefusedOrder extends StatefulWidget {
  const RefusedOrder(
      {super.key,
        required this.reasons,
        required this.controllerMotiveItem,
        required this.callback,
        this.action});

  final List<Reason> reasons;
  final TextEditingController controllerMotiveItem;
  final String? action;
  final VoidCallback callback;

  @override
  State<RefusedOrder> createState() => RefusedOrderState();
}

class RefusedOrderState extends State<RefusedOrder> {
  TextEditingController? _searchController;
  late List<Reason> _reasonsList = widget.reasons;

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  void searchMotive(String query) {
    final result = widget.reasons.where((reason) {
      var fullMotive = '${reason.codmotvis.toLowerCase()} ${reason.nommotvis.toLowerCase()}';
      final titleLower = fullMotive.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    setState(() {
      _reasonsList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => _navigationService.goBack(),
        ),
      ),
      body: Column(
        children: [
          HeaderSection(
            searchController: _searchController,
            onChanged: searchMotive,
          ),
          BodySection(
              reasons: _reasonsList,
              reasonController: widget.controllerMotiveItem,
              action: widget.action,
              callback: widget.callback),
        ],
      ),
    );
  }
}
