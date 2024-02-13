import 'package:bexdeliveries/src/config/size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

//cubit
import '../../../../cubits/summary/summary_cubit.dart';

//models
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/strings.dart';
import '../../../../../utils/constants/nums.dart';

//widgets
import '../../../../widgets/icon_wifi_widget.dart';

class AppBarSummary extends StatelessWidget {
  const AppBarSummary(
      {super.key, required this.arguments, required this.summaryCubit});

  final SummaryArgument arguments;
  final SummaryCubit summaryCubit;

  Future<void> vibrate() async {
    var hasVibrate = await Vibration.hasVibrator();
    if (hasVibrate!) {
      await Vibration.vibrate(duration: 500);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedFon = getProportionateScreenHeight(16);
    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: IconButton(
          onPressed: () {
            if (arguments.origin != null && arguments.origin == 'navigation') {
              summaryCubit.navigationService.goBack();
            } else {
              summaryCubit.navigationService.goTo(AppRoutes.work,
                  arguments: WorkArgument(work: arguments.work));
            }
          },
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.secondaryContainer)),
      actions: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: IconConnection(fsu: false),
        ),
        BlocSelector<SummaryCubit, SummaryState, bool>(
            selector: (state) => state.time != null,
            builder: (context, x) {
              return x
                  ? GestureDetector(
                      onTap: () async =>
                          await summaryCubit.getDiffTime(arguments.work.id!),
                      child: Text('Tiempo ${summaryCubit.state.time}',
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer)))
                  : const SizedBox();
            }),
        const SizedBox(width: 5)
      ],
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.25,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          background: SafeArea(
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getProportionateScreenHeight(25)),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(kDefaultPadding),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'NIT: ',
                                          style: TextStyle(
                                              fontSize: calculatedFon,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer),
                                        ),
                                        TextSpan(
                                            text: arguments.work.numberCustomer,
                                            style: TextStyle(
                                                fontSize: calculatedFon,
                                                fontWeight: FontWeight.normal,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    arguments.work.customer!,
                                    style: TextStyle(
                                        fontSize: calculatedFon,
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer),
                                  ),
                                  const SizedBox(height: 10),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'DIR: ',
                                          style: TextStyle(
                                              fontSize: calculatedFon,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer),
                                        ),
                                        TextSpan(
                                            text: arguments.work.address,
                                            style: TextStyle(
                                                fontSize: calculatedFon,
                                                fontWeight: FontWeight.normal,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  arguments.work.cellphone != null
                                      ? Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'CEL: ',
                                                style: TextStyle(
                                                    fontSize: calculatedFon,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer),
                                              ),
                                              TextSpan(
                                                  text:
                                                      arguments.work.cellphone,
                                                  style: TextStyle(
                                                      fontSize: calculatedFon,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer)),
                                            ],
                                          ),
                                        )
                                      : Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'CEL: ',
                                                style: TextStyle(
                                                    fontSize: calculatedFon,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer),
                                              ),
                                              TextSpan(
                                                  text: 'No registra',
                                                  style: TextStyle(
                                                      fontSize: calculatedFon,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer)),
                                            ],
                                          ),
                                        )
                                ],
                              ),
                            )),
                      ),
                    ])),
          )),
      title: Text("SERVICIO: ${arguments.work.workcode}",
          style: TextStyle(
              fontSize: calculatedFon,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.secondaryContainer)),
    );
  }
}
