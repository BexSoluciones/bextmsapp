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

final NavigationService _navigationService = locator<NavigationService>();

class AppBarInventory extends StatelessWidget {
  const AppBarInventory(
      {Key? key,
      required this.arguments,
      required this.isArrived,
      required this.one})
      : super(key: key);

  final PackageArgument arguments;
  final bool isArrived;
  final GlobalKey one;

  Future<void> vibrate() async {
    var hasVibrate = await Vibration.hasVibrator();
    if (hasVibrate!) {
      await Vibration.vibrate(duration: 500);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: IconButton(
          onPressed: () {
            context.read<InventoryCubit>().reset(arguments.summary.validate!,
                arguments.work.id!, arguments.summary.orderNumber);
            _navigationService.goTo(AppRoutes.inventory,
                arguments: InventoryArgument(
                    work: arguments.work, summary: arguments.summary));
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
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
                    icon: const Icon(Icons.change_circle_outlined)))
            : Container(),
        const SizedBox(width: 5)
      ],
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: MediaQuery.of(context).size.height * 0.28,
      flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          centerTitle: true,
          background: SafeArea(
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
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
                                          const TextSpan(
                                            text: 'EXPEDICIÓN: ',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                              text:
                                                  arguments.summary.expedition,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ],
                                      ),
                                    ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'DOCUMENTO: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text:
                                                '${arguments.work.type}-${arguments.summary.orderNumber}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'NIT: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text: arguments.work.numberCustomer,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    arguments.work.customer!,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  const SizedBox(height: 10),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'DIR: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                            text: arguments.work.address,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  arguments.work.cellphone != null
                                      ? Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: 'CEL: ',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                  text:
                                                      arguments.work.cellphone,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            )),
                      ),
                    ])),
          )),
      title: Text(arguments.work.workcode!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
    );
  }
}
