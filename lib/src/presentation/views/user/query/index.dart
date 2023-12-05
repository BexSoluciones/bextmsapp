
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//utils
import '../../../../config/size.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/strings.dart';

//cubit
import '../../../cubits/query/query_cubit.dart';

//domain
import '../../../../domain/models/work.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//widgets
import './features/item.dart';

class QueryView extends StatefulWidget {
  const QueryView({Key? key}) : super(key: key);

  @override
  State<QueryView> createState() => _QueryViewState();
}

class _QueryViewState extends State<QueryView> {
  late QueryCubit queryCubit;
  final FormatNumber formatNumber = FormatNumber();
  List<String> workCodes = [];


  @override
  void initState() {
    queryCubit = BlocProvider.of(context);
    queryCubit.getWorks('');
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(18);
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: const Text(
            'Consultas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 16.0,
              right: 16.0,
              bottom: 20.0,
            ),
            child: BlocBuilder<QueryCubit, QueryState>(
              builder: (_, state) {
                switch (state.runtimeType) {
                  case QueryLoading:
                    return const Center(child: CupertinoActivityIndicator());
                  case QuerySuccess:
                    return _buildHome(
                      state.works!,
                      state.countTotalCollectionWorks,
                      calculatedTextScaleFactor,
                      calculatedFon
                    );
                  case QueryFailed:
                    return Center(
                      child: Text(state.error!),
                    );
                  default:
                    return const SizedBox();
                }
              },
            ),
          ),
        ));
  }

  Widget _buildHome(List<Work> works, double? countWorks,double calculatedTextScaleFactor, double  calculatedFon) {
    return Column(
      children: [
        Expanded(
            flex: 12,
            child: ListView.separated(
              itemCount: works.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return Slidable(
                  key: const ValueKey(0),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {
                          context.read<QueryCubit>().goTo(
                              collectionQueryRoute, works[index].workcode);
                          queryCubit
                              .getWorks(works[index].workcode.toString());
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.monetization_on_outlined,
                      ),
                      SlidableAction(
                        onPressed: (_) {
                          context.read<QueryCubit>().goTo(
                              devolutionQueryRoute, works[index].workcode);
                          queryCubit
                              .getWorks(works[index].workcode.toString());
                        },
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        icon: Icons.back_hand_outlined,
                      ),
                    ],
                  ),
                  endActionPane:
                      ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: (_) {
                        context
                            .read<QueryCubit>()
                            .goTo(respawnQueryRoute, works[index].workcode);
                        queryCubit
                            .getWorks(works[index].workcode.toString());
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.restore_page,
                    ),
                  ]),
                  child: ItemQuery(work: works[index]),
                );
              },
            )),
        const Spacer(),
        Container(
                 width: double.infinity,
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(20),
                     color: kPrimaryColor),
               height: 60,
                 child: Center(
                   child: Text(
                       'Total recaudado: ${FormatNumber().formatter.format(countWorks)}',
                       textScaler: TextScaler.linear(calculatedTextScaleFactor),
                       style: TextStyle(
                           color: Colors.white, fontSize: calculatedFon)),
                ),
          )

      ],
    );
  }
}

