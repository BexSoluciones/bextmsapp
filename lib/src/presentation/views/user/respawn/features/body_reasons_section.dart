import 'package:bexdeliveries/src/domain/models/arguments.dart';
import 'package:bexdeliveries/src/domain/repositories/database_repository.dart';
import 'package:bexdeliveries/src/locator.dart';
import 'package:bexdeliveries/src/services/navigation.dart';
import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/reason.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();
final NavigationService _navigationService = locator<NavigationService>();

class BodySection extends StatelessWidget {
  const BodySection(
      {Key? key,
      required this.reasons,
      required this.reasonController,
      required this.callback,
        required this.arguments,
      this.action})
      : super(key: key);

  final List<Reason> reasons;
  final TextEditingController reasonController;
  final InventoryArgument arguments;

  final String? action;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: reasons.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${reasons[index].codmotvis} - ${reasons[index].nommotvis}'),
            onTap: () {
              reasonController.text = reasons[index].nommotvis;
              validateReasons(context);
              callback();
              Navigator.pop(context);
            },
            //reasonCallbacks
          );
        },
      ),
    );
  }

  validateReasons(BuildContext context) async {
    var re = await _databaseRepository.findReason(reasonController.text);
    if (re != null) {
      if (re.photo! == 1 ||  re.observation! == 1 || re.firm! == 1) {
        var newArguments =  InventoryArgument(reason:reasonController.text, work: arguments.work, summary: arguments.summary,total: arguments.total,summaries: arguments.summaries );
        _navigationService.goTo("/respawnMotive", arguments: newArguments);
      }
    }
  }
}
