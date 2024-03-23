import 'package:bexdeliveries/src/presentation/blocs/collection/collection_bloc.dart';
import 'package:bexdeliveries/src/presentation/views/user/respawn/index.dart';
import 'package:bexdeliveries/src/utils/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../cubits/respawn/respawn_cubit.dart';

//utils
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';

//widgets
import '../../../widgets/default_button_widget.dart';

//features
import 'features/header.dart';

class RespawnViewMotive extends StatefulWidget {
  const RespawnViewMotive({super.key, required this.arguments});

  final InventoryArgument arguments;
  @override
  State<RespawnViewMotive> createState() => _RespawnViewState();
}

class _RespawnViewState extends State<RespawnViewMotive> {
  late RespawnCubit respawnCubit;
  late CollectionBloc collectionBloc;
  final observationController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void initState() {
    respawnCubit = BlocProvider.of<RespawnCubit>(context);
    respawnCubit.getReasons();
    super.initState();
    collection();
  }
  void collection()async{
    collectionBloc = BlocProvider.of<CollectionBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).colorScheme.secondaryContainer),
          onPressed: (){
            respawnCubit.navigationService.goBack();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => RespawnView(
                arguments: widget.arguments,
                reasonSelected: true,
              ),
            ));
          }
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<RespawnCubit, RespawnState>(builder: (context, state) {
            switch (state.runtimeType) {
              case RespawnLoading:
                return const Center(child: CupertinoActivityIndicator());
              case RespawnSuccess:
                return buildBody(size, state);
              case RespawnFailed:
                return buildBody(size, state);
              default:
                return const SliverToBoxAdapter();
            }
          })
        ],
      ),
    );
  }

  SafeArea buildBody(Size size, state) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.primary,
                  height: 250,
                  child: const Column(
                    children: [
                      SizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                            'Esta seguro de confirmar tu entrega como Redespacho?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      maxLines: 4,
                      controller: observationController,
                      decoration: InputDecoration(
                        labelText: 'Observación',
                        fillColor: Colors.black,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors.black, width: 1.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 1.0),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    )),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: DefaultButton(
                        widget:  const Icon(Icons.edit, color: Colors.white),
                        press: () async {
                          collectionBloc.add(CollectionNavigate(
                              route: AppRoutes.firm,
                              arguments:widget.arguments.summary.orderNumber));
                        })),

                Padding(
                    padding: const EdgeInsets.all(20),
                    child: DefaultButton(
                        widget:const Icon(Icons.camera_alt,
                            color: Colors.white),
                        press: () async {
                          collectionBloc.add(CollectionNavigate(
                              route: AppRoutes.camera,
                              arguments: widget.arguments.summary.orderNumber));
                        })),
                if (state.error != null)
                  Text(state.error,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.red, fontSize: 16)),
                Padding(
                  padding: const EdgeInsets.only(
                    left: kDefaultPadding,
                    right: kDefaultPadding,
                  ),
                  child:  DefaultButton(
                    widget: const Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    press: () async {await BlocProvider.of<RespawnCubit>(context).confirmTransaction(widget.arguments,
                      widget.arguments.reason,
                      observationController.text,
                    );
                    },
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
