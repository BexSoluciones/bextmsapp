import 'package:bexdeliveries/src/config/size.dart';
import 'package:bexdeliveries/src/presentation/views/user/query/features/respawn_description.dart';
import 'package:bexdeliveries/src/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//cubit
import '../../../../cubits/query/query_cubit.dart';

//domain
import '../../../../../domain/models/work.dart';
import '../../../../../domain/abstracts/format_abstract.dart';

//widgets
import 'item_respawn.dart';

class RespawnQueryView extends StatefulWidget {
  const RespawnQueryView({Key? key, required this.workcode}) : super(key: key);

  final String workcode;

  @override
  State<RespawnQueryView> createState() => _RespawnQueryViewState();
}

class _RespawnQueryViewState extends State<RespawnQueryView> with FormatNumber {

  @override
  Widget build(BuildContext context) {
    final calculatedTextScaleFactor = textScaleFactor(context);
    final calculatedFon = getProportionateScreenHeight(18);
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
                    return Center(child: SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100.0,
                    ));
                  case QuerySuccess:
                    return _buildHome(
                      state.respawns!,
                      state.totalRespawn!,
                        calculatedTextScaleFactor,calculatedFon
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

  Widget _buildHome(List<WorkAdditional>? data, double totalRespawn, double calculatedTextScaleFactor, double calculatedFon) {
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
                    onTap: ()async{
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
                              child: RespawnDescription(data: data[index]),
                            );
                          },
                        ),
                      );
                    },
                    child: ItemRespawn(data: data[index],reason:'Redespachos')
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
            child: Text('Total: ${formatter.format(totalRespawn)}',
                textScaleFactor: calculatedTextScaleFactor,
                style:  TextStyle(color: Colors.white, fontSize: calculatedFon)),
          ),
        )
      ],
    );
  }
}
