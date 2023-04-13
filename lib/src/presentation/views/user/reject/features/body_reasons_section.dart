import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/reason.dart';

class BodySection extends StatelessWidget {
  const BodySection(
      {Key? key,
      required this.reasons,
      required this.reasonController,
      required this.callback,
      this.action})
      : super(key: key);

  final List<Reason> reasons;
  final TextEditingController reasonController;

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
    // var re = await database.findReason(reasonController.text);
    //
    // if (re != null) {
    //   if (re.photo! == 1) {
    //     Provider.of<DataInventory>(context, listen: false)
    //         .changeShowPhotoIcon(true);
    //   }
    //
    //   if (re.observation! == 1) {
    //     Provider.of<DataInventory>(context, listen: false)
    //         .changeShowObservationIcon(true);
    //   }
    //
    //   if (re.firm! == 1) {
    //     Provider.of<DataInventory>(context, listen: false)
    //         .changeShowFirmIcon(true);
    //   }
    // }
  }
}
