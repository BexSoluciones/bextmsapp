import 'dart:io';
import 'package:bexdeliveries/src/presentation/blocs/account/account_bloc.dart';
import 'package:bexdeliveries/src/utils/constants/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

//cubit
import '../../../../config/size.dart';
import '../../../../services/navigation.dart';
import '../../../cubits/collection/collection_cubit.dart';

//utils
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//services
import '../../../../locator.dart';
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
  final allowInsetsBelow = _storageService.getBool('allow_insets_below');
  bool showDropdownError = false;
  List<String> options = [];
  List<String> formattedAccountList = [];
  List<dynamic> data = [];
  String? selectedOption = 'Seleccionar cuenta';
  var paymentTransferValue = 0.0;
  var paymentEfectyValue = 0.0;

  String get _currency =>
      '  ${NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol}';

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController paymentEfectyController = TextEditingController();
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

    paymentEfectyController.addListener(() {
      if (paymentTransferController.text.isNotEmpty &&
          paymentEfectyController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentEfectyController.text) +
              double.parse(paymentTransferController.text);
        });
      } else if (paymentEfectyController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentEfectyController.text);
        });
      } else if (paymentEfectyController.text.isEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = 0;
        });
      } else if (paymentTransferController.text.isNotEmpty &&
          paymentEfectyController.text.isEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text);
        });
      }
    });

    paymentTransferController.addListener(() {
      if (paymentEfectyController.text.isNotEmpty &&
          paymentTransferController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text) +
              double.parse(paymentEfectyController.text);
        });
      } else if (paymentTransferController.text.isNotEmpty) {
        setState(() {
          total = double.parse(paymentTransferController.text);
        });
      } else if (paymentEfectyController.text.isEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = 0;
        });
      } else if (paymentEfectyController.text.isNotEmpty &&
          paymentTransferController.text.isEmpty) {
        setState(() {
          total = double.parse(paymentEfectyController.text);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    paymentTransferController.dispose();
    paymentEfectyController.dispose();
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
              builder: (_, state) {
                switch (state.runtimeType) {
                  case CollectionLoading:
                    return Center(
                        child: SpinKitCircle(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100.0,
                    ));
                  case CollectionSuccess:
                    return _buildCollection(
                      size,
                      state,
                    );
                  default:
                    return const SizedBox();
                }
              },
            )));
  }

  Widget _buildCollection(Size size, CollectionState state) {
    return SingleChildScrollView(
        child: SafeArea(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
            children: [
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
                        controller: paymentEfectyController,
                        onChanged: data.isNotEmpty
                            ? (newValue) {
                                if (newValue.isEmpty) {
                                  setState(() {
                                    data.clear();
                                    paymentTransferArrayController.clear();
                                    paymentEfectyController.clear();
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
                              if (double.tryParse(
                                      paymentEfectyController.text) !=
                                  null) {
                                setState(() {
                                  total = total -
                                      double.parse(
                                          paymentEfectyController.text);
                                });
                              }
                              data.clear();
                              paymentTransferArrayController.clear();
                              paymentEfectyController.clear();
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
                                if (double.tryParse(paymentTransferController.text) != null) {
                                  setState(() {
                                    total -=double.parse(paymentTransferController.text);
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
                                              if (paymentEfectyController
                                                  .text.isNotEmpty) {
                                                paymentEfectyValue =
                                                    double.parse(
                                                        paymentEfectyController
                                                            .text);
                                              } else {
                                                paymentEfectyValue = 0;
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
                                              total =
                                                  count + paymentEfectyValue;
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
                                              if (paymentEfectyController
                                                  .text.isNotEmpty) {
                                                paymentEfectyValue =
                                                    double.parse(
                                                        paymentEfectyController
                                                            .text);
                                              } else {
                                                paymentEfectyValue = 0;
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
                                              total =
                                                  count + paymentEfectyValue;
                                            }
                                          }
                                          for (var element in widget.arguments.summaries!) {
                                            totalSummary = element.grandTotalCopy!;
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
                                            CodigoQRouteTransf,
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
                          switch (state.enterpriseConfig?.allowInsetsBelow) {
                            case false:
                              if (widget.arguments.typeOfCharge == 'CREDITO' &&
                                  total == 0.0) {
                                await context
                                    .read<CollectionCubit>()
                                    .confirmTransaction(
                                        widget.arguments,
                                        paymentEfectyController,
                                        paymentTransferController,
                                       data
                                );
                              } else if (total != state.totalSummary) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'El valor a recaudar debe ser igual al total',
                                            style: TextStyle(
                                                color: Colors.white))));
                              } else {
                                await context
                                    .read<CollectionCubit>()
                                    .confirmTransaction(
                                        widget.arguments,
                                        paymentEfectyController,
                                        paymentTransferController,data);
                              }
                              break;
                            case true:
                              if (total <= state.totalSummary!.toDouble() ||
                                  widget.arguments.typeOfCharge == 'CREDITO') {
                                await context
                                    .read<CollectionCubit>()
                                    .confirmTransaction(
                                        widget.arguments,
                                        paymentEfectyController,
                                        paymentTransferController,data);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                            'El recaudo no puede ser mayor al total',
                                            style: TextStyle(
                                                color: Colors.white))));
                              }
                              break;
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              backgroundColor: Colors.orange,
                              content: Text(
                                  'El recaudo solo puede contener puntos y unicamente para los decimales, ejemplo: 127809.64',
                                  style: TextStyle(color: Colors.white))));
                        }
                      })),

        ]),
      ),
    ));
  }
}
