import 'package:bexdeliveries/src/presentation/cubits/summary/summary_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//models
import '../../../../../domain/models/arguments.dart';

//widgets
import '../../../../widgets/showcase.dart';

class HeaderSummary extends StatelessWidget {
  const HeaderSummary({
    super.key,
    required this.arguments,
    required this.one,
    required this.two,
    required this.three,
    required this.four,
  });

  final SummaryArgument arguments;
  final GlobalKey one;
  final GlobalKey two;
  final GlobalKey three;
  final GlobalKey four;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
        floating: true,
        delegate: _SliverAppBarDelegate(
            child: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildPhoneShowcase(arguments.work, one, context),
                buildWhatsAppShowcase(arguments.work, two, context),
                buildMapShowcase(context, arguments.work, three),
                BlocSelector<SummaryCubit, SummaryState, bool>(
                    selector: (state) => (state is SummarySuccess ||
                        state is SummaryFailed) && state.summaries.isNotEmpty,
                    builder: (context, x) {
                      return x
                          ? buildPublishShowcase(
                              context,
                              four)
                          : const SizedBox();
                    })
              ],
            ),
          ),
        )));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});

  final PreferredSize child;

  @override
  double get minExtent => child.preferredSize.height;
  @override
  double get maxExtent => child.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  bool get maintainState => false;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
