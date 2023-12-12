import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//cubits
import '../../../../blocs/account/account_bloc.dart';
import '../../../../cubits/collection/collection_cubit.dart';
//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';
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

class _FormCollectionState extends State<FormCollection> with FormatNumber {
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
                                  .collectionCubit.total! -
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
                        onPressed: () => widget.collectionCubit
                            .goToCamera(widget.orderNumber)),
                    widget.state.enterpriseConfig != null &&
                            widget.state.enterpriseConfig!.codeQr != null
                        ? IconButton(
                            icon: const Icon(Icons.qr_code_2,
                                size: 32, color: kPrimaryColor),
                            onPressed: () =>
                                widget.collectionCubit.goToCodeQR())
                        : Container()
                  ],
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  autofocus: false,
                  controller: widget.collectionCubit.transferController,
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
                          widget.collectionCubit.total -= double.parse(
                              widget.collectionCubit.transferController.text);
                        }
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
                BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) =>
                        state is CollectionInitial &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true,
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
                            true,
                    builder: (c, x) {
                      return x
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
                                      // setState(() {
                                      //   selectedOption = newValue;
                                      //   showDropdownError = false;
                                      // });
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
                                    // validator: (value) {
                                    //   if (showDropdownError &&
                                    //       (value == null ||
                                    //           value.isEmpty ||
                                    //           value == options[0])) {
                                    //     return 'Selecciona una opción válida';
                                    //   }
                                    //   return null;
                                    // },
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
                              data: widget.collectionCubit.selectedAccounts,
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
                const SizedBox(height: 50),
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
