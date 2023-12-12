import 'dart:async';
import 'dart:io';
import 'package:bexdeliveries/src/presentation/views/user/collection/features/form.dart';
import 'package:bexdeliveries/src/presentation/views/user/collection/features/header.dart';
import 'package:bexdeliveries/src/services/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

//blocs
import '../../../blocs/account/account_bloc.dart';

//cubit
import '../../../cubits/collection/collection_cubit.dart';

//utils
import '../../../../utils/constants/strings.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';
import '../../../../services/storage.dart';

//widgets
import '../../../widgets/default_button_widget.dart';
import '../../../widgets/transaction_list.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();
final NavigationService _navigationService = locator<NavigationService>();

class CollectionView extends StatefulWidget {
  const CollectionView({Key? key, required this.arguments}) : super(key: key);

  final InventoryArgument arguments;

  @override
  State<CollectionView> createState() => CollectionViewState();
}

class CollectionViewState extends State<CollectionView>
    with WidgetsBindingObserver, FormatNumber {
  final _formKey = GlobalKey<FormState>();

  late CollectionCubit collectionCubit;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<AccountBloc>().add(LoadAccountListEvent());
    collectionCubit = BlocProvider.of<CollectionCubit>(context);
    collectionCubit.getCollection(
        widget.arguments.work.id!, widget.arguments.orderNumber);
    collectionCubit.cashController.addListener(collectionCubit.listenForCash);
    collectionCubit.transferController
        .addListener(collectionCubit.listenForTransfer);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    collectionCubit.dispose();
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

  void buildBlocListener(context, CollectionState state) {
    print(state);
    if (state is CollectionSuccess || state is CollectionFailed) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              state.error!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      } else {
        if (state.validate != null && state.validate == true) {
          collectionCubit.goToWork(state.work);
        } else if (state.validate != null && state.validate == false) {
          collectionCubit.goToSummary(state.work);
        }
      }
    } else {
      print('failed');
    }
  }

  Widget _buildBlocConsumer(Size size) {
    return BlocConsumer<CollectionCubit, CollectionState>(
      listener: buildBlocListener,
      builder: (context, state) {
        switch (state.runtimeType) {
          case CollectionLoading:
            return const Center(child: CupertinoActivityIndicator());
          case CollectionInitial:
            return _buildCollection(size, state);
          case CollectionSuccess:
            return _buildSuccessTransaction(size);
          default:
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
              type: widget.arguments.typeOfCharge, total: state.totalSummary!),
          SizedBox(height: size.height * 0.02),
          FormCollection(
              formKey: _formKey,
              collectionCubit: collectionCubit,
              state: state,
              orderNumber: widget.arguments.orderNumber),
          Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: DefaultButton(
                  widget: const Icon(Icons.edit, color: Colors.white),
                  press: () => context
                      .read<CollectionCubit>()
                      .goToFirm(widget.arguments.orderNumber))),
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
                              if (form!.validate()) collectionCubit.validate();
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
      required this.confirmateTransaction,
      required this.context})
      : super(key: key);

  final double totalSummary;
  final double total;
  final Function confirmateTransaction;
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
            widget.confirmateTransaction(context);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
