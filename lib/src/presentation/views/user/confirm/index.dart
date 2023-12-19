import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../cubits/confirm/confirm_cubit.dart';

//domain
import '../../../../domain/models/arguments.dart';

//widgets
import '../../../widgets/default_button_widget.dart';

class ConfirmWorkView extends StatefulWidget {
  const ConfirmWorkView({Key? key, required this.arguments}) : super(key: key);

  final WorkArgument arguments;

  @override
  State<ConfirmWorkView> createState() => ConfirmWorkViewState();
}

class ConfirmWorkViewState extends State<ConfirmWorkView> {
  late ConfirmCubit confirmCubit;

  @override
  void initState() {
    confirmCubit = BlocProvider.of<ConfirmCubit>(context);
    confirmCubit.init(widget.arguments.work);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Iniciar el servicio',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ConfirmCubit, ConfirmState>(
            builder: (context, state) {
              if (state is ConfirmLoading) {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              } else if (state is ConfirmSuccess) {
                return _buildConfirm(state);
              } else {
                return const SizedBox();
              }
            },
          ),
        ));
  }

  Widget _buildConfirm(state) {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const SizedBox(),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.2,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '¿Realmente deseas iniciar \nel servicio',
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade800),
                    ),
                    TextSpan(
                      text: widget.arguments.work.workcode,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '?',
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            )),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultButton(
                  press: () => context.read<ConfirmCubit>().confirm(widget.arguments),
                  widget: const Text('Aceptar',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultButton(
                    color: Colors.grey,
                    press: () => context.read<ConfirmCubit>().out(widget.arguments),
                    widget: const Text('Cancelar',
                        style: TextStyle(fontSize: 16, color: Colors.white))),
              ),
            ],
          ),
        ),
      )
    ]);
  }
}
