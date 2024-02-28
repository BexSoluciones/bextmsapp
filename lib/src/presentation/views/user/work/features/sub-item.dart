import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart';

//helpers
import '../../../../../utils/constants/strings.dart';

//models
import '../../../../../domain/models/work.dart';
import '../../../../../domain/models/arguments.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class SubItemWork extends StatefulWidget {
  const SubItemWork(
      {super.key,
      required this.index,
      required this.work,
      required this.enabled});

  final int index;
  final Work work;
  final bool enabled;

  @override
  SubItemWorkState createState() => SubItemWorkState();
}

class SubItemWorkState extends State<SubItemWork> {
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
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(14);
    return Padding(
        key: ValueKey(widget.work.id),
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Material(
            child: Ink(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  enabled: widget.enabled,
                  leading: GestureDetector(
                      onTap: null,
                      child: CircleAvatar(
                          backgroundColor:
                              Colors.primaries[widget.work.color ?? 5],
                          child: Text(
                            '${widget.work.order ?? 0 + 1}',
                            textScaler:
                                TextScaler.linear(calculatedTextScaleFactor),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          ))),
                  onTap: () => _navigationService.goTo(AppRoutes.summary,
                      arguments: SummaryArgument(work: widget.work)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  title: Text(
                    widget.work.customer!,
                    textScaler: TextScaler.linear(calculatedTextScaleFactor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Text(
                        widget.work.address!,
                        textScaler:
                            TextScaler.linear(calculatedTextScaleFactor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.scrim),
                      )),
                      Row(
                        children: [
                          const Icon(Icons.move_to_inbox, color: Colors.brown),
                          Text(widget.work.count.toString(),
                              textScaler:
                                  TextScaler.linear(calculatedTextScaleFactor),
                              style: TextStyle(
                                  fontSize: calculatedFon,
                                  color: Theme.of(context).colorScheme.scrim))
                        ],
                      )
                    ],
                  ),
                  trailing: buildIcon(),
                ))));
  }
}
