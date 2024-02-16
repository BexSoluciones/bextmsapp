import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//blocs
import '../../../../blocs/collection/collection_bloc.dart';
//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
import '../../../../../utils/constants/strings.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';
//widgets
import '../../../../widgets/default_button_widget.dart';
//features
import 'form_payment.dart';
import 'accounts.dart';

class FormCollection extends StatefulWidget {
  final GlobalKey formKey;
  final String orderNumber;
  final CollectionBloc collectionBloc;
  final CollectionState state;

  const FormCollection(
      {super.key,
      required this.formKey,
      required this.collectionBloc,
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

  void _closeModal(void value) => widget.collectionBloc.add(CollectionCloseModal());
  void _openModal() => widget.collectionBloc.add(CollectionOpenModal());

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
                        BlocSelector<CollectionBloc, CollectionState, bool>(
                            selector: (state) =>
                                state.canRenderView() &&
                                state.enterpriseConfig != null &&
                                state.enterpriseConfig!.multipleAccounts ==
                                    true,
                            builder: (c, x) {
                              return x
                                  ? IconButton(
                                      icon: const Icon(Icons.camera_alt,
                                          size: 32, color: kPrimaryColor),
                                      onPressed: () => widget.collectionBloc
                                          .add(CollectionNavigate(
                                              route: AppRoutes.camera,
                                              arguments: widget.orderNumber)))
                                  : const SizedBox();
                            }),
                      ]),
                    ]),
                PaymentEfectyInputField(),
                const SizedBox(height: 10),
                BlocSelector<CollectionBloc, CollectionState, bool>(
                    bloc: widget.collectionBloc,
                    selector: (state) =>
                        state.canRenderView() &&
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
                                    onPressed: () => widget.collectionBloc.add(
                                        CollectionNavigate(
                                            route: AppRoutes.camera,
                                            arguments: widget.orderNumber))),
                                BlocSelector<CollectionBloc, CollectionState,
                                        bool>(
                                    bloc: widget.collectionBloc,
                                    selector: (state) =>
                                        state.canRenderView() &&
                                        state.enterpriseConfig != null &&
                                        state.enterpriseConfig!.codeQr != null,
                                    builder: (c, x) {
                                      return x
                                          ? IconButton(
                                              icon: const Icon(Icons.qr_code_2,
                                                  size: 32,
                                                  color: kPrimaryColor),
                                              onPressed: () => widget
                                                  .collectionBloc
                                                  .add(CollectionNavigate(
                                                      route: AppRoutes.qr,
                                                      arguments: widget
                                                          .state
                                                          .enterpriseConfig!
                                                          .codeQr)))
                                          : const SizedBox();
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
                BlocSelector<CollectionBloc, CollectionState, bool>(
                    selector: (state) =>
                        state.canRenderView() &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? PaymentTransferInputField()
                          : DefaultButton(
                              widget: const Text('Cuentas Bancarias',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              press: () {
                                _openModal();

                                Future<void> future = showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (c) {
                                      return AccountsCollection(
                                        orderNumber: widget.orderNumber,
                                        collectionBloc: widget.collectionBloc,
                                        state: widget.state,
                                      );
                                    });

                                future.then((void value) => _closeModal(value));
                              });
                    }),
                BlocSelector<CollectionBloc, CollectionState, bool>(
                    selector: (state) =>
                        state.canRenderView() &&
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
                                        // if (widget.collectionCubit
                                        //         .selectedAccount !=
                                        //     null) {
                                        //   widget.collectionCubit.goToCodeQR(
                                        //       widget.collectionCubit
                                        //           .selectedAccount!.codeQr);
                                        // } else {
                                        //   widget.collectionCubit.error();
                                        // }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )
                          : const SizedBox();
                    }),
                BlocSelector<CollectionBloc, CollectionState, bool>(
                    selector: (state) =>
                        state.canRenderView() &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? const PaymentAccountsInputField()
                          : const SizedBox();
                    }),
                const SizedBox(height: 10),
                BlocSelector<CollectionBloc, CollectionState, bool>(
                    selector: (state) =>
                        state.canRenderView() &&
                        state.enterpriseConfig != null &&
                        state.enterpriseConfig!.specifiedAccountTransfer ==
                            true &&
                        state.enterpriseConfig!.multipleAccounts == false,
                    builder: (c, x) {
                      return x
                          ? PaymentDateInputField()
                          : const SizedBox();
                    }),
                const SizedBox(height: 30),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20)),
                      Text('\$${formatter.format(widget.state.total)}',
                          style: const TextStyle(fontSize: 20)),
                    ]),
              ],
            )));
  }
}
