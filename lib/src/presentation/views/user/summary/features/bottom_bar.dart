import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//domain
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/models/transaction.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
//utils

import '../../../../../utils/constants/nums.dart';
import '../../../../../utils/constants/strings.dart';

//cubits
import '../../../../cubits/summary/summary_cubit.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';

class BottomViewSummary extends StatelessWidget with FormatDate {
  const BottomViewSummary(
      {super.key, required this.arguments, required this.summaryCubit});

  final SummaryArgument arguments;
  final SummaryCubit summaryCubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<SummaryCubit, SummaryState, bool>(
            selector: (state) =>
                state.isArrived == true && state.isGeoReference == false,
            builder: (c, x) {
              return x
                  ? Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: DefaultButton(
                          widget: const Text('¿Quieres georeferenciarlo?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          press: () => summaryCubit.navigationService.goTo(
                              AppRoutes.summaryGeoReference,
                              arguments: arguments)),
                    )
                  : const SizedBox();
            }),
        BlocSelector<SummaryCubit, SummaryState, bool>(
            selector: (state) => state.isArrived == false,
            builder: (c, x) {
              return x
                  ? Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: DefaultButton(
                          widget: const Text('¿Llegaste donde el cliente?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18)),
                          press: () async {
                            var transaction = Transaction(
                                workId: arguments.work.id!,
                                workcode: arguments.work.workcode!,
                                status: 'arrived',
                                start: now(),
                                end: now(),
                                latitude: null,
                                longitude: null,
                                firm: null);
                            summaryCubit.sendTransactionArrived(
                                context, arguments.work, transaction);
                          }),
                    )
                  : const SizedBox();
            }),
      ],
    );
  }
}
