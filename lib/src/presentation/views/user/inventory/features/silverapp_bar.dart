import 'package:bexdeliveries/src/config/size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vibration/vibration.dart';

//cubit
import '../../../../cubits/inventory/inventory_cubit.dart';

//models
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/strings.dart';
import '../../../../../utils/constants/nums.dart';

//widgets
import '../../../../widgets/icon_wifi_widget.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

class AppBarInventory extends StatelessWidget {
  AppBarInventory(
      {super.key,
      required this.arguments,
      required this.isArrived,
      required this.one});

  final InventoryArgument arguments;
  final bool isArrived;
  final GlobalKey one;
  final NavigationService navigationService = locator<NavigationService>();

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
            context.read<InventoryCubit>().reset(arguments.summary.validate!,
                arguments.work.id!, arguments.summary.orderNumber);
            navigationService.goTo(AppRoutes.summary,
                arguments: SummaryArgument(work: arguments.work));
          },
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.secondaryContainer)),
      actions: [
        const IconConnection(),
        isArrived == true
            ? Showcase(
                key: one,
                disableMovingAnimation: true,
                title: 'Zap!',
                description:
                    'Aqui puedes reordar todas las cantidades como las tenias. 😁',
                child: IconButton(
                    onPressed: () async {
                      await vibrate();
                      if (context.mounted) {
                        BlocProvider.of<InventoryCubit>(context).reset(
                            arguments.summary.validate!,
                            arguments.work.id!,
                            arguments.summary.orderNumber);
                      }
                    },
                    icon: Icon(Icons.change_circle_outlined,
                        color:
                            Theme.of(context).colorScheme.secondaryContainer)))
            : const SizedBox(),
        const SizedBox(width: 5)
      ],
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.28,
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
                                  if (arguments.summary.expedition != null)
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'EXPEDICIÓN: ',
                                            style: TextStyle(
                                                fontSize: calculatedFon,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer),
                                          ),
                                          TextSpan(
                                              text:
                                                  arguments.summary.expedition,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer)),
                                        ],
                                      ),
                                    ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'DOCUMENTO: ',
                                          style: TextStyle(
                                              fontSize: calculatedFon,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer),
                                        ),
                                        TextSpan(
                                            text:
                                                '${arguments.work.type}-${arguments.summary.orderNumber}',
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
                                      : const SizedBox(),
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
