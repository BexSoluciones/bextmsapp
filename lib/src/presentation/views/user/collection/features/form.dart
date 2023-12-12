import 'package:bexdeliveries/src/domain/models/account.dart';
import 'package:bexdeliveries/src/presentation/views/user/collection/features/accounts.dart';
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
import '../../../../../domain/abstracts/format_abstract.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';
import '../../../../widgets/transaction_list.dart';

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
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: kDefaultPadding, right: kDefaultPadding),
        child: Form(
            key: widget.formKey,
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
                        widget.collectionCubit.transferController.clear();
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
                //TODO:: [Heider Zapa] fix multiple accounts
                const SizedBox(height: 10),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        state is CollectionInitial &&
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
                                widget.state.enterpriseConfig != null &&
                                        widget.state.enterpriseConfig!.codeQr !=
                                            null
                                    ? IconButton(
                                        icon: const Icon(Icons.qr_code_2,
                                            size: 32, color: kPrimaryColor),
                                        onPressed: () =>
                                            widget.collectionCubit.goToCodeQR())
                                    : Container()
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
                        state is CollectionInitial &&
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
                                if (value!.contains(',')) {
                                  return '';
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
                                    now();
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (c) {
                                      return AccountsCollection(
                                        orderNumber: widget.orderNumber,
                                        collectionCubit: widget.collectionCubit,
                                        state: widget.state,
                                      );
                                    });
                              });
                    }),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        state is CollectionInitial &&
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
                                      onPressed: () {
                                        widget.collectionCubit.addAccount();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.add),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.qr_code_2),
                                      onPressed: () => widget.collectionCubit
                                          .goToCamera(widget.orderNumber),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Container();
                    }),
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        state is CollectionInitial &&
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
                                      widget.collectionCubit.accountId =
                                          newValue?.accountId;
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
                                      if (value == null) {
                                        return 'Selecciona una opción válida';
                                      }
                                      return null;
                                    },
                                    items: accountBlocState.accounts
                                        .map((Account value) {
                                      return DropdownMenuItem<Account>(
                                        value: value,
                                        child: Text(
                                          '${value.name} - ${value.accountNumber}',
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
                        state is CollectionInitial &&
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
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        state is CollectionInitial &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true,
                    builder: (c, x) {
                      return x
                          ? TransactionList(
                              selectedAccounts:
                                  widget.collectionCubit.selectedAccounts,
                              onTotalChange: (amount) {
                                widget.collectionCubit.total += amount;
                                setState(() {});
                              },
                              onDataRemove: (removedData) {
                                widget.collectionCubit.selectedAccounts
                                    .remove(removedData);
                                setState(() {});
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
