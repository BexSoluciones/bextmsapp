import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../blocs/history_order/history_order_bloc.dart';

//models
import '../../../../config/size.dart';
import '../../../../domain/models/work.dart';
import '../../../../domain/models/arguments.dart';

//utils
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/strings.dart';

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';
import '../../../../services/storage.dart';
//widgets
import '../../../widgets/default_button_widget.dart';
import '../../../widgets/different_item.dart';



class HistoryView extends StatefulWidget {
  const HistoryView({
    super.key,
    required this.arguments,
  });

  final HistoryArgument arguments;


  @override
  State<HistoryView> createState() => _HistoryViewState();
}



class _HistoryViewState extends State<HistoryView> {
  late HistoryOrderBloc historicWorkBloc;
  bool isLoadingModal = false;
  bool isLoading = false;
  List<Work> newWorks = [];

  final LocalStorageService storageService = locator<LocalStorageService>();
  final NavigationService navigationService = locator<NavigationService>();

  @override
  void initState() {
    historicWorkBloc = BlocProvider.of<HistoryOrderBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: getFullScreenWidth(),
              height: getFullScreenHeight(),
              padding: const EdgeInsets.all(20),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Lottie.asset(
                          //     'assets/animations/13357-route-finder.json',
                          //     height: 180,
                          //     width: 180),
                          Text(
                              '¿Deseas usar este histórico con probabilidad de ${widget.arguments.likelihood.toStringAsFixed(2)}%?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(20),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: getProportionateScreenHeight(10)),
                          Text('La nueva ruta se calculará en segundo plano.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(16),
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400)),
                          (widget.arguments.differents.isNotEmpty)
                              ? Expanded(
                                  flex: 1,
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          widget.arguments.differents.length,
                                      itemBuilder: (context, index) {
                                        return DifferentItem(
                                            differentItem: widget
                                                .arguments.differents[index],
                                            index: index);
                                      }))
                              : Container(),
                          SizedBox(height: getProportionateScreenHeight(10)),
                          BlocConsumer<HistoryOrderBloc, HistoryOrderState>(
                            listener: (context, state) {
                              if (state is HistoryOrderShow) {
                                newWorks = state.historyOrder!.works;
                              }
                            },
                            builder: (context, state) {
                              return Column(
                                children: [
                                  (state is HistoryOrderShow)
                                      ? DefaultButton(
                                          widget: isLoadingModal
                                              ? const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                )
                                              : Text('Usar',
                                                  style: TextStyle(
                                                      fontSize:
                                                          getProportionateScreenHeight(
                                                              20),
                                                      color: Colors.white)),
                                          press: () async {
                                            storageService.setBool(
                                                '${widget.arguments.work.workcode}-usedHistoric',
                                                true);
                                            storageService.setBool(
                                                '${widget.arguments.work.workcode}-showAgain',
                                                true);
                                            storageService.setInt(
                                                'history-id-${widget.arguments.work.workcode}',
                                                state.historyOrder!.id);
                                            historicWorkBloc
                                                .add(ChangeCurrentWork(
                                              work: widget.arguments.work,

                                              //newWorks: newWorks
                                            ));
                                          })
                                      : const CircularProgressIndicator(),
                                  SizedBox(
                                      height: getProportionateScreenHeight(10)),
                                  DefaultButton(
                                      color: Colors.grey,
                                      widget: Text('Recuerdamelo más tarde',
                                          style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      20),
                                              color: Colors.white)),
                                      press: () {
                                        storageService.setBool(
                                            '${widget.arguments.work.workcode}-showAgain',
                                            false);
                                        navigationService.goTo(AppRoutes.work,
                                            arguments: WorkArgument(
                                                work: widget.arguments.work));
                                      }),
                                  SizedBox(
                                      height: getProportionateScreenHeight(10)),
                                  DefaultButton(
                                      color: Colors.grey,
                                      widget: Text('No volver a mostrar',
                                          style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      20),
                                              color: Colors.white)),
                                      press: () {
                                        storageService.setBool(
                                            '${widget.arguments.work.workcode}-showAgain',
                                            true);
                                        navigationService.goTo(AppRoutes.work,
                                            arguments: WorkArgument(
                                                work: widget.arguments.work));
                                      })
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
