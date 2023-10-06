import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/nums.dart';

class HeaderRespawn extends StatelessWidget {
  const HeaderRespawn({Key? key, required this.arguments}) : super(key: key);

  final InventoryArgument arguments;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (arguments.expedition != null)
                    Text.rich(
                      TextSpan(
                        children: [
                           TextSpan(
                            text: 'EXPEDICIÓN: ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                          ),
                          TextSpan(
                              text: arguments.expedition,
                              style:  TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
                        ],
                      ),
                    ),
                  Text.rich(
                    TextSpan(
                      children: [
                         TextSpan(
                          text: 'DOCUMENTO: ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                        ),
                        TextSpan(
                            text: '${arguments.work.type}-${arguments.orderNumber}',
                            style:  TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                        ),
                        TextSpan(
                            text: arguments.work.numberCustomer,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    arguments.work.customer!,
                    style:  TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      children: [
                         TextSpan(
                          text: 'DIR: ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                        ),
                        TextSpan(
                            text: arguments.work.address,
                            style:  TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
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
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                        ),
                        TextSpan(
                            text:
                            arguments.work.cellphone,
                            style:  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
                      ],
                    ),
                  )
                      : Container(),
                ],
              ),
            )),
      ),
    ]);
  }
}
