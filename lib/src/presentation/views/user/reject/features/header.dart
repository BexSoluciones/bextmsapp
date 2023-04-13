import 'package:flutter/material.dart';

//domain
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/nums.dart';

class HeaderReject extends StatelessWidget {
  const HeaderReject({Key? key, required this.arguments}) : super(key: key);

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
                          const TextSpan(
                            text: 'EXPEDICIÓN: ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text: arguments.expedition,
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
                            text: '${arguments.work.type}-${arguments.orderNumber}',
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
    ]);
  }
}
