import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../cubits/partial/partial_cubit.dart';

//domain
import '../../../../domain/models/arguments.dart';

//utils
import '../../../../utils/constants/nums.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

//features
import 'features/header.dart';
import 'features/reason_global_page.dart';

//widgets
import '../../../widgets/default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();

class PartialView extends StatefulWidget {
  const PartialView({Key? key, required this.arguments}) : super(key: key);

  final InventoryArgument arguments;

  @override
  State<PartialView> createState() => _PartialViewState();
}

class _PartialViewState extends State<PartialView> {
  late PartialCubit partialCubit;

  @override
  void initState() {
    partialCubit = BlocProvider.of<PartialCubit>(context);
    partialCubit.init(widget.arguments);
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
          onPressed: () => _navigationService.goBack(),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
            height: size.height * 0.25,
            width: size.width,
            child: HeaderPartial(arguments: widget.arguments),
          ),
          BlocBuilder<PartialCubit, PartialState>(builder: (context, state) {
            switch (state.runtimeType) {
              case PartialLoading:
                return const Center(child: CupertinoActivityIndicator());
              case PartialSuccess:
                return buildBody(size, state);
              case PartialFailed:
                return buildBody(size, state);
              default:
                return const SliverToBoxAdapter();
            }
          })
        ],
      ),
    );
  }

  SizedBox buildBody(Size size, PartialState state) {
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
                  '¿Estas seguro de confirmar esta entrega como parcial?',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: BlocListener<PartialCubit, PartialState>(
                    listener: (context, state) {},
                    child: ReasonsGlobal(
                      context: context,
                      r: state.products,
                      setState: setState,
                      type: 'partial',
                      reasons: state.reasons!,
                    ))),
            const Spacer(),
            if (state.error != null)
              Text(state.error!,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            DefaultButton(
                widget: const Text('Confirmar',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    )),
                press: () {
                  BlocProvider.of<PartialCubit>(context)
                      .goToCollection(widget.arguments);
                })
          ],
        ),
      ),
    );
  }
}
