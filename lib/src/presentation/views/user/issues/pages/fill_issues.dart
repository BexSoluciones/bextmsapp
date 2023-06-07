import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//blocs
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/strings.dart';
import '../../../../blocs/processing_queue/processing_queue_bloc.dart';
import '../../../../blocs/issues/issues_bloc.dart';

//domain
import '../../../../../domain/news.dart';

//services
import '../../../../../locator.dart';
import '../../../../../services/navigation.dart';
import '../../../../../services/location.dart';
import '../../../../../services/storage.dart';
import '../../../../../services/isolate.dart';

//widgets
import '../../../../widgets/default_button_widget.dart';

final NavigationService _navigationService = locator<NavigationService>();
final ProcessingQueueBloc _processingQueueBloc = locator<ProcessingQueueBloc>();
final LocationService _locationService = locator<LocationService>();
final IsolateService _isolateService = locator<IsolateService>();
final LocalStorageService _storageService = locator<LocalStorageService>();

class FillIssueScreen extends StatefulWidget {
  const FillIssueScreen({super.key});

  @override
  State<FillIssueScreen> createState() => _FillIssueScreenState();
}

class _FillIssueScreenState extends State<FillIssueScreen> {
  final TextEditingController observationsController = TextEditingController();

  late IssuesBloc issuesBloc;
  @override
  void initState() {
    issuesBloc = BlocProvider.of<IssuesBloc>(context);
    issuesBloc.add(ChangeObservations(observations: observationsController));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<IssuesBloc, IssuesState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.selectedIssue!.codmotvis.toString()} - ${state.selectedIssue!.nommotvis.toString()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: DefaultButton(
                            color:
                                state.images != null && state.images.length != 0
                                    ? Colors.green
                                    : theme.primaryColor,
                            widget:
                                state.images != null && state.images.length != 0
                                    ? const Row(
                                        children: [
                                          Text('Foto Cargada Exitosamente'),
                                          Icon(Icons.camera_alt,
                                              color: Colors.white),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                            Text('La foto es requerida',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white)),
                                            Icon(Icons.camera_alt,
                                                color: Colors.white)
                                          ]),
                            press: () async {
                              await Navigator.of(context).pushNamed(cameraRoute,
                                  arguments: (state.status == 'work')
                                      ? state.workId.toString() +
                                          state.codmotvis!
                                      : (state.status == 'summary')
                                          ? state.selectedSummaryId.toString() +
                                              state.codmotvis!
                                          : _storageService
                                                  .getInt('user_id')!
                                                  .toString() +
                                              state.codmotvis!);
                            }),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(15),
                          child: DefaultButton(
                              color:
                                  state.firm != null && state.firm.length != 0
                                      ? Colors.green
                                      : theme.primaryColor,
                              widget: /* true */
                                  state.firm != null && state.firm.length != 0
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text('Firma Adjuntada !!'),
                                            Icon(Icons.edit,
                                                color: Colors.white),
                                          ],
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                              Text('La firma es requerida',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white)),
                                              Icon(Icons.edit,
                                                  color: Colors.white)
                                            ]),
                              press: () async {
                                await _navigationService.goTo(
                                  firmRoute,
                                  arguments: (state.status == 'work')
                                      ? state.workId.toString() +
                                          state.codmotvis!
                                      : (state.status == 'summary')
                                          ? state.selectedSummaryId.toString() +
                                              state.codmotvis!
                                          : _storageService
                                                  .getInt('user_id')!
                                                  .toString() +
                                              state.codmotvis!,
                                );
                              })),
                      Padding(
                          padding: const EdgeInsets.all(15),
                          child: TextField(
                            maxLines: 4,
                            controller: observationsController,
                            decoration: InputDecoration(
                              hintText: state.selectedIssue!.observation == 1
                                  ? 'La observación es requerida'
                                  : '',
                              labelText: 'Observación',
                              fillColor: Colors.black,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.black, width: 1.0),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: kPrimaryColor, width: 1.0),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                          )),
                    ],
                  ),
                  DefaultButton(
                      widget: Text('Enviar'.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal)),
                      press: () async {
                        if (await validateParameters(issuesBloc: issuesBloc)) {
                          // var location = await _locationService.getLocation()
                          //
                          // var firmApplication = await helperFunctions.getFirm(
                          //     'firm-${(issuesBloc.state.status == 'work') ? issuesBloc.state.workId.toString() + issuesBloc.state.codmotvis! : (issuesBloc.state.status == 'summary') ? issuesBloc.state.selectedSummaryId.toString() + issuesBloc.state.codmotvis! : _storageService.getInt('user_id')!.toString() + issuesBloc.state.codmotvis!}');
                          //
                          // var images = await helperFunctions.getImages(
                          //     '${(issuesBloc.state.status == 'work') ? issuesBloc.state.workId.toString() + issuesBloc.state.codmotvis! : (issuesBloc.state.status == 'summary') ? issuesBloc.state.selectedSummaryId.toString() + issuesBloc.state.codmotvis! : _storageService.getInt('user_id')!.toString() + issuesBloc.state.codmotvis!}');
                          //
                          // var imagesPath = <String>[];
                          // var firmApplicationPath = <String>[];
                          //
                          // if (firmApplication != null) {
                          //   firmApplicationPath.add(firmApplication.path);
                          // }
                          //
                          // if (images.isNotEmpty) {
                          //   images.forEach((element) {
                          //     List<int> imageBytes = element.readAsBytesSync();
                          //     var base64Image = base64Encode(imageBytes);
                          //     imagesPath.add(base64Image);
                          //   });
                          // }
                          //
                          // var news = News(
                          //     status: state.status!,
                          //     userId: _storageService.getInt('user_id')!,
                          //     workId: (state.status == 'summary' ||
                          //         state.status == 'general')
                          //         ? null
                          //         : state.workId,
                          //     summaryId: (state.status == 'work' ||
                          //         state.status == 'general')
                          //         ? null
                          //         : state.selectedSummaryId,
                          //     nommotvis: state.nommotvis!,
                          //     codmotvis: state.codmotvis!,
                          //     latitude: location.latitude!.toString(),
                          //     longitude: location.longitude!.toString(),
                          //     images: imagesPath,
                          //     firm: firmApplicationPath,
                          //     observation: state.observations!.text);
                          //
                          // _processingQueueBloc.inAddPq
                          //     .add(helperFunctions.addNews(news: news));
                          //
                          // if (news.firm != null) {
                          //   news.firm = jsonEncode(firmApplicationPath);
                          // }
                          // if (news.images != null) {
                          //   news.images = jsonEncode(imagesPath);
                          // }
                          //
                          // await database.insertNews(news: news);
                          //
                          // if (state.selectedIssue?.tipocliente != null &&
                          //     state.selectedIssue?.tipocliente.toLowerCase() ==
                          //         'unlock' &&
                          //     state.selectedIssue!.codmotvis == '01') {
                          //   _storageService.setBool(
                          //       '${state.selectedSummaryId}-distance_ignore',
                          //       true);
                          // }
                          //
                          // Navigator.pop(context);
                          // Navigator.pop(context);
                          //
                          // await showDialog(
                          //     context: context,
                          //     builder: (context) => CustomConfirmDialog(
                          //       title: 'Novedad Creada',
                          //       message: 'Novedad reportada con exito !!',
                          //       onConfirm: () => Navigator.pop(context),
                          //       buttonText: 'Aceptar',
                          //       cancelButtom: false,
                          //     ));
                        } else {
                          print('all is not ok :C');
                        }
                      })
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> validateParameters({required IssuesBloc issuesBloc}) async {
    if (issuesBloc.state.selectedIssue!.firm == 1) {
      // var firmApplication = await helperFunctions.getFirm(
      //     'firm-${(issuesBloc.state.status == 'work') ? issuesBloc.state.workId.toString() + issuesBloc.state.codmotvis! : (issuesBloc.state.status == 'summary') ? issuesBloc.state.selectedSummaryId.toString() + issuesBloc.state.codmotvis! : _storageService.getInt('user_id')!.toString() + issuesBloc.state.codmotvis!}');
      // if (firmApplication != null) {
      //   print('firm Ok');
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       backgroundColor: Colors.red,
      //       content: Text('Debe ingresar la firma en las evidencias.',
      //           style: TextStyle(color: Colors.white))));
      //   return false;
      // }
    }

    if (issuesBloc.state.selectedIssue!.observation == 1) {
      // if (issuesBloc.state.observations!.text.isNotEmpty) {
      //   print('observations ok');
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       backgroundColor: Colors.red,
      //       content: Text('Debe ingresar Observaciones en las evidencias.',
      //           style: TextStyle(color: Colors.white))));
      //   return false;
      // }
    }
    if (issuesBloc.state.selectedIssue!.photo == 1) {
      // var images = await helperFunctions.getImages(
      //     (issuesBloc.state.status == 'work') ? issuesBloc.state.workId.toString() + issuesBloc.state.codmotvis! : (issuesBloc.state.status == 'summary') ? issuesBloc.state.selectedSummaryId.toString() + issuesBloc.state.codmotvis! : _storageService.getInt('user_id')!.toString() + issuesBloc.state.codmotvis!);
      // if (images.isNotEmpty) {
      //   print('photos Ok');
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //       backgroundColor: Colors.red,
      //       content: Text('Debe ingresar fotos en las evidencias.',
      //           style: TextStyle(color: Colors.white))));
      //   return false;
      // }
    }

    return true;
  }
}
