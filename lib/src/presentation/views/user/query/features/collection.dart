import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../../presentation/cubits/query/query_cubit.dart';

//domain
import '../../../../../domain/abstracts/format_abstract.dart';
import '../../../../../domain/models/work.dart';

//utils
import '../../../../../utils/constants/colors.dart';

//widgets
import 'delivery_description.dart';

import 'item_collection.dart';

class CollectionQueryView extends StatefulWidget {
  const CollectionQueryView({Key? key, required this.workcode})
      : super(key: key);

  final String workcode;

  @override
  State<CollectionQueryView> createState() => _CollectionQueryViewState();
}

class _CollectionQueryViewState extends State<CollectionQueryView>
    with FormatNumber {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.primary),
          title: Text(
            'Recaudos ${widget.workcode}',
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
                    return _buildHome(state.delivery, state.totalDelivery!);
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

  Widget _buildHome(List<WorkAdditional>? data, double totalDelivery) {
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
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: DeliveryDescription(data: data[index]),
                            );
                          },
                        ),
                      );
                    },
                    child: ItemCollection(data: data[index]));
              },
            )),
        const Spacer(),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: kPrimaryColor),
          height: 60,
          child: Center(
            child: Text('Total: ${formatter.format(totalDelivery)}',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        )
      ],
    );
  }
}
