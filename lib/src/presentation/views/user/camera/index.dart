import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//bloc
import '../../../blocs/camera/camera_bloc.dart';

//utils
import '../../../../utils/constants/keys.dart';

//widgets
import '../../../blocs/photo/photo_bloc.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: Text("foto tomada exitosamente"),
          ));
          BlocProvider.of<CameraBloc>(context).add(CameraInitialized());
          //Navigator.of(context).pop(state.path);
          BlocProvider.of<PhotosBloc>(context).add(PhotosLoaded());
        } else if (state is CameraCaptureFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 1),
            key: MyPhotosKeys.errorSnackBar,
            content: Text(state.error),
          ));
        }
      },
      builder: (_, state) => Scaffold(
            key: globalKey,
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text("Camera"),
            ),
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
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                         const SizedBox(width: 10),
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          heroTag: 'takePhotoBtn',
                          child: const Icon(Icons.camera_alt),
                          onPressed: () => BlocProvider.of<CameraBloc>(context)
                              .add(CameraCaptured()),
                        ),
                      const SizedBox(width: 30),
                      FloatingActionButton(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                        heroTag: 'GalleryPhotoBtn',
                        child: const Icon(Icons.photo),
                        onPressed: () => BlocProvider.of<CameraBloc>(context)
                            .add(CameraGallery()),
                      ),
                        const SizedBox(width: 30),
                        FloatingActionButton(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                          heroTag: 'showPhotoBtn',
                          onPressed: () => BlocProvider.of<CameraBloc>(context)
                              .add(const CameraFolder(path: '')),
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
