import 'package:bexdeliveries/src/domain/models/summary_report.dart';
import 'package:bexdeliveries/src/domain/models/work.dart';

import 'package:bexdeliveries/src/presentation/cubits/ordersummaryreasons/ordersummaryreasons_cubit.dart';
import 'package:bexdeliveries/src/presentation/views/user/navigation/pages/description/description_map.dart';
import 'package:bexdeliveries/src/presentation/views/user/navigation/pages/map/map_view_reason.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';




class RejectsDescription extends StatefulWidget {
  final WorkAdditional data;


  const RejectsDescription({Key? key, required this.data}) : super(key: key);

  @override
  State<RejectsDescription> createState() => _RejectsDescriptionState();
}

class _RejectsDescriptionState extends State<RejectsDescription> {

  late OrdersummaryreasonsCubit ordersummaryreasonsCubit;
  var connectivity = Connectivity();


  @override
  void initState() {
    ordersummaryreasonsCubit = BlocProvider.of(context);
    ordersummaryreasonsCubit.OrdenSummary(widget.data.orderNumber);
    super.initState();

  }


  PreferredSizeWidget buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: Builder(
          builder: (BuildContext context) {
            return Text(
              '${widget.data.type ?? "Sin tipo"}-${widget.data.orderNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () async {
              var network = await connectivity.checkConnectivity();
              if (network == ConnectivityResult.wifi ||
                  network == ConnectivityResult.mobile) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MaxBoxScreen(
                          workcode: widget.data.work.workcode!,
                          latitud: widget.data.latitude ?? 0,
                          longitud: widget.data.longitude ?? 0,
                          customer: widget.data.work.customer,
                          nit: widget.data.work.numberCustomer,
                          latitudCliente:double.parse(widget.data.work.latitude!),
                          longituduCliente:  double.parse(widget.data.work.longitude!),
                        ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Actualmente no está disponible la función de navegación sin internet',
                  ),
                ));
              }
            },
          ),
          const SizedBox(width: 20.0,)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SafeArea(
        child: BlocBuilder<OrdersummaryreasonsCubit, OrdersummaryreasonsState>(
          builder: (_, state) {
            switch (state.runtimeType) {
              case OrdersummaryreasonsLoading:
                return Center(
                    child: SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100.0,
                    ));
              case OrdersummaryreasonsSuccess:
                return _buildHome(
                  state.summariesRejects,
                );
              case OrdersummaryreasonsFailed:
                return Center(
                  child: Text(state.error!),
                );
              default:
                return const SizedBox();
            }
          },
        ),

      ),
    );
  }


  Widget _buildHome(List<SummaryReport>? data) {
    return Column(
      children: [
        Expanded(
            flex: 11,
            child: ListView.separated(
              itemCount: data!.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final innerSummaries = data[index];
                return ItemDescription(
                  summary: innerSummaries,
                  workcode: widget.data.work.workcode!,
                  workId:widget.data.work.id!,
                  orderNumber:widget.data.orderNumber,
                  onTap: null,
                );
              },
            )),

      ],
    );
  }


}
