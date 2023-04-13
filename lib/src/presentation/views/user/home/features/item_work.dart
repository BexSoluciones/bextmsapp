import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/strings.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ItemWork extends StatelessWidget {
  const ItemWork({Key? key, required this.work}) : super(key: key);

  final Work? work;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          onTap: () {
            _navigationService.goTo(workRoute, arguments: WorkArgument(work: work!));
          },
          title: Text(
            'Servicio: ${work?.workcode}',
            // textScaleFactor: textScaleFactor(context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Row(
            children: [
              Text(
                'Clientes: ${work?.count}',
                // textScaleFactor: textScaleFactor(context),
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
              ),
              Flexible(
                  child: Text(
                ' Atendidos: ${work!.right ?? '0'} Pendientes: ${work!.left ?? '0'}',
                // textScaleFactor: textScaleFactor(context),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ))
            ],
          ),
        ),
      ),
    );
  }
}
