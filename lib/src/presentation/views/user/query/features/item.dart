import 'package:bexdeliveries/src/presentation/cubits/type/work_type_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../../config/size.dart';
import '../../../../../domain/models/work.dart';
import '../../../../../domain/repositories/database_repository.dart';
import '../../../../../locator.dart';

final DatabaseRepository _databaseRepository = locator<DatabaseRepository>();

class ItemQuery extends StatefulWidget {
  const ItemQuery({Key? key, required this.work}) : super(key: key);

  final Work work;

  @override
  State<ItemQuery> createState() => _ItemQueryState();
}

class _ItemQueryState extends State<ItemQuery> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(14);
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(
            'Servicio: ${widget.work.workcode}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              FutureBuilder<WorkTypes?>(
                  future: _databaseRepository.getWorkTypesFromWorkcode(widget.work.workcode!),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Entregas: ${snapshot.data.delivery} Parciales: ${snapshot.data.partial}',
                                textScaleFactor: calculatedTextScaleFactor ,
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
                              ),
                              Text(
                                ' Redespachos: ${snapshot.data.respawn} Devoluciones total: ${snapshot.data.rejects}',
                                textScaleFactor: calculatedTextScaleFactor ,
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
                              ),
                            ],
                          ));
                    } else {
                      return Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ' Entregas: 0 Parciales: 0',
                                textScaleFactor: calculatedTextScaleFactor ,
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
                              ),
                              Text(
                                ' Redespachos: 0 Devoluciones total: 0',
                                textScaleFactor: calculatedTextScaleFactor,
                                style: TextStyle(
                                    fontSize: calculatedFon,
                                    fontWeight: FontWeight.normal,color: Theme.of(context).colorScheme.scrim),
                              ),
                            ],
                          ));
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
