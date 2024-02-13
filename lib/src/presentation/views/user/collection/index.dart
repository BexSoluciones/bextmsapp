import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../../utils/constants/strings.dart';
import '../../../blocs/collection/collection_bloc.dart';
import '../../../blocs/account/account_bloc.dart';

//utils
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/nums.dart';

//domain
import '../../../../domain/models/arguments.dart';
import '../../../../domain/abstracts/format_abstract.dart';

//widgets
import '../../../widgets/default_button_widget.dart';
//features
import './features/form.dart';
import './features/header.dart';

class CollectionView extends StatefulWidget {
  const CollectionView({super.key, required this.arguments});

  final InventoryArgument arguments;

  @override
  State<CollectionView> createState() => CollectionViewState();
}

class CollectionViewState extends State<CollectionView> with FormatNumber {
  final _formKey = GlobalKey<FormState>();

  late CollectionBloc collectionBloc;
  late FocusScopeNode currentFocus;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    context.read<AccountBloc>().add(LoadAccountListEvent());
    collectionBloc = BlocProvider.of<CollectionBloc>(context);

    collectionBloc.add(CollectionLoading(
        workId: widget.arguments.work.id!,
        orderNumber: widget.arguments.summary.orderNumber));
  }

  @override
  void dispose() {
    super.dispose();
  }

  void unFocus() {
    currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => collectionBloc.add(CollectionBack()),
          ),
        ),
        body: GestureDetector(onTap: unFocus, child: buildBlocConsumer(size)));
  }

  Widget buildBlocConsumer(Size size) {
    return BlocConsumer<CollectionBloc, CollectionState>(
      buildWhen: (previous, current) => previous != current,
      listener: buildBlocListener,
      builder: (context, state) {
        print(state.status);
        if (state.status == CollectionStatus.loading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state.status == CollectionStatus.initial ||
            state.status == CollectionStatus.error) {
          return _buildCollection(size, state);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  void buildBlocListener(BuildContext context, CollectionState state) async {
    if (state.status == CollectionStatus.success) {
      // if (state.validate != null && state.validate == true) {
      //   collectionBloc.add(
      //       CollectionNavigate(route: AppRoutes.work, arguments: state.work));
      // } else if (state.validate != null && state.validate == false) {
      //   collectionBloc.add(
      //       CollectionNavigate(route: AppRoutes.summary, arguments: state.work));
      // }
      // } else if (state is CollectionFailed && state.error != null) {
      //   ScaffoldMessenger.of(context).removeCurrentSnackBar();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       duration: const Duration(seconds: 1),
      //       backgroundColor: Colors.red,
      //       content: Text(
      //         state.error!,
      //         style: const TextStyle(color: Colors.white),
      //       ),
      //     ),
      //   );
      // } else if (state is CollectionWaiting) {
      //   await showDialog(
      //       context: context,
      //       builder: (_) {
      //         return MyDialog(
      //           id: widget.arguments.work.id!,
      //           orderNumber: widget.arguments.summary.orderNumber,
      //           total: collectionCubit.total,
      //           totalSummary: state.totalSummary!.toDouble(),
      //           arguments: widget.arguments,
      //           context: context,
      //         );
      //       });
      // }
    } else if (state.status == CollectionStatus.back) {
      collectionBloc.navigationService.goBack();
    }
  }

  Widget _buildCollection(Size size, CollectionState state) {
    return SingleChildScrollView(
        child: SafeArea(
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: Column(children: [
          HeaderCollection(
              type: widget.arguments.summary.typeOfCharge!,
              total: state.totalSummary ?? 0.0),
          SizedBox(height: size.height * 0.02),
          FormCollection(
              formKey: _formKey,
              collectionBloc: collectionBloc,
              state: state,
              orderNumber: widget.arguments.summary.orderNumber),
          Padding(
              padding: const EdgeInsets.only(
                  left: kDefaultPadding, right: kDefaultPadding),
              child: DefaultButton(
                  widget: const Icon(Icons.edit, color: Colors.white),
                  press: () => collectionBloc.add(CollectionNavigate(
                      route: AppRoutes.firm,
                      arguments: widget.arguments.summary.orderNumber)))),
          SizedBox(height: size.height * 0.05),
          BlocSelector<CollectionBloc, CollectionState, bool>(
              selector: (state) =>
                  state.formSubmissionStatus == FormSubmissionStatus.submitting,
              builder: (BuildContext c, x) {
                return x
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(
                            left: kDefaultPadding, right: kDefaultPadding),
                        child: DefaultButton(
                            widget: const Text('Confirmar',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            press: () async {
                              state.isSubmitting() || !state.isValid
                                  ? null
                                  : collectionBloc.add(CollectionButtonPressed(
                                      arguments: widget.arguments));
                            }));
              })
        ]),
      ),
    ));
  }
}

// class MyDialog extends StatefulWidget {
//   const MyDialog(
//       {super.key,
//       required this.id,
//       required this.orderNumber,
//       required this.totalSummary,
//       required this.total,
//       required this.arguments,
//       required this.context});
//
//   final int id;
//   final String orderNumber;
//   final double totalSummary;
//   final double total;
//   final InventoryArgument arguments;
//   final BuildContext context;
//
//   @override
//   MyDialogState createState() => MyDialogState();
// }
//
// class MyDialogState extends State<MyDialog> with FormatNumber {
//   var seconds = 5;
//   var showText = false;
//   Timer? timer;
//
//   @override
//   void setState(VoidCallback fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer.periodic(
//       const Duration(seconds: 1),
//       (Timer timer) {
//         if (seconds == 0) {
//           setState(() {
//             timer.cancel();
//             showText = true;
//           });
//         } else {
//           setState(() {
//             seconds--;
//             showText = false;
//           });
//         }
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Confirmar recaudo'),
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: <Widget>[
//             Text(
//                 'Valor a recaudar: \$${formatter.format(widget.totalSummary)}'),
//             Text('Valor a guardar: por \$${formatter.format(widget.total)}'),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: const Text('Cancelar'),
//           onPressed: () {
//             Navigator.of(context).pop();
//             context
//                 .read<CollectionCubit>()
//                 .getCollection(widget.id, widget.orderNumber);
//           },
//         ),
//         TextButton(
//           child: showText ? const Text('Si') : Text(seconds.toString()),
//           onPressed: () {
//             Navigator.of(context).pop();
//             context
//                 .read<CollectionCubit>()
//                 .confirmTransaction(widget.arguments)
//                 .then((value) {});
//             context
//                 .read<CollectionCubit>()
//                 .getCollection(widget.id, widget.orderNumber);
//           },
//         ),
//       ],
//     );
//   }
// }
