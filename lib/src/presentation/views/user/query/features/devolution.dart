import 'package:bexdeliveries/src/domain/models/work.dart';
import 'package:bexdeliveries/src/presentation/cubits/query/query_cubit.dart';
import 'package:bexdeliveries/src/presentation/views/user/query/features/rejects_description.dart';
import 'package:bexdeliveries/src/presentation/views/user/query/features/respawn_description.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//domain
import '../../../../../domain/abstracts/format_abstract.dart';

//widgets
import 'item_devolution.dart';
import 'package:lottie/lottie.dart';

import 'item_respawn.dart';

class DevolutionQueryView extends StatefulWidget {
  const DevolutionQueryView({Key? key, required this.workcode}) : super(key: key);

  final String workcode;

  @override
  State<DevolutionQueryView> createState() => _DevolutionQueryViewState();
}

class _DevolutionQueryViewState extends State<DevolutionQueryView> with FormatNumber {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Devoluciones ${widget.workcode}',
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
                    return Center(
                        child: SpinKitCircle(
                          color: Theme.of(context).colorScheme.primary,
                          size: 100.0,
                        ));
                  case QuerySuccess:
                    return _buildHome(
                        state.rejects,
                        state.totalReject!
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

  Widget _buildHome(List<WorkAdditional>? data, double totalReject) {
    return Column(
      children: [
        Expanded(
            flex: 11,
            child: ListView.separated(
              itemCount: data!.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 500),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: RejectsDescription(data: data[index]),
                          );
                        },
                      ),
                    );

                  },
                  child: ItemRespawn(data: data[index],reason:'Devoluciones '),
                );
              },
            )),
        const Spacer(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kPrimaryColor),
          height: 60,
          child: Center(
            child: Text('Total: ${formatter.format(totalReject)}',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        )
      ],
    );
  }
}
