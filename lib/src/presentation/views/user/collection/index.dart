import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

//cubit
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

final LocalStorageService _storageService = locator<LocalStorageService>();

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

  String get _currency =>
      '  ${NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol}';

  final TextEditingController _typeAheadController = TextEditingController();
  final TextEditingController paymentEfectyController = TextEditingController();
  final TextEditingController paymentTransferController =
      TextEditingController();

  String? get firmS => null;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

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
            resizeToAvoidBottomInset: false,
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
                    return const Center(child: CupertinoActivityIndicator());
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
        child: ListView(children: [
          SizedBox(
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
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(widget.arguments.typeOfCharge,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))
                ],
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

                              paymentEfectyController.clear();
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
                          state.enterpriseConfig != null && state.enterpriseConfig!.codeQr != null
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
                        controller: paymentTransferController,
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
                                      paymentTransferController.text) !=
                                  null) {
                                setState(() {
                                  total = total -
                                      double.parse(
                                          paymentTransferController.text);
                                });
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
                      state.enterpriseConfig != null && state.enterpriseConfig!.specifiedAccountTransfer == true
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Text('NÚMERO DE CUENTA',
                                      style: TextStyle(fontSize: 14)),
                                  Icon(Icons.account_balance_outlined)
                                ]),
                              ],
                            )
                          : Container(),
                      state.enterpriseConfig != null && state.enterpriseConfig!.specifiedAccountTransfer == true
                          ? DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: null,
                              onChanged: (String? newValue) {
                                // setState(() {
                                //   selectedOption = newValue;
                                //   showDropdownError = false;
                                // });
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.grey, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: kPrimaryColor, width: 2.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: kPrimaryColor, width: 2.0),
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
                                // if (showDropdownError &&
                                //     (value == null ||
                                //         value.isEmpty ||
                                //         value == options[0])) {
                                //   return 'Selecciona una opción válida';
                                // }
                                return null;
                              },
                              items: [
                                'cuenta 1'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.contains('-')
                                        ? '${value.split('-')[0]} - ${value.split('-')[1]}'
                                        : 'Selecciona una cuenta',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                );
                              }).toList(),
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
          SizedBox(height: size.height * 0.12),
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
                                        paymentTransferController);
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
                                        paymentTransferController);
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
                                        paymentTransferController);
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
