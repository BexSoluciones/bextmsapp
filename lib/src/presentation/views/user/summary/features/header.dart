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

    return SizedBox(
      // color: Theme.of(context).colorScheme.primary,
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
                      TextSpan(
                        text: 'SERVICIO: ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                      ),
                      TextSpan(
                          text: arguments.work.workcode,
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
                          style:  TextStyle(
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
                          text: ' ${arguments.work.address}',
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
                                  fontWeight: FontWeight.bold,color:Theme.of(context).colorScheme.secondaryContainer),
                            ),
                            TextSpan(
                                text: arguments.work.cellphone,
                                style:  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,color:Theme.of(context).colorScheme.secondaryContainer)),
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
