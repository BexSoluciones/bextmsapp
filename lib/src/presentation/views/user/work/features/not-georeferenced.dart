import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

//utils
import '../../../../../utils/constants/nums.dart';

//cubit
import '../../../../cubits/work/work_cubit.dart';

//widget
import 'sub-item.dart';

class NotGeoreferencedViewWork extends StatefulWidget {
  const NotGeoreferencedViewWork({Key? key, required this.workcode}) : super(key: key);

  final String workcode;

  @override
  NotGeoreferencedViewWorkState createState() => NotGeoreferencedViewWorkState();
}

class NotGeoreferencedViewWorkState extends State<NotGeoreferencedViewWork> {
  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
          switch (state.runtimeType) {
            case WorkLoading:
              return const Center(child: CupertinoActivityIndicator());
            case WorkSuccess:
              return _buildWork(state);
            default:
              return const SizedBox();
          }
        }));
  }

  Widget _buildWork(state) {
    return Padding(
        padding: const EdgeInsets.only(left: kDefaultPadding, right: kDefaultPadding, top: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Center(
                  child: Text('SERVICIO: ${widget.workcode}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            Flexible(flex: 16, child: buildStaticBody(state.notGeoreferenced))
          ],
        ));
  }

  Widget buildStaticBody(works) {
    if (works.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/36499-page-not-found.json'),
          const Text('No hay clientes sin georeferenciación.')
        ],
      );
    } else {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: works.length,
        itemBuilder: (context, index) {
          final work = works[index];
          return SubItemWork(work: work, enabled: true);
        },
      );
    }
  }
}
