import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';

//cubit
import '../../../../cubits/summary/summary_cubit.dart';

//domain
import '../../../../../domain/models/arguments.dart';
import '../../../../../domain/models/transaction.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

//features
import '../../../../widgets/icon_svg_widget.dart';

import 'item_summary.dart';

class ListViewSummary extends StatefulWidget {
  const ListViewSummary(
      {super.key,
      required this.summaryCubit,
      required this.arguments,
      required this.one,
      required this.two,
      required this.three,
      required this.four,
      required this.five});

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

    return BlocConsumer<SummaryCubit, SummaryState>(
      listener: buildBlocListener,
      builder: (context, state) {
        if (state is SummaryLoading) {
          return const SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.center,
              child: CupertinoActivityIndicator(),
            ),
          );
        } else if (state is SummarySuccess || state is SummaryFailed) {
          return _buildSummary(state, size);
        } else {
          return const SliverToBoxAdapter(child: SizedBox());
        }
      },
    );
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

  Widget _buildSummary(SummaryState state, Size size) {
    if (state.summaries.isEmpty) {
      return SliverToBoxAdapter(
        child: SvgWidget(
          path: 'assets/icons/not-results.svg',
          messages: [
            'No hay facturas para el cliente ${widget.arguments.work.customer}.'
          ],
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return BlocBuilder<SummaryCubit, SummaryState>(
                buildWhen: (previous, current) {
                  return (current is SummarySuccess ||
                          current is SummaryFailed) &&
                      previous.summaries.isNotEmpty &&
                      previous.summaries[index] != current.summaries[index];
                },
                key: ValueKey(index),
                builder: (context, state) {
                  final summary = state.summaries[index];
                  if (index == 0) {
                    return showCaseClientTile(context, summary);
                  } else {
                    return ItemSummary(
                        summary: summary,
                        arguments: widget.arguments,
                        isArrived: state.isArrived!,
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
                });
          },
          childCount: state.summaries.length,
        ),
      );
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
