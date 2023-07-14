import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//bloc
import '../../../blocs/camera/camera_bloc.dart';

//utils
import '../../../../utils/constants/keys.dart';

//widgets
import '../../../widgets/error.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  CameraViewState createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: close_sinks
    final bloc = BlocProvider.of<CameraBloc>(context);

    // App state changed before we got the chance to initialize.
    if (!bloc.isInitialized()) return;

    if (state == AppLifecycleState.inactive) {
      bloc.add(CameraStopped());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(CameraInitialized());
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CameraBloc, CameraState>(
      listener: (_, state) {
        if (state is CameraCaptureSuccess) {

          // Navigator.of(context).pop(state.path);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("foto tomada exitosamente"),
          ));
          BlocProvider.of<CameraBloc>(context)
              .add(CameraInitialized());
        } else if (state is CameraCaptureFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            key: MyPhotosKeys.errorSnackBar,
            content: Text(state.error),
          ));
        }
      },
      builder: (_, state) => Scaffold(
            key: globalKey,
            backgroundColor: Colors.black,
            appBar: AppBar(title: const Text("Camera")),
            body: state is CameraReady
                ? Container(
                    key: MyPhotosKeys.cameraPreviewScreen,
                    child: CameraPreview(
                        BlocProvider.of<CameraBloc>(context).getController()))
                : state is CameraFailure
                    ? Error(key: MyPhotosKeys.errorScreen, message: state.error)
                    : Container(
                        key: MyPhotosKeys.emptyContainerScreen,
                      ),
            floatingActionButton: state is CameraReady
                ? Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      heroTag: 'changeCameraBtn',
                      child: Icon(state is CameraChangeLen
                          ? Icons.camera_front
                          : Icons.camera_rear),
                      onPressed: () => BlocProvider.of<CameraBloc>(context)
                          .add(CameraChange(state is CameraChangeLen ? "front" : "back")),
                    ),
                    const SizedBox(width: 70),
                    FloatingActionButton(
                      heroTag: 'takePhotoBtn',
                      child: const Icon(Icons.camera_alt),
                      onPressed: () => BlocProvider.of<CameraBloc>(context)
                          .add(CameraCaptured()),
                    ),
                    const SizedBox(width: 60),
                    FloatingActionButton(
                      heroTag: 'showPhotoBtn',
                      onPressed: () => BlocProvider.of<CameraBloc>(context)
                          .add(const CameraFolder(path: "12345")),
                      child: const Icon(Icons.folder),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ])
                : Container(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ));
}
