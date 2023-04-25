import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/strings.dart';
//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';

//cubit
import '../../../../../presentation/cubits/work/work_cubit.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ItemWork extends StatefulWidget {
  const ItemWork({Key? key, required this.work}) : super(key: key);

  final Work work;
  @override
  ItemWorkState createState() => ItemWorkState();
}

class ItemWorkState extends State<ItemWork> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Icon buildIcon() {
    if (widget.work.latitude != null && widget.work.longitude != null) {
      return const Icon(
        Icons.location_pin,
        color: Colors.green,
      );
    } else {
      return const Icon(Icons.location_off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkCubit, WorkState>(
        key: ValueKey(widget.work.id),
        builder: (context, state) {
          return Padding(
              key: ValueKey(widget.work.id),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Material(
                  child: Ink(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  enabled: state.started &&
                      (widget.work.hasCompleted != null &&
                          widget.work.hasCompleted == 0),
                  leading: GestureDetector(
                      onTap: null,
                      child: CircleAvatar(
                          backgroundColor:
                              Colors.primaries[widget.work.color ?? 1],
                          child: Text('${widget.work.order != null ? widget.work.order! + 1 : 1 }'))),
                  onTap: () => _navigationService.goTo(summaryRoute,
                      arguments: SummaryArgument(work: widget.work)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Text(
                    widget.work.customer!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text(
                        '${widget.work.address}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      )),
                      Row(
                        children: [
                          Icon(Icons.move_to_inbox, color: Colors.brown[300]),
                          Text(widget.work.count.toString(),
                              style: const TextStyle(fontSize: 14))
                        ],
                      )
                    ],
                  ),
                  trailing: buildIcon(),
                ),
              )));
        });
  }
}
