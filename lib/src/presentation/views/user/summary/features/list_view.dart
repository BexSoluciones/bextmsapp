import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/summary/summary_cubit.dart';

//domain
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/models/summary.dart';
import '../../../../../domain/models/transaction.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

//utils
import '../../../../../utils/constants/nums.dart';
import '../../../../../utils/constants/strings.dart';

//features
import '../../../../widgets/default_button_widget.dart';
import '../../../../widgets/showcase.dart';
import 'item_summary.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ListViewSummary extends StatefulWidget {
  const ListViewSummary(
      {Key? key,
      required this.arguments,
      required this.one,
      required this.two,
      required this.three,
      required this.four,
      required this.five})
      : super(key: key);

  final SummaryArgument arguments;
  final GlobalKey one, two, three, four, five;

  @override
  ListViewSummaryState createState() => ListViewSummaryState();
}

class ListViewSummaryState extends State<ListViewSummary> with FormatDate {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<SummaryCubit, SummaryState>(builder: (context, state) {
      switch (state.runtimeType) {
        case SummaryLoading:
          return  Align(
            alignment: Alignment.center,
            child: SpinKitCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 100.0,
            ),
          );
        case SummarySuccess:
          return _buildSummary(state, size);
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildSummary(SummaryState state, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height / 1.55,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPhoneShowcase(widget.arguments.work, widget.one),
                buildWhatsAppShowcase(widget.arguments.work, widget.two),
                buildMapShowcase(context, widget.arguments.work, widget.three),
                buildPublishShowcase(widget.four, state.summaries.first.id),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildList(state.isArrived, state.summaries),
          ),
          state.isArrived == false
              ? Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: DefaultButton(
                      widget: const Text('¿Llegaste donde el cliente?',
                          textScaleFactor:
                          1.0,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      press: () async {
                        var transaction = Transaction(
                            workId: widget.arguments.work.id!,
                            workcode: widget.arguments.work.workcode!,
                            status: 'arrived',
                            start: now(),
                            end: now(),
                            latitude: null,
                            longitude: null,
                            firm: null);
                        context.read<SummaryCubit>().sendTransactionArrived(
                            widget.arguments.work, transaction);
                      }),
                )
              : Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: DefaultButton(
                      widget: const Text('¿Quieres georeferenciarlo?',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      press: () => _navigationService.goTo(
                          summaryGeoreferenceRoute,
                          arguments: widget.arguments.work)),
                )
        ],
      ),
    );
  }

  Widget _buildList(isArrived, List<Summary> summaries) {
    if (summaries.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset('assets/animations/36499-page-not-found.json'),
          Text(
              'No hay facturas para el cliente ${widget.arguments.work.customer}.',
              maxLines: 2)
        ],
      );
    } else {
      return Padding(
          padding: const EdgeInsets.only(
              left: kDefaultPadding, right: kDefaultPadding),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: summaries.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final summary = summaries[index];
              if (index == 0) {
                return showCaseClientTile(context, summary);
              } else {
                return ItemSummary(
                    summary: summary,
                    arguments: widget.arguments,
                    isArrived: isArrived,
                    onTap: () async {
                      var transaction = Transaction(
                        workId: widget.arguments.work.id!,
                        summaryId: summary.id,
                        workcode: widget.arguments.work.workcode!,
                        orderNumber: summary.orderNumber,
                        status: 'summary',
                        start: now(),
                        end: now(),
                        latitude: null,
                        longitude: null,
                      );
                      context.read<SummaryCubit>().sendTransactionSummary(
                          widget.arguments.work, summary, transaction);
                    });
              }
            },
          ));
    }
  }

  Widget showCaseClientTile(BuildContext context, summary) {
    return Showcase(
        key: widget.five,
        disableMovingAnimation: true,
        description: 'Este en tu primer cliente, click para ver sus facturas!',
        child: ItemSummary(
            summary: summary,
            arguments: widget.arguments,
            isArrived: false,
            onTap: () async {
              var transaction = Transaction(
                workId: widget.arguments.work.id!,
                summaryId: summary.id,
                workcode: widget.arguments.work.workcode!,
                orderNumber: summary.orderNumber,
                status: 'summary',
                start: now(),
                end: now(),
                latitude: null,
                longitude: null,
              );
              context.read<SummaryCubit>().sendTransactionSummary(
                  widget.arguments.work, summary, transaction);
            }));
  }
}
