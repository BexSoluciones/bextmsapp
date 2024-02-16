import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';
import '../../../../../domain/models/account.dart';
//blocs
import '../../../../blocs/account/account_bloc.dart';
import '../../../../blocs/collection/collection_bloc.dart';
//utils
import '../../../../../utils/constants/colors.dart';
//widgets
import '../../../../widgets/text_input_widget.dart';

class PaymentEfectyInputField extends StatelessWidget with FormatNumber {
  PaymentEfectyInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) => current.efecty != previous.efecty,
          builder: (context, state) => textField(
                context: context,
                prefixText: currency,
                onChanged: (efecty) => context
                    .read<CollectionBloc>()
                    .add(CollectionPaymentEfectyChanged(value: efecty)),
                keyBoardType: TextInputType.number,
                errorText:
                    state.efecty.hasError ? state.efecty.errorMessage : null,
              ));
}

class PaymentTransferInputField extends StatelessWidget with FormatNumber {
  PaymentTransferInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) =>
              current.transfer != previous.transfer,
          builder: (context, state) => textField(
                context: context,
                onChanged: (transfer) => context
                    .read<CollectionBloc>()
                    .add(CollectionPaymentTransferChanged(value: transfer)),
                keyBoardType: TextInputType.number,
                errorText: state.transfer.hasError
                    ? state.transfer.errorMessage
                    : null,
                prefixText: currency,
              ));
}

class PaymentMultiTransferInputField extends StatelessWidget with FormatNumber {
  PaymentMultiTransferInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) =>
              current.multiTransfer != previous.multiTransfer,
          builder: (context, state) => textField(
                context: context,
                onChanged: (transfer) => context
                    .read<CollectionBloc>()
                    .add(CollectionPaymentTransferChanged(value: transfer)),
                errorText: state.multiTransfer.hasError
                    ? state.multiTransfer.errorMessage
                    : null,
                prefixText: currency,
              ));
}

class PaymentAccountsInputField extends StatelessWidget {
  const PaymentAccountsInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionBloc, CollectionState>(
        buildWhen: (previous, current) => previous.account != current.account,
        builder: (context, state) {
          return BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountBlocState) {
              if (accountBlocState is AccountLoadingState) {
                return const CircularProgressIndicator();
              } else if (accountBlocState is AccountLoadedState) {
                return DropdownButtonFormField<Account>(
                  itemHeight: null,
                  isExpanded: true,
                  value: accountBlocState.accounts.first,
                  onChanged: (account) => context
                      .read<CollectionBloc>()
                      .add(CollectionPaymentAccountChanged(value: account!)),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
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
                    if (state.transfer.value.isNotEmpty && value!.id == 0) {
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
          );
        });
  }
}

class PaymentDateInputField extends StatelessWidget with FormatDate {
  PaymentDateInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) => current.date != previous.date,
          builder: (context, state) => textField(
              key: UniqueKey(),
              initialValue: state.date.value,
              readOnly: true,
              context: context,
              onTap: () async {
                var pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101));

                if (pickedDate != null && context.mounted) {
                  var formattedDate = date(pickedDate);
                  context
                      .read<CollectionBloc>()
                      .add(CollectionPaymentDateChanged(value: formattedDate));
                }
              },
              errorText: state.date.hasError ? state.date.errorMessage : null,
              keyBoardType: TextInputType.none));
}
