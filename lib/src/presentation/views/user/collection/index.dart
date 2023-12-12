import 'dart:async';
import 'dart:io';
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

  bool isLoading = false;
  double totalSummary = 0;
  double total = 0;
  int cantPictures = 0;

  File? file;
  bool isErrorReasons = false;
  bool isErrorCollection = false;
  static const _locale = 'en';
  String message = '';
  bool showDropdownError = false;
  List<String> options = [];
  List<String> formattedAccountList = [];
  List<dynamic> data = [];
  String? selectedOption = 'Seleccionar cuenta';
  var paymentTransferValue = 0.0;
  var paymentCashValue = 0.0;

  String get _currency =>
      '  ${NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol}';

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController paymentCashController = TextEditingController();
  final TextEditingController paymentTransferController =
      TextEditingController();
  final TextEditingController paymentTransferArrayController =
      TextEditingController();

  String? get firmS => null;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<AccountBloc>().add(LoadAccountListEvent());

    collectionCubit = BlocProvider.of<CollectionCubit>(context);
    collectionCubit.getCollection(
        widget.arguments.work.id!, widget.arguments.orderNumber);

    paymentCashController.addListener(() {
      if (paymentTransferController.text.isNotEmpty &&
          paymentCashController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentCashController.text) +
              double.parse(paymentTransferController.text);
        });
      } else if (paymentCashController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentCashController.text);
        });
      } else if (paymentCashController.text.isEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = 0;
        });
      } else if (paymentTransferController.text.isNotEmpty &&
          paymentCashController.text.isEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text);
        });
      }
    });

    paymentTransferController.addListener(() {
      if (paymentCashController.text.isNotEmpty &&
          paymentTransferController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text) +
              double.parse(paymentCashController.text);
        });
      } else if (paymentTransferController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text);
        });
      } else if (paymentCashController.text.isEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = 0;
        });
      } else if (paymentCashController.text.isNotEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = double.parse(paymentCashController.text);
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    paymentTransferController.dispose();
    paymentCashController.dispose();
    _typeAheadController.dispose();
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
    if (state is CollectionSuccess || state is CollectionFailed) {
      if (state.error != null) {
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
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: kDefaultPadding, right: kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                        'TOTAL A RECAUDAR: \$${formatter.format(state.totalSummary)}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer)),
                    const SizedBox(height: 3),
                    Text(widget.arguments.typeOfCharge,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer))
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.05),
          Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Text('EFECTIVO', style: TextStyle(fontSize: 14)),
                              Icon(Icons.money, color: Colors.green),
                            ]),
                          ]),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        autofocus: false,
                        controller: paymentCashController,
                        onChanged: data.isNotEmpty
                            ? (newValue) {
                                if (newValue.isEmpty) {
                                  setState(() {
                                    data.clear();
                                    paymentTransferArrayController.clear();
                                    paymentCashController.clear();
                                  });
                                }
                              }
                            : null,
                        decoration: InputDecoration(
                          prefixText: _currency,
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (double.tryParse(paymentCashController.text) !=
                                  null) {
                                setState(() {
                                  total = total -
                                      double.parse(paymentCashController.text);
                                });
                              }
                              data.clear();
                              paymentTransferArrayController.clear();
                              paymentCashController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo es requerido';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(children: [
                            Text('TRANSFERENCIA BANCARIA',
                                style: TextStyle(fontSize: 14)),
                            Icon(Icons.credit_card)
                          ]),
                          IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  size: 32, color: kPrimaryColor),
                              onPressed: () => context
                                  .read<CollectionCubit>()
                                  .goToCamera(widget.arguments.orderNumber)),
                          state.enterpriseConfig != null &&
                                  state.enterpriseConfig!.codeQr != null
                              ? IconButton(
                                  icon: const Icon(Icons.qr_code_2,
                                      size: 32, color: kPrimaryColor),
                                  onPressed: () => context
                                      .read<CollectionCubit>()
                                      .goToCodeQR())
                              : Container()
                        ],
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        autofocus: false,
                        controller: data.isEmpty
                            ? paymentTransferController
                            : paymentTransferArrayController,
                        decoration: InputDecoration(
                          prefixText: _currency,
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 2.0),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 2.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (data.isEmpty) {
                                if (double.tryParse(
                                        paymentTransferController.text) !=
                                    null) {
                                  setState(() {
                                    total -= double.parse(
                                        paymentTransferController.text);
                                  });
                                }
                              }
                              paymentTransferController.clear();
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                        validator: (value) {
                          if (value!.contains(',')) {
                            return '';
                          }
                          return null;
                        },
                      ),
                      state.enterpriseConfig != null &&
                              state.enterpriseConfig!
                                      .specifiedAccountTransfer ==
                                  true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(children: [
                                  Text('NÚMERO DE CUENTA',
                                      style: TextStyle(fontSize: 14)),
                                  Icon(Icons.account_balance_outlined)
                                ]),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (data.isNotEmpty) {
                                            paymentTransferController.text = '';
                                          }

                                          if (paymentTransferController
                                              .text.isNotEmpty) {
                                            if (double.tryParse(
                                                    paymentTransferController
                                                        .text) !=
                                                null) {
                                              paymentTransferValue =
                                                  double.parse(
                                                      paymentTransferController
                                                          .text);
                                              var parsedNumberString = '';
                                              if (selectedOption != null) {
                                                var parts = selectedOption!
                                                    .split(' - ');
                                                if (parts.length >= 3) {
                                                  parsedNumberString = parts[2]
                                                      .replaceAll(
                                                          RegExp(r'[^\d]+'),
                                                          '');
                                                }
                                              }
                                              if (paymentCashController
                                                  .text.isNotEmpty) {
                                                paymentCashValue = double.parse(
                                                    paymentCashController.text);
                                              } else {
                                                paymentCashValue = 0;
                                              }
                                              var parsedNumber =
                                                  parsedNumberString.isNotEmpty
                                                      ? int.parse(
                                                          parsedNumberString)
                                                      : null;
                                              var count = 0.0;
                                              data.add([
                                                paymentTransferValue,
                                                parsedNumber,
                                                selectedOption
                                              ]);

                                              for (var i = 0;
                                                  i < data.length;
                                                  i++) {
                                                count += double.parse(
                                                    data[i][0].toString());
                                              }
                                              total = count + paymentCashValue;
                                            }
                                          } else {
                                            if (double.tryParse(
                                                    paymentTransferArrayController
                                                        .text) !=
                                                null) {
                                              paymentTransferValue = double.parse(
                                                  paymentTransferArrayController
                                                      .text);
                                              var parsedNumberString = '';
                                              if (selectedOption != null) {
                                                var parts = selectedOption!
                                                    .split(' - ');
                                                if (parts.length >= 3) {
                                                  parsedNumberString = parts[2]
                                                      .replaceAll(
                                                          RegExp(r'[^\d]+'),
                                                          '');
                                                }
                                              }
                                              if (paymentCashController
                                                  .text.isNotEmpty) {
                                                paymentCashValue = double.parse(
                                                    paymentCashController.text);
                                              } else {
                                                paymentCashValue = 0;
                                              }
                                              var parsedNumber =
                                                  parsedNumberString.isNotEmpty
                                                      ? int.parse(
                                                          parsedNumberString)
                                                      : null;
                                              var count = 0.0;
                                              data.add([
                                                paymentTransferValue,
                                                parsedNumber,
                                                selectedOption
                                              ]);

                                              for (var i = 0;
                                                  i < data.length;
                                                  i++) {
                                                count += double.parse(
                                                    data[i][0].toString());
                                              }
                                              total = count + paymentCashValue;
                                            }
                                          }
                                          for (var element
                                              in widget.arguments.summaries!) {
                                            totalSummary =
                                                element.grandTotalCopy!;
                                          }
                                          if (total != totalSummary) {
                                            message =
                                                'el recaudo debe ser igual al total';
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  message,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.qr_code_2),
                                      onPressed: () {
                                        _navigationService.goTo(
                                            AppRoutes.codeQr,
                                            arguments: _storageService
                                                .getString('code_qr'));
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Container(),
                      state.enterpriseConfig != null &&
                              state.enterpriseConfig!
                                      .specifiedAccountTransfer ==
                                  true
                          ? BlocBuilder<AccountBloc, AccountState>(
                              builder: (context, state) {
                                if (state is AccountLoadingState) {
                                  return const CircularProgressIndicator();
                                } else if (state is AccountLoadedState) {
                                  final formattedAccountLists =
                                      state.formattedAccountList;
                                  return DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: state.formattedAccountList.first,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedOption = newValue;
                                        showDropdownError = false;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: kPrimaryColor, width: 2.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: kPrimaryColor, width: 2.0),
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.orange,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: kPrimaryColor,
                                    ),
                                    dropdownColor: Colors.white,
                                    validator: (value) {
                                      if (showDropdownError &&
                                          (value == null ||
                                              value.isEmpty ||
                                              value == options[0])) {
                                        return 'Selecciona una opción válida';
                                      }
                                      return null;
                                    },
                                    items: formattedAccountLists
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value.contains('-')
                                              ? '${value.split('-')[0]} - ${value.split('-')[1]}'
                                              : 'Seleccionar cuenta',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else if (state is AccountErrorState) {
                                  return Text('Error: ${state.error}');
                                } else {
                                  return const Text(
                                      'No se han cargado datos aún.');
                                }
                              },
                            )
                          : Container(),
                      state.enterpriseConfig != null &&
                              state.enterpriseConfig!
                                      .specifiedAccountTransfer ==
                                  true
                          ? TransactionList(
                              data: data,
                              onTotalChange: (amount) {
                                setState(() {
                                  total += amount;
                                });
                              },
                              onDataRemove: (removedData) {
                                setState(() {
                                  data.remove(removedData);
                                });
                              },
                            )
                          : Container(),
                      const SizedBox(height: 50),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total:',
                                style: TextStyle(fontSize: 20)),
                            Text('\$${formatter.format(total)}',
                                style: const TextStyle(fontSize: 20)),
                          ]),
                    ],
                  ))),
          Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: DefaultButton(
                  widget: const Icon(Icons.edit, color: Colors.white),
                  press: () => context
                      .read<CollectionCubit>()
                      .goToFirm(widget.arguments.orderNumber))),
          SizedBox(height: size.height * 0.10),
          isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                      left: kDefaultPadding, right: kDefaultPadding),
                  child: DefaultButton(
                      widget: const Text('Confirmar',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      press: () async {
                        final form = _formKey.currentState;
                        if (form!.validate()) {
                          final allowInsetsBelow =
                              state.enterpriseConfig!.allowInsetsBelow;
                          final allowInsetsAbove =
                              state.enterpriseConfig!.allowInsetsAbove;

                          logDebugFine(
                              headerCollectionLogger, allowInsetsBelow.toString());
                          logDebugFine(
                              headerCollectionLogger, allowInsetsAbove.toString());

                          if (state.enterpriseConfig!
                                      .specifiedAccountTransfer ==
                                  true &&
                              paymentTransferController.text.isNotEmpty) {
                            if (selectedOption == 'Seleccionar cuenta') {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Selecciona un numero de cuenta',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                              return;
                            }
                          }

                          if (widget.arguments.typeOfCharge == 'CREDITO' &&
                              total == 0) {
                            _storageService.setBool('firmRequired', false);
                            _storageService.setBool('photoRequired', false);
                            await context
                                .read<CollectionCubit>()
                                .confirmTransaction(
                                    widget.arguments,
                                    paymentCashController,
                                    paymentTransferController,
                                    data);
                            return;
                          }

                          if ((allowInsetsBelow == null ||
                                  allowInsetsBelow == false) &&
                              (allowInsetsAbove == null ||
                                  allowInsetsAbove == false)) {
                            if (total == state.totalSummary!.toDouble()) {
                              _storageService.setBool('firmRequired', false);
                              _storageService.setBool('photoRequired', false);
                              await context
                                  .read<CollectionCubit>()
                                  .confirmTransaction(
                                      widget.arguments,
                                      paymentCashController,
                                      paymentTransferController,
                                      data);
                              return;
                            } else {
                              message = 'el recaudo debe ser igual al total';
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    message,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                          } else if ((allowInsetsBelow != null &&
                                  allowInsetsBelow == true) &&
                              (allowInsetsAbove != null &&
                                  allowInsetsAbove == true)) {
                            _storageService.setBool('firmRequired', false);
                            _storageService.setBool('photoRequired', false);

                            if (total <= state.totalSummary!.toDouble()) {
                              await context
                                  .read<CollectionCubit>()
                                  .confirmTransaction(
                                      widget.arguments,
                                      paymentCashController,
                                      paymentTransferController,
                                      data);
                            } else {
                              await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return MyDialog(
                                      total: total,
                                      totalSummary:
                                          state.totalSummary!.toDouble(),
                                      confirmateTransaction: () => context
                                          .read<CollectionCubit>()
                                          .confirmTransaction(
                                              widget.arguments,
                                              paymentCashController,
                                              paymentTransferController,
                                              data),
                                      context: context,
                                    );
                                  });
                            }

                            return;
                          } else if ((allowInsetsBelow != null &&
                                  allowInsetsBelow == true) &&
                              (allowInsetsAbove == null ||
                                  allowInsetsAbove == false)) {
                            logDebugFine(headerCollectionLogger, total.toString());
                            logDebugFine(headerCollectionLogger,
                                state.totalSummary!.toDouble().toString());

                            if (total <= state.totalSummary!.toDouble()) {
                              _storageService.setBool('firmRequired', false);
                              _storageService.setBool('photoRequired', false);
                              await context
                                  .read<CollectionCubit>()
                                  .confirmTransaction(
                                      widget.arguments,
                                      paymentCashController,
                                      paymentTransferController,
                                      data);
                            } else {
                              message =
                                  'el recaudo debe ser igual o menor al total';
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    message,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return;
                          } else if ((allowInsetsBelow == null ||
                                  allowInsetsBelow == false) &&
                              (allowInsetsAbove != null &&
                                  allowInsetsAbove == true)) {
                            if (total >= state.totalSummary!.toDouble()) {
                              _storageService.setBool('firmRequired', false);
                              _storageService.setBool('photoRequired', false);
                              await showDialog(
                                  context: context,
                                  builder: (_) {
                                    return MyDialog(
                                      total: total,
                                      totalSummary:
                                          state.totalSummary!.toDouble(),
                                      confirmateTransaction: () => context
                                          .read<CollectionCubit>()
                                          .confirmTransaction(
                                              widget.arguments,
                                              paymentCashController,
                                              paymentTransferController,
                                              data),
                                      context: context,
                                    );
                                  });
                            } else {
                              message =
                                  'el recaudo debe ser igual o mayor al total';
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    message,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }

                            return;
                          }
                        }
                      })),
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
