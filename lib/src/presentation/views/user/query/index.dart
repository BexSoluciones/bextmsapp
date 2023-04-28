import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//utils
import '../../../../utils/constants/strings.dart';

//cubit
import '../../../cubits/query/query_cubit.dart';

//domain
import '../../../../domain/models/work.dart';

//widgets
import './features/item.dart';

class QueryView extends StatefulWidget {
  const QueryView({Key? key}) : super(key: key);

  @override
  State<QueryView> createState() => _QueryViewState();
}

class _QueryViewState extends State<QueryView> {

  late QueryCubit queryCubit;

  @override
  void initState() {
    queryCubit = BlocProvider.of(context);
    queryCubit.getWorks();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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

  Widget _buildHome(List<Work> works) {
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
                        onPressed: (_) => context
                            .read<QueryCubit>()
                            .goTo(collectionQueryRoute, works[index].workcode),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        icon: Icons.monetization_on_outlined,
                      ),
                      SlidableAction(
                        onPressed: (_) => context
                            .read<QueryCubit>()
                            .goTo(devolutionQueryRoute, works[index].workcode),
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        icon: Icons.back_hand_outlined,
                      ),
                    ],
                  ),
                  endActionPane:
                      ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: (_) => context
                          .read<QueryCubit>()
                          .goTo(respawnQueryRoute, works[index].workcode),
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
        // FutureBuilder<double>(
        //   future: database.countTotalCollectionWorks(),
        //   builder:
        //       (BuildContext context, AsyncSnapshot snapshot) {
        //     if (snapshot.connectionState ==
        //         ConnectionState.waiting) {
        //       return LinearProgressIndicator(
        //         valueColor: AlwaysStoppedAnimation<Color>(
        //             kPrimaryColor),
        //       );
        //     } else {
        //       return Container(
        //         width: double.infinity,
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20),
        //             color: kPrimaryColor),
        //         height: getProportionateScreenHeight(60),
        //         child: Center(
        //           child: Text(
        //               'Total recaudado: ${formatter.format(snapshot.data ?? 0.0)}',
        //               textScaleFactor: textScaleFactor(context),
        //               style: TextStyle(
        //                   color: Colors.white, fontSize: getProportionateScreenHeight(18))),
        //         ),
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }
}
