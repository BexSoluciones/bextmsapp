import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//blocs
import '../../../../blocs/collection/collection_bloc.dart';
//widgets
import '../../../../widgets/text_input_widget.dart';

class PaymentEfectyInputField extends StatelessWidget {
  const PaymentEfectyInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CollectionBloc, CollectionState>(
          buildWhen: (previous, current) => current.efecty != previous.efecty,
          builder: (context, state) => textField(
                context: context,
                hintTxt: 'Efectivo',
                onChanged: (efecty) => context
                    .read<CollectionBloc>()
                    .add(CollectionPaymentEfectyChanged(value: efecty)),
                keyBoardType: TextInputType.number,
                errorText:
                    state.efecty.hasError ? state.efecty.errorMessage : null,
              ));
}

class PaymentTransferInputField extends StatelessWidget {
  const PaymentTransferInputField({super.key});

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
                errorText: state.transfer.hasError
                    ? state.transfer.errorMessage
                    : null,
                hintTxt: 'Transferencia',
              ));
}

class PaymentMultiTransferInputField extends StatelessWidget {
  const PaymentMultiTransferInputField({super.key});

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
                hintTxt: 'Transferencia',
              ));
}
