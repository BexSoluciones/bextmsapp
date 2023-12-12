import 'package:flutter/material.dart';
//cubits
import '../../../../cubits/collection/collection_cubit.dart';
//utils
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/nums.dart';
//domain
import '../../../../../domain/abstracts/format_abstract.dart';

class FormCollection extends StatelessWidget with FormatNumber {
  final GlobalKey formKey;
  final String orderNumber;
  final CollectionCubit collectionCubit;
  final CollectionState state;

  FormCollection(
      {super.key,
      required this.formKey,
      required this.collectionCubit,
      required this.state,
      required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: kDefaultPadding, right: kDefaultPadding),
        child: Form(
            key: formKey,
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
                  controller: collectionCubit.cashController,
                  // onChanged: data.isNotEmpty
                  //     ? (newValue) {
                  //         if (newValue.isEmpty) {
                  //           setState(() {
                  //             data.clear();
                  //             paymentTransferArrayController.clear();
                  //             paymentCashController.clear();
                  //           });
                  //         }
                  //       }
                  //     : null,
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
                                collectionCubit.transferController.text) !=
                            null) {
                          state.total = state.total! -
                              double.parse(collectionCubit.cashController.text);
                        }
                        // data.clear();
                        // paymentTransferArrayController.clear();
                        // paymentCashController.clear();
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
                        onPressed: () =>
                            collectionCubit.goToCamera(orderNumber)),

                    // state.enterpriseConfig != null &&
                    //         state.enterpriseConfig!.codeQr != null
                    //     ? IconButton(
                    //         icon: const Icon(Icons.qr_code_2,
                    //             size: 32, color: kPrimaryColor),
                    //         onPressed: () => collectionCubit.goToCodeQR())
                    //     : Container()
                  ],
                ),
                // TextFormField(
                //   keyboardType: TextInputType.number,
                //   autofocus: false,
                //   controller: data.isEmpty
                //       ? paymentTransferController
                //       : paymentTransferArrayController,
                //   decoration: InputDecoration(
                //     prefixText: _currency,
                //     focusedBorder: const OutlineInputBorder(
                //       borderSide: BorderSide(color: Colors.grey, width: 2.0),
                //     ),
                //     enabledBorder: const OutlineInputBorder(
                //       borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                //     ),
                //     errorBorder: const OutlineInputBorder(
                //       borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
                //     ),
                //     suffixIcon: IconButton(
                //       onPressed: () {
                //         if (data.isEmpty) {
                //           if (double.tryParse(paymentTransferController.text) !=
                //               null) {
                //             setState(() {
                //               total -=
                //                   double.parse(paymentTransferController.text);
                //             });
                //           }
                //         }
                //         paymentTransferController.clear();
                //       },
                //       icon: const Icon(Icons.clear),
                //     ),
                //   ),
                //   validator: (value) {
                //     if (value!.contains(',')) {
                //       return '';
                //     }
                //     return null;
                //   },
                // ),
                // state.enterpriseConfig != null &&
                //         state.enterpriseConfig!.specifiedAccountTransfer == true
                //     ? Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Row(children: [
                //             Text('NÚMERO DE CUENTA',
                //                 style: TextStyle(fontSize: 14)),
                //             Icon(Icons.account_balance_outlined)
                //           ]),
                //           Row(
                //             children: [
                //               IconButton(
                //                 onPressed: () {
                //                   setState(() {
                //                     if (data.isNotEmpty) {
                //                       paymentTransferController.text = '';
                //                     }
                //
                //                     if (paymentTransferController
                //                         .text.isNotEmpty) {
                //                       if (double.tryParse(
                //                               paymentTransferController.text) !=
                //                           null) {
                //                         paymentTransferValue = double.parse(
                //                             paymentTransferController.text);
                //                         var parsedNumberString = '';
                //                         if (selectedOption != null) {
                //                           var parts =
                //                               selectedOption!.split(' - ');
                //                           if (parts.length >= 3) {
                //                             parsedNumberString = parts[2]
                //                                 .replaceAll(
                //                                     RegExp(r'[^\d]+'), '');
                //                           }
                //                         }
                //                         if (paymentCashController
                //                             .text.isNotEmpty) {
                //                           paymentCashValue = double.parse(
                //                               paymentCashController.text);
                //                         } else {
                //                           paymentCashValue = 0;
                //                         }
                //                         var parsedNumber =
                //                             parsedNumberString.isNotEmpty
                //                                 ? int.parse(parsedNumberString)
                //                                 : null;
                //                         var count = 0.0;
                //                         data.add([
                //                           paymentTransferValue,
                //                           parsedNumber,
                //                           selectedOption
                //                         ]);
                //
                //                         for (var i = 0; i < data.length; i++) {
                //                           count += double.parse(
                //                               data[i][0].toString());
                //                         }
                //                         total = count + paymentCashValue;
                //                       }
                //                     } else {
                //                       if (double.tryParse(
                //                               paymentTransferArrayController
                //                                   .text) !=
                //                           null) {
                //                         paymentTransferValue = double.parse(
                //                             paymentTransferArrayController
                //                                 .text);
                //                         var parsedNumberString = '';
                //                         if (selectedOption != null) {
                //                           var parts =
                //                               selectedOption!.split(' - ');
                //                           if (parts.length >= 3) {
                //                             parsedNumberString = parts[2]
                //                                 .replaceAll(
                //                                     RegExp(r'[^\d]+'), '');
                //                           }
                //                         }
                //                         if (paymentCashController
                //                             .text.isNotEmpty) {
                //                           paymentCashValue = double.parse(
                //                               paymentCashController.text);
                //                         } else {
                //                           paymentCashValue = 0;
                //                         }
                //                         var parsedNumber =
                //                             parsedNumberString.isNotEmpty
                //                                 ? int.parse(parsedNumberString)
                //                                 : null;
                //                         var count = 0.0;
                //                         data.add([
                //                           paymentTransferValue,
                //                           parsedNumber,
                //                           selectedOption
                //                         ]);
                //
                //                         for (var i = 0; i < data.length; i++) {
                //                           count += double.parse(
                //                               data[i][0].toString());
                //                         }
                //                         total = count + paymentCashValue;
                //                       }
                //                     }
                //                     for (var element
                //                         in widget.arguments.summaries!) {
                //                       totalSummary = element.grandTotalCopy!;
                //                     }
                //                     if (total != totalSummary) {
                //                       message =
                //                           'el recaudo debe ser igual al total';
                //                       ScaffoldMessenger.of(context)
                //                           .hideCurrentSnackBar();
                //                       ScaffoldMessenger.of(context)
                //                           .showSnackBar(
                //                         SnackBar(
                //                           backgroundColor: Colors.red,
                //                           content: Text(
                //                             message,
                //                             style: const TextStyle(
                //                                 color: Colors.white),
                //                           ),
                //                         ),
                //                       );
                //                     }
                //                   });
                //                 },
                //                 icon: const Icon(Icons.add),
                //               ),
                //               IconButton(
                //                 icon: const Icon(Icons.qr_code_2),
                //                 onPressed: () {
                //                   _navigationService.goTo(AppRoutes.codeQr,
                //                       arguments:
                //                           _storageService.getString('code_qr'));
                //                 },
                //               ),
                //             ],
                //           )
                //         ],
                //       )
                //     : Container(),
                // state.enterpriseConfig != null &&
                //         state.enterpriseConfig!.specifiedAccountTransfer == true
                //     ? BlocBuilder<AccountBloc, AccountState>(
                //         builder: (context, state) {
                //           if (state is AccountLoadingState) {
                //             return const CircularProgressIndicator();
                //           } else if (state is AccountLoadedState) {
                //             final formattedAccountLists =
                //                 state.formattedAccountList;
                //             return DropdownButtonFormField<String>(
                //               isExpanded: true,
                //               value: state.formattedAccountList.first,
                //               onChanged: (String? newValue) {
                //                 setState(() {
                //                   selectedOption = newValue;
                //                   showDropdownError = false;
                //                 });
                //               },
                //               decoration: const InputDecoration(
                //                 contentPadding: EdgeInsets.symmetric(
                //                     horizontal: 16, vertical: 12),
                //                 focusedBorder: OutlineInputBorder(
                //                   borderSide: BorderSide(
                //                       color: Colors.grey, width: 2.0),
                //                 ),
                //                 enabledBorder: OutlineInputBorder(
                //                   borderSide: BorderSide(
                //                       color: kPrimaryColor, width: 2.0),
                //                 ),
                //                 errorBorder: OutlineInputBorder(
                //                   borderSide: BorderSide(
                //                       color: kPrimaryColor, width: 2.0),
                //                 ),
                //                 hintStyle: TextStyle(
                //                   color: Colors.orange,
                //                 ),
                //               ),
                //               style: const TextStyle(
                //                 color: kPrimaryColor,
                //               ),
                //               dropdownColor: Colors.white,
                //               validator: (value) {
                //                 if (showDropdownError &&
                //                     (value == null ||
                //                         value.isEmpty ||
                //                         value == options[0])) {
                //                   return 'Selecciona una opción válida';
                //                 }
                //                 return null;
                //               },
                //               items: formattedAccountLists
                //                   .map<DropdownMenuItem<String>>(
                //                       (String value) {
                //                 return DropdownMenuItem<String>(
                //                   value: value,
                //                   child: Text(
                //                     value.contains('-')
                //                         ? '${value.split('-')[0]} - ${value.split('-')[1]}'
                //                         : 'Seleccionar cuenta',
                //                     style: const TextStyle(color: Colors.black),
                //                   ),
                //                 );
                //               }).toList(),
                //             );
                //           } else if (state is AccountErrorState) {
                //             return Text('Error: ${state.error}');
                //           } else {
                //             return const Text('No se han cargado datos aún.');
                //           }
                //         },
                //       )
                //     : Container(),
                // state.enterpriseConfig != null &&
                //         state.enterpriseConfig!.specifiedAccountTransfer == true
                //     ? TransactionList(
                //         data: data,
                //         onTotalChange: (amount) {
                //           setState(() {
                //             total += amount;
                //           });
                //         },
                //         onDataRemove: (removedData) {
                //           setState(() {
                //             data.remove(removedData);
                //           });
                //         },
                //       )
                //     : Container(),
                const SizedBox(height: 50),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 20)),
                      Text('\$${formatter.format(state.total)}',
                          style: const TextStyle(fontSize: 20)),
                    ]),
              ],
            )));
  }
}
