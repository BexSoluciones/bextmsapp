import 'package:flutter/material.dart';

//models
import '../../../../../domain/models/arguments.dart';

//utils
import '../../../../../utils/constants/nums.dart';

class HeaderSummary extends StatelessWidget {
  const HeaderSummary({Key? key, required this.arguments}) : super(key: key);

  final SummaryArgument arguments;

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      width: size.width,
      height: size.height / 3.8,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: kDefaultPadding),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'SERVICIO: ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text: arguments.work.workcode,
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
                          text: ' ${arguments.work.address}',
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
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: arguments.work.cellphone,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                      )
                    : Container(),
                arguments.work.cellphone != null
                    ? const SizedBox(height: 10)
                    : Container(),
              ],
            ),
          ),
    );
  }
}
