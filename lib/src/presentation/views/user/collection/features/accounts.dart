import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
import '../../../../../utils/constants/strings.dart';
//blocs
import '../../../../blocs/collection/collection_bloc.dart';
import '../../../../blocs/account/account_bloc.dart';
//domain
import '../../../../../domain/models/account.dart';
import '../../../../../domain/abstracts/format_abstract.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';
import '../../../../widgets/transaction_list.dart';
import 'form_payment.dart';

class AccountsCollection extends StatefulWidget {
  final String orderNumber;
  final CollectionBloc collectionBloc;

  const AccountsCollection({
    super.key,
    required this.orderNumber,
    required this.collectionBloc,
  });

  @override
  State<AccountsCollection> createState() => _AccountsCollectionState();
}

class _AccountsCollectionState extends State<AccountsCollection>
    with FormatNumber {
  final _formKey = GlobalKey<FormState>();

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<CollectionBloc, CollectionState>(
        // listenWhen: (previous, current) =>
        //     previous.accounts != previous.accounts,
        // buildWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
      print('listener');
      print(state.accounts);
    }, builder: (context, state) {
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formatter.format(state.totalSummary),
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                const Text('TOTAL RECAUDADO',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(formatter.format(state.total),
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
                        onPressed: () => widget.collectionBloc.add(
                            CollectionNavigate(
                                route: AppRoutes.camera,
                                arguments: widget.orderNumber))),
                    state.enterpriseConfig != null &&
                            state.enterpriseConfig!.codeQr != null
                        ? IconButton(
                            icon: const Icon(Icons.qr_code_2,
                                size: 32, color: kPrimaryColor),
                            onPressed: () => widget.collectionBloc.add(
                                CollectionNavigate(
                                    route: AppRoutes.codeQr,
                                    arguments: state.enterpriseConfig!.codeQr)))
                        : const SizedBox()
                  ],
                ),
                PaymentMultiTransferInputField(),
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
                            onPressed: () => widget.collectionBloc.add(
                                CollectionNavigate(
                                    route: AppRoutes.codeQr,
                                    arguments: state.account!.value?.codeQr))),
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
                        value: state.account?.value ??
                            accountBlocState.accounts.first,
                        onChanged: (account) => context
                            .read<CollectionBloc>()
                            .add(CollectionPaymentAccountChanged(
                                value: account!)),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
                PaymentDateInputField(),
                const SizedBox(height: 10),
                DefaultButton(
                    widget: BlocSelector<CollectionBloc, CollectionState, bool>(
                      selector: (state) => state.isEditing == true,
                      builder: (c, x) {
                        return x
                            ? const Text('Editar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20))
                            : const Text('Agregar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20));
                      },
                    ),
                    press: () {
                      final form = _formKey.currentState;
                      if (form!.validate()) {
                        widget.collectionBloc.add(CollectionAddOrUpdatePayment(
                            index: widget.collectionBloc.state.indexToEdit));
                      }
                    }),
                const SizedBox(height: 10),
                Expanded(
                    child: TransactionList(
                  selectedAccounts: state.accounts ?? [],
                  onDataEdit: (index) => widget.collectionBloc
                      .add(CollectionEditPaymentWithAccount(index: index)),
                  onDataRemove: (payment, amount) => widget.collectionBloc.add(
                      CollectionRemovePayment(payment: payment, value: amount)),
                ))
              ],
            ),
          ),
        ),
      ));
    });
  }
}
