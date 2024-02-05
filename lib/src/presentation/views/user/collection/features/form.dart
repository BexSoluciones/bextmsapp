import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//blocs
import '../../../../blocs/account/account_bloc.dart';
//cubits
import '../../../../cubits/collection/collection_cubit.dart';
//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
//domain
import '../../../../../domain/models/account.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';
import '../features/accounts.dart';

class FormCollection extends StatefulWidget {
  final GlobalKey formKey;
  final String orderNumber;
  final CollectionCubit collectionCubit;
  final CollectionState state;

  const FormCollection(
      {super.key,
      required this.formKey,
      required this.collectionCubit,
      required this.state,
      required this.orderNumber});

  @override
  State<FormCollection> createState() => _FormCollectionState();
}

class _FormCollectionState extends State<FormCollection>
    with FormatNumber, FormatDate {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _closeModal(void value) => widget.collectionCubit.closeModal();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: kDefaultPadding, right: kDefaultPadding),
        child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Text('EFECTIVO', style: TextStyle(fontSize: 14)),
                        const Icon(Icons.money, color: Colors.green),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                        ),
                        BlocSelector<CollectionCubit, CollectionState, bool>(
                            selector: (state) =>
                                (state is CollectionInitial ||
                                    state is CollectionLoading ||
                                    state is CollectionFailed) &&
                                state.enterpriseConfig != null &&
                                state.enterpriseConfig!.multipleAccounts ==
                                    true,
                            builder: (c, x) {
                              return x
                                  ? IconButton(
                                      icon: const Icon(Icons.camera_alt,
                                          size: 32, color: kPrimaryColor),
                                      onPressed: () => widget.collectionCubit
                                          .goToCamera(widget.orderNumber))
                                  : Container();
                            }),
                      ]),
                    ]),
                TextFormField(
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  controller: widget.collectionCubit.cashController,
                  onChanged: widget.collectionCubit.selectedAccounts.isNotEmpty
                      ? (newValue) {
                          if (newValue.isEmpty) {
                            widget.collectionCubit.selectedAccounts.clear();
                            widget.collectionCubit.cashController.clear();
                            setState(() {});
                          }
                        }
                      : null,
                  decoration: InputDecoration(
                    prefixText: currency,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (double.tryParse(widget
                                .collectionCubit.transferController.text) !=
                            null) {
                          widget.collectionCubit.total = widget
                                  .collectionCubit.total -
                              double.parse(
                                  widget.collectionCubit.cashController.text);
                        }
                        widget.collectionCubit.selectedAccounts.clear();
                        widget.collectionCubit.cashController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  validator: (value) {
                    if (value!.startsWith('.') || value.endsWith('.')) {
                      return 'valor no válido';
                    }
                    if (value.contains(',')) {
                      return 'no debe contener comas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    bloc: widget.collectionCubit,
                    selector: (state) =>
                        (state is CollectionInitial ||
                            state is CollectionLoading ||
                            state is CollectionFailed) &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? Row(
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
                                    onPressed: () => widget.collectionCubit
                                        .goToCamera(widget.orderNumber)),
                                BlocSelector<CollectionCubit, CollectionState,
                                        bool>(
                                    bloc: widget.collectionCubit,
                                    selector: (state) =>
                                        (state is CollectionInitial ||
                                            state is CollectionLoading ||
                                            state is CollectionFailed) &&
                                        state.enterpriseConfig != null &&
                                        state.enterpriseConfig!.codeQr != null,
                                    builder: (c, x) {
                                      return x
                                          ? IconButton(
                                              icon: const Icon(Icons.qr_code_2,
                                                  size: 32,
                                                  color: kPrimaryColor),
                                              onPressed: () => widget
                                                  .collectionCubit
                                                  .goToCodeQR(widget
                                                      .state
                                                      .enterpriseConfig!
                                                      .codeQr))
                                          : Container();
                                    }),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Text('TRANSFERENCIA BANCARIA',
                                      style: TextStyle(fontSize: 14)),
                                  Icon(Icons.credit_card)
                                ])
                              ],
                            );
                    }),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        (state is CollectionInitial ||
                            state is CollectionLoading ||
                            state is CollectionFailed) &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? TextFormField(
                              keyboardType: TextInputType.number,
                              autofocus: false,
                              controller:
                                  widget.collectionCubit.transferController,
                              decoration: InputDecoration(
                                prefixText: currency,
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 2.0),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.0),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.0),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (double.tryParse(widget.collectionCubit
                                            .transferController.text) !=
                                        null) {
                                      widget.collectionCubit.total -=
                                          double.parse(widget.collectionCubit
                                              .transferController.text);
                                    }
                                    widget.collectionCubit.transferController
                                        .clear();
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                              validator: (value) {
                                if (value!.startsWith('.') ||
                                    value.endsWith('.')) {
                                  return 'valor no válido';
                                }
                                if (value.contains(',')) {
                                  return 'el valor no puede contener comas';
                                }
                                return null;
                              },
                            )
                          : DefaultButton(
                              widget: const Text('Cuentas Bancarias',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              press: () {
                                widget.collectionCubit.dateController.text =
                                    date(null);
                                widget.collectionCubit.selectedAccount = null;
                                widget.collectionCubit.indexToEdit = null;
                                widget.collectionCubit.isEditing = false;
                                Future<void> future = showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (c) {
                                      return AccountsCollection(
                                        orderNumber: widget.orderNumber,
                                        collectionCubit: widget.collectionCubit,
                                        state: widget.state,
                                      );
                                    });

                                future.then((void value) => _closeModal(value));
                              });
                    }),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        (state is CollectionInitial ||
                            state is CollectionLoading ||
                            state is CollectionFailed) &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
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
                                      icon: const Icon(Icons.qr_code_2),
                                      onPressed: () {
                                        if (widget.collectionCubit
                                                .selectedAccount !=
                                            null) {
                                          widget.collectionCubit.goToCodeQR(
                                              widget.collectionCubit
                                                  .selectedAccount!.codeQr);
                                        } else {
                                          widget.collectionCubit.error();
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Container();
                    }),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        (state is CollectionInitial ||
                            state is CollectionLoading ||
                            state is CollectionFailed) &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? BlocBuilder<AccountBloc, AccountState>(
                              builder: (context, accountBlocState) {
                                if (accountBlocState is AccountLoadingState) {
                                  return const CircularProgressIndicator();
                                } else if (accountBlocState
                                    is AccountLoadedState) {
                                  return DropdownButtonFormField<Account>(
                                    itemHeight: null,
                                    isExpanded: true,
                                    value: accountBlocState.accounts.first,
                                    onChanged: (Account? newValue) {
                                      widget.collectionCubit.selectedAccount =
                                          newValue;
                                      setState(() {});
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                      // fontSize: 10,
                                      color: kPrimaryColor,
                                    ),
                                    dropdownColor: Colors.white,
                                    validator: (value) {
                                      if (widget
                                              .collectionCubit
                                              .transferController
                                              .text
                                              .isNotEmpty &&
                                          value!.id == 0) {
                                        return 'Selecciona una opción válida';
                                      }
                                      return null;
                                    },
                                    items: accountBlocState.accounts
                                        .map((Account value) {
                                      return DropdownMenuItem<Account>(
                                        value: value,
                                        child: Text(
                                          value.accountNumber != null
                                              ? '${value.name} - ${value.accountNumber}'
                                              : value.name!,
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else if (accountBlocState
                                    is AccountErrorState) {
                                  return Text(
                                      'Error: ${accountBlocState.error}');
                                } else {
                                  return const Text(
                                      'No se han cargado datos aún.');
                                }
                              },
                            )
                          : Container();
                    }),
                const SizedBox(height: 10),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        (state is CollectionInitial ||
                            state is CollectionLoading ||
                            state is CollectionFailed) &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? TextField(
                              controller: widget.collectionCubit
                                  .dateController, //editing controller of this TextField
                              autofocus: false,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(left: 15.0),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: kPrimaryColor, width: 2.0),
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                var pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));

                                if (pickedDate != null) {
                                  var formattedDate = DateFormat('yyyy-MM-dd')
                                      .format(pickedDate);
                                  setState(() {
                                    widget.collectionCubit.dateController.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                } else {
                                  print('Fecha no seleccionada');
                                }
                              },
                            )
                          : Container();
                    }),
                const SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20)),
                      Text(
                          '\$${formatter.format(widget.collectionCubit.total)}',
                          style: const TextStyle(fontSize: 20)),
                    ]),
              ],
            )));
  }
}
