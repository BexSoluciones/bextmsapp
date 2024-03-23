import 'package:bexdeliveries/src/domain/models/arguments.dart';
import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/reason.dart';

//feature
import 'refused.dart';

class ReasonsGlobal extends StatefulWidget {
  const ReasonsGlobal(
      {super.key,
      required this.reasons,
      required this.context,
      required this.setState,
        required this.arguments,
      required this.typeAheadController});

  final List<Reason> reasons;
  final dynamic context, setState;
  final TextEditingController typeAheadController;
  final InventoryArgument arguments;

  @override
  State<ReasonsGlobal> createState() => _ReasonsGlobalState();
}

class _ReasonsGlobalState extends State<ReasonsGlobal> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('SELECCIONE UN MOTIVO'),
      subtitle: (widget.typeAheadController.text == '')
          ? Text(
              'Sin motivo asignado',
              style: TextStyle(color: Colors.red.shade700),
            )
          : Text(widget.typeAheadController.text),
      trailing: (widget.typeAheadController.text == '')
          ? const Icon(Icons.add)
          : const Icon(Icons.edit),
      onTap: () async {
        await showModalBottomSheet<void>(
            enableDrag: false,
            useSafeArea: true,
            isScrollControlled: true,
            context: widget.context,
            builder: (BuildContext context) => PopScope(
                  canPop: true,
                  child: RefusedOrder(
                    reasons: widget.reasons,
                    controllerMotiveItem: widget.typeAheadController,
                    arguments: widget.arguments,
                    action: 'redespacho',
                    callback: reload,
                  ),
                ));
      },
    );
  }
}
