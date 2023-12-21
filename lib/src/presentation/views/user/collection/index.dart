import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../blocs/account/account_bloc.dart';

//cubit
import '../../../cubits/collection/collection_cubit.dart';

//utils
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//widgets
import '../../../widgets/default_button_widget.dart';
//features
import './features/form.dart';
import './features/header.dart';

class CollectionView extends StatefulWidget {
  const CollectionView({Key? key, required this.arguments}) : super(key: key);

  final InventoryArgument arguments;

  @override
  State<CollectionView> createState() => CollectionViewState();
}

class CollectionViewState extends State<CollectionView> with FormatNumber {
  final _formKey = GlobalKey<FormState>();

  late CollectionCubit collectionCubit;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<AccountBloc>().add(LoadAccountListEvent());
    collectionCubit = BlocProvider.of<CollectionCubit>(context);
    collectionCubit.getCollection(
        widget.arguments.work.id!, widget.arguments.summary.orderNumber);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      collectionCubit.cashController.addListener(() {
        collectionCubit.listenForCash();
        setState(() {});
      });
      collectionCubit.transferController.addListener(() {
        if (!collectionCubit.isEditing) {
          collectionCubit.listenForTransfer();
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    // collectionCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    FocusScopeNode currentFocus;

    void unfocus() {
      currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    return GestureDetector(
        onTap: unfocus,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.read<CollectionCubit>().goBack(),
              ),
            ),
            body: BlocBuilder<CollectionCubit, CollectionState>(
              builder: (_, state) => _buildBlocConsumer(size),
            )));
  }

  void buildBlocListener(BuildContext context, CollectionState state) async {
    if (state is CollectionSuccess) {
      if (state.validate != null && state.validate == true) {
        collectionCubit.goToWork(state.work);
      } else if (state.validate != null && state.validate == false) {
        collectionCubit.goToSummary(state.work);
      }
    } else if (state is CollectionFailed && state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            state.error!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (state is CollectionWaiting) {
      await showDialog(
          context: context,
          builder: (_) {
            return MyDialog(
              total: collectionCubit.total,
              totalSummary: state.totalSummary!.toDouble(),
              confirmTransaction: () => collectionCubit.confirmTransaction(
                widget.arguments,
              ),
              context: context,
            );
          });
    }
  }

  Widget _buildBlocConsumer(Size size) {
    return BlocConsumer<CollectionCubit, CollectionState>(
      // buildWhen: (previous, current) => previous != current,
      listener: buildBlocListener,
      builder: (context, state) {
        if (state is CollectionLoading ||
            state is CollectionInitial ||
            state is CollectionModalClosed ||
            state is CollectionFailed) {
          return _buildCollection(size, state);
        } else if (state is CollectionSuccess) {
          return _buildSuccessTransaction(size);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildCollection(Size size, CollectionState state) {
    return SingleChildScrollView(
        child: SafeArea(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(children: [
          HeaderCollection(
              type: widget.arguments.summary.typeOfCharge!,
              total: state.totalSummary ?? 0.0),
          SizedBox(height: size.height * 0.02),
          FormCollection(
              formKey: _formKey,
              collectionCubit: collectionCubit,
              state: state,
              orderNumber: widget.arguments.summary.orderNumber),
          Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: DefaultButton(
                  widget: const Icon(Icons.edit, color: Colors.white),
                  press: () => context
                      .read<CollectionCubit>()
                      .goToFirm(widget.arguments.summary.orderNumber))),
          SizedBox(height: size.height * 0.05),
          BlocSelector<CollectionCubit, CollectionState, bool>(
              selector: (state) => state is CollectionLoading,
              builder: (BuildContext c, x) {
                return x
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: kDefaultPadding, right: kDefaultPadding),
                        child: DefaultButton(
                            widget: const Text('Confirmar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            press: () async {
                              final form = _formKey.currentState;
                              if (form!.validate()) {
                                collectionCubit.validate(widget.arguments);
                              }
                            }));
              })
        ]),
      ),
    ));
  }

  Widget _buildSuccessTransaction(Size size) {
    return SafeArea(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 50, color: Colors.green),
              Text('Transación exitosa.')
            ],
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog(
      {Key? key,
      required this.totalSummary,
      required this.total,
      required this.confirmTransaction,
      required this.context})
      : super(key: key);

  final double totalSummary;
  final double total;
  final Function confirmTransaction;
  final BuildContext context;

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> with FormatNumber {
  var seconds = 5;
  var showText = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (seconds == 0) {
          setState(() {
            timer.cancel();
            showText = true;
          });
        } else {
          setState(() {
            seconds--;
            showText = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar recaudo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
                'Valor a recaudar: \$${formatter.format(widget.totalSummary)}'),
            Text('Valor a guardar: por \$${formatter.format(widget.total)}'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: showText ? const Text('Si') : Text(seconds.toString()),
          onPressed: () {
            widget.confirmTransaction(context);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
