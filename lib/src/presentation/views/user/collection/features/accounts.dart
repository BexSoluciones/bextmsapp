import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
//blocs
import '../../../../blocs/account/account_bloc.dart';
//cubit
import '../../../../cubits/collection/collection_cubit.dart';
//domain
import '../../../../../domain/models/account.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';
import '../../../../widgets/transaction_list.dart';

class AccountsCollection extends StatefulWidget {
  final String orderNumber;
  final CollectionCubit collectionCubit;
  final CollectionState state;

  const AccountsCollection({
    super.key,
    required this.orderNumber,
    required this.collectionCubit,
    required this.state,
  });

  @override
  State<AccountsCollection> createState() => _AccountsCollectionState();
}

class _AccountsCollectionState extends State<AccountsCollection>
    with FormatNumber {

  final _formKey = GlobalKey<FormState>();

  @override
  void setState(VoidCallback fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
        child: SizedBox(
      height: size.height,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: kDefaultPadding, vertical: kDefaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('TOTAL A RECAUDAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formatter.format(widget.collectionCubit.state.totalSummary),
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const Text('TOTAL RECAUDADO',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(formatter.format(widget.collectionCubit.total),
                  style: const TextStyle(fontSize: 18)),
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
                      onPressed: () =>
                          widget.collectionCubit.goToCamera(widget.orderNumber)),
                  widget.state.enterpriseConfig != null &&
                          widget.state.enterpriseConfig!.codeQr != null
                      ? IconButton(
                          icon: const Icon(Icons.qr_code_2,
                              size: 32, color: kPrimaryColor),
                          onPressed: () => widget.collectionCubit.goToCodeQR())
                      : Container()
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                autofocus: false,
                controller: widget.collectionCubit.multiTransferController,
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
                      if (double.tryParse(
                              widget.collectionCubit.multiTransferController.text) !=
                          null) {
                        widget.collectionCubit.total -= double.parse(
                            widget.collectionCubit.multiTransferController.text);
                      }
                      widget.collectionCubit.multiTransferController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ),
                validator: (value) {
                  if(value!.startsWith('.') || value.endsWith('.')) {
                    return 'valor no válido';
                  }
                  if (value.contains(',')) {
                    return '';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Text('NÚMERO DE CUENTA', style: TextStyle(fontSize: 14)),
                    Icon(Icons.account_balance_outlined)
                  ]),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.qr_code_2),
                        onPressed: () => widget.collectionCubit.goToCodeQR(),
                      ),
                    ],
                  )
                ],
              ),
              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, accountBlocState) {
                  if (accountBlocState is AccountLoadingState) {
                    return const CircularProgressIndicator();
                  } else if (accountBlocState is AccountLoadedState) {
                    return DropdownButtonFormField<Account>(
                      itemHeight: null,
                      isExpanded: true,
                      value: accountBlocState.accounts.first,
                      onChanged: (Account? newValue) {
                        widget.collectionCubit.selectedAccount = newValue;
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2.0),
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
                        if (value!.id == 0) {
                          return 'Selecciona una opción válida';
                        }
                        return null;
                      },
                      items: accountBlocState.accounts.map((Account value) {
                        return DropdownMenuItem<Account>(
                          value: value,
                          child: Text(
                            value.accountNumber != null
                                ? '${value.name} - ${value.accountNumber}'
                                : value.name!,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                    );
                  } else if (accountBlocState is AccountErrorState) {
                    return Text('Error: ${accountBlocState.error}');
                  } else {
                    return const Text('No se han cargado datos aún.');
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: widget.collectionCubit
                    .dateController, //editing controller of this TextField
                autofocus: false,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 15.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
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
                    var formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      widget.collectionCubit.dateController.text =
                          formattedDate; //set output date to TextField value.
                    });
                  } else {
                    print('Fecha no seleccionada');
                  }
                },
              ),
              const SizedBox(height: 10),
              DefaultButton(
                  widget: BlocSelector<CollectionCubit, CollectionState, bool>(
                    selector: (state) => state is CollectionEditingPayment,
                    builder: (c, x) {
                      return x ? const Text('Editar',
                          style: TextStyle(color: Colors.white, fontSize: 20)) : const Text('Agregar',
                          style: TextStyle(color: Colors.white, fontSize: 20));
                    },
                  ),
                  press: () {
                    final form = _formKey.currentState;
                    if (form!.validate()) {
                      widget.collectionCubit.addOrUpdatePaymentWithAccount(
                          index: widget.collectionCubit.indexToEdit);
                      setState(() {});
                    }

                  }),
              const SizedBox(height: 10),
              Expanded(
                  child: TransactionList(
                selectedAccounts: widget.collectionCubit.selectedAccounts,
                onDataEdit: (index) {
                  widget.collectionCubit.editPaymentWithAccount(index);
                  setState(() {});
                },
                onTotalChange: (amount) {
                  widget.collectionCubit.total += amount;
                  setState(() {});
                },
                onDataRemove: (removedData) {
                  widget.collectionCubit.selectedAccounts.remove(removedData);
                  setState(() {});
                },
              ))
            ],
          ),
        ),
      ),
    ));
  }
}
