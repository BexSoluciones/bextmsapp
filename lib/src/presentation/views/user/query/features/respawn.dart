import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../cubits/query/query_cubit.dart';

//domain
import '../../../../../domain/models/work.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

//widgets
import 'item_respawn.dart';
import 'package:lottie/lottie.dart';

class RespawnQueryView extends StatefulWidget {
  const RespawnQueryView({Key? key, required this.workcode}) : super(key: key);

  final String workcode;

  @override
  State<RespawnQueryView> createState() => _RespawnQueryViewState();
}

class _RespawnQueryViewState extends State<RespawnQueryView> with FormatNumber {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Redespachos ${widget.workcode}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                      state.respawns!,
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

  Widget _buildHome(List<WorkAdditional> data) {
           return Column(
              children: [
                Expanded(
                    flex: 11,
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16.0),
                      itemBuilder: (context, index) {
                        return ItemRespawn(data: data[index]);
                      },
                    )),
                const Spacer(),
                // StreamBuilder<double>(
                //   stream: database.countTotalRespawnWorksByWorkcode(widget.workcode),
                //   builder: (BuildContext context, AsyncSnapshot snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return LinearProgressIndicator(
                //         valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                //       );
                //     } else {
                //       return Container(
                //         width: double.infinity,
                //         decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(20),
                //             color: kPrimaryColor),
                //         height: 60,
                //         child: Center(
                //           child: Text(
                //               'Total: ${formatter.format(snapshot.data)}',
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
