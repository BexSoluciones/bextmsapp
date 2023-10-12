import 'package:bexdeliveries/src/presentation/cubits/type/work_type_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../../domain/models/work.dart';

class ItemQuery extends StatefulWidget {
  const ItemQuery({Key? key, required this.work }) : super(key: key);

  final Work work;

  @override
  State<ItemQuery> createState() => _ItemQueryState();
}

class _ItemQueryState extends State<ItemQuery> {
  late WorkTypeCubit workTypeCubit;

  @override
  void initState() {
    // TODO: implement initState
    workTypeCubit = BlocProvider.of(context);
    workTypeCubit.getWorkTypesFromWork(widget.work.workcode!);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
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

          subtitle: BlocBuilder<WorkTypeCubit, WorkTypeState>(
            builder: (_, state) {
              switch (state.runtimeType) {
                case WorkTypeCubitLoading:
                  return const Center(child: CupertinoActivityIndicator());
                case WorkTypeCubitSuccess:
                  return _buildHome(
                      state.workTypes!
                  );
                case WorkTypeCubitFailed:
                  return Center(
                    child: Text(state.error!),
                  );
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
  Widget _buildHome(WorkTypes workTypes){
    return Row(
      children: [
        Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' Entregas: ${workTypes.delivery} Parciales: ${workTypes.partial}',
                  style:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.scrim),
                ),
                Text(
                  'Redespachos: ${workTypes.respawn} Devoluciones total: ${workTypes.rejects}',
                  style:  TextStyle(
                      fontSize:14,
                      fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.scrim),
                ),
              ],
            )),
      ],
    );

  }
}
