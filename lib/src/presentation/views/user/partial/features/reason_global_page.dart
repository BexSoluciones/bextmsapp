import 'package:flutter/material.dart';
//domain
import '../../../../../domain/models/reason.dart';
//features
import 'refused.dart';

class ReasonsGlobal extends StatefulWidget {
  const ReasonsGlobal(
      {super.key,
      required this.context,
      required this.reasons,
      required this.type,
      required this.setState,
      required this.r,
      this.typeAheadController});

  final dynamic context, type, r, setState;
  final List<Reason> reasons;
  final TextEditingController? typeAheadController;

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
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: widget.r.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(widget.r[index].nameItem),
          subtitle: (widget.r[index].controller.text == '')
              ? Text(
                  'Sin motivo asignado',
                  style: TextStyle(color: Colors.red.shade700),
                )
              : Text(widget.r[index].controller.text),
          trailing: (widget.r[index].controller.text == '')
              ? const Icon(Icons.add)
              : const Icon(Icons.edit),
          onTap: () async {
            await showModalBottomSheet<void>(
                enableDrag: false,
                useSafeArea: true,
                isScrollControlled: true,
                context: widget.context,
                builder: (BuildContext context) => WillPopScope(
                      onWillPop: () async => false,
                      child: RefusedOrder(
                          reasons: widget.reasons,
                          controllerMotiveItem: widget.r[index].controller,
                          callback: reload),
                    ));
          },
        );
      },
    );
  }
}
