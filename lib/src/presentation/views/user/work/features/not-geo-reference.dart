import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/nums.dart';

//cubit
import '../../../../cubits/work/work_cubit.dart';

//widget
import 'sub-item.dart';

class NotGeoReferencedViewWork extends StatefulWidget {
  const NotGeoReferencedViewWork({Key? key, required this.workcode})
      : super(key: key);

  final String workcode;

  @override
  NotGeoReferencedViewWorkState createState() =>
      NotGeoReferencedViewWorkState();
}

class NotGeoReferencedViewWorkState extends State<NotGeoReferencedViewWork> {
  bool isLoading = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(18);
    return SafeArea(
        child: BlocBuilder<WorkCubit, WorkState>(builder: (context, state) {
      switch (state.runtimeType) {
        case WorkLoading:
          return const Center(child: CupertinoActivityIndicator());
        case WorkSuccess:
          return _buildWork(state, calculatedTextScaleFactor, calculatedFon);
        default:
          return const SizedBox();
      }
    }));
  }

  Widget _buildWork(
      state, double calculatedTextScaleFactor, double calculatedFon) {
    return Padding(
        padding: const EdgeInsets.only(
            left: kDefaultPadding, right: kDefaultPadding, top: 10.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: Center(
                  child: Text('SERVICIO: ${widget.workcode}',
                      textScaler: TextScaler.linear(calculatedTextScaleFactor),
                      style: TextStyle(
                          fontSize: calculatedFon,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary))),
            ),
            Flexible(flex: 16, child: buildStaticBody(state.notGeoreferenced))
          ],
        ));
  }

  Widget buildStaticBody(works) {
    if (works.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No hay clientes sin georeferenciación.',
              style: TextStyle(fontWeight: FontWeight.w600))
        ],
      );
    } else {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: works.length,
        itemBuilder: (context, index) {
          final work = works[index];
          return SubItemWork(index: index, work: work, enabled: true);
        },
      );
    }
  }
}
