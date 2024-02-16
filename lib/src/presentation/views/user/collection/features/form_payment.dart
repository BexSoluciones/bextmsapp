import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';
//blocs
import '../../../../blocs/collection/collection_bloc.dart';
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

class PaymentDateInputField extends StatelessWidget {
  const PaymentDateInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) => current.date != previous.date,
          builder: (context, state) => textField(
                initialValue: state.date.value,
                context: context,
                onChanged: (date) => context
                    .read<CollectionBloc>()
                    .add(CollectionPaymentDateChanged(value: date)),
                onTap: () async {
                      var pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101));

                      if (pickedDate != null && context.mounted) {
                        var formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                        context.read<CollectionBloc>().add(CollectionPaymentDateChanged(value: formattedDate));
                      }
                },
                errorText: state.date.hasError ? state.date.errorMessage : null,
                keyBoardType: TextInputType.none
              ));
}
