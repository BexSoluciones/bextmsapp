import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../cubits/reject/reject_cubit.dart';

//utils
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';

//widgets
import '../../../widgets/default_button_widget.dart';

//features
import 'features/header.dart';
import 'features/reason_global_page.dart';

class RejectView extends StatefulWidget {
  const RejectView({super.key, required this.arguments});

  final InventoryArgument arguments;

  @override
  State<RejectView> createState() => _RejectViewState();
}

class _RejectViewState extends State<RejectView> {
  late RejectCubit rejectCubit;

  final observationController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  void initState() {
    rejectCubit = BlocProvider.of<RejectCubit>(context);
    rejectCubit.getReasons();
    super.initState();
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
          onPressed: () => rejectCubit.navigationService.goBack(),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: size.height * 0.25,
            width: size.width,
            child: Container(
                color: Theme.of(context).colorScheme.primary,
                child: HeaderReject(arguments: widget.arguments)),
          ),
          BlocBuilder<RejectCubit, RejectState>(builder: (context, state) {
            switch (state.runtimeType) {
              case RejectLoading:
                return const Center(child: CupertinoActivityIndicator());
              case RejectSuccess:
                return buildBody(size, state);
              case RejectFailed:
                return buildBody(size, state);
              default:
                return const SliverToBoxAdapter();
            }
          })
        ],
      ),
    );
  }

  SizedBox buildBody(Size size, state) {
    return SizedBox(
      height: size.height / 1.6,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const ListTile(
                title: Text(
                  '¿Estas seguro de confirmar esta entrega como rechazo?',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 100.0),
            ReasonsGlobal(
              reasons: state.reasons,
              context: context,
              setState: setState,
              typeAheadController: reasonController,
            ),
            const Spacer(),
            if (state.error != null)
              Text(state.error,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            DefaultButton(
                widget: const Text('Confirmar',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                press: () {
                  BlocProvider.of<RejectCubit>(context).confirmTransaction(
                      widget.arguments, reasonController.text, null);
                })
          ],
        ),
      ),
    );
  }
}
