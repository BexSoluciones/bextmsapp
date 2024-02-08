import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../../../widgets/icon_svg_widget.dart';
import '../../../../widgets/showcase.dart';
import 'item_summary.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

class ListViewSummary extends StatefulWidget {
  const ListViewSummary(
      {Key? key,
      required this.summaryCubit,
      required this.arguments,
      required this.one,
      required this.two,
      required this.three,
      required this.four,
      required this.five})
      : super(key: key);

  final SummaryCubit summaryCubit;
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

    return BlocBuilder<SummaryCubit, SummaryState>(
        builder: (_, state) => _buildBlocConsumer(size));
  }

  void buildBlocListener(BuildContext context, SummaryState state) async {
    if (state is SummaryFailed && state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            state.error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  Widget _buildBlocConsumer(Size size) {
    return BlocConsumer<SummaryCubit, SummaryState>(
      listener: buildBlocListener,
      builder: (context, state) {
        if (state is SummaryLoading) {
          return const Align(
            alignment: Alignment.center,
            child: CupertinoActivityIndicator(),
          );
        } else if (state is SummarySuccess || state is SummaryFailed) {
          return _buildSummary(state, size);
        } else {
          return const SizedBox();
        }
      },
    );
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
                buildPhoneShowcase(widget.arguments.work, widget.one, context),
                buildWhatsAppShowcase(
                    widget.arguments.work, widget.two, context),
                buildMapShowcase(context, widget.arguments.work, widget.three),
                state.summaries.isNotEmpty
                    ? buildPublishShowcase(
                        widget.four, state.summaries.first.id)
                    : Container(),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildList(state.isArrived, state.summaries),
          ),
          BlocSelector<SummaryCubit, SummaryState, bool>(
              selector: (state) =>
                  state.isArrived == true && state.isGeoReference == false,
              builder: (c, x) {
                return x
                    ? Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: DefaultButton(
                            widget: const Text('¿Quieres georeferenciarlo?',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                            press: () => _navigationService.goTo(
                                AppRoutes.summaryGeoReference,
                                arguments: widget.arguments)),
                      )
                    : Container();
              }),
          BlocSelector<SummaryCubit, SummaryState, bool>(
              selector: (state) => state.isArrived == false,
              builder: (c, x) {
                return x
                    ? Padding(
                        padding: const EdgeInsets.all(kDefaultPadding),
                        child: DefaultButton(
                            widget: const Text('¿Llegaste donde el cliente?',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
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
                              widget.summaryCubit.sendTransactionArrived(
                                  context, widget.arguments.work, transaction);
                            }),
                      )
                    : Container();
              }),
        ],
      ),
    );
  }

  Widget _buildList(isArrived, List<Summary> summaries) {
    if (summaries.isEmpty) {
      return SvgWidget(
        path: 'assets/icons/not-results.svg',
        messages: [
          'No hay facturas para el cliente ${widget.arguments.work.customer}.'
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
                      widget.summaryCubit.sendTransactionSummary(
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
              widget.summaryCubit.sendTransactionSummary(
                  widget.arguments.work, summary, transaction);
            }));
  }
}
