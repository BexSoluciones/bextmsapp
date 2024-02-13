import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as B;

//bloc
import '../../../blocs/camera/camera_bloc.dart';
import '../../../blocs/gps/gps_bloc.dart';

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
  late GpsBloc gpsBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    gpsBloc = BlocProvider.of<GpsBloc>(context);
    gpsBloc.add(OnStopFollowingUser());
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
    if (bloc.getController() == null || !bloc.isInitialized()!) return;

    if (state == AppLifecycleState.inactive) {
      bloc.add(CameraStopped());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(CameraInitialized());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CameraBloc, CameraState>(
      listener: (context, state) {
        if (state is CameraCaptureSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: Text("Foto tomada exitosamente"),
          ));
          BlocProvider.of<CameraBloc>(context).add(CameraInitialized());
          BlocProvider.of<PhotosBloc>(context).add(PhotosLoaded());
        } else if (state is CameraCaptureFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: const Duration(seconds: 1),
            content: Text(state.error),
          ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: globalKey,
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text("Camera"),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                gpsBloc.add(OnStartFollowingUser());
                gpsBloc.goBack();
              },
            ),
          ),
          body: _buildCameraPreview(state),
          floatingActionButton: _buildFloatingActionButton(context, state),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }
  Widget _buildCameraPreview(CameraState state) {
    if (state is CameraReady) {
      return Container(
        key: MyPhotosKeys.cameraPreviewScreen,
        child: CameraPreview(
          BlocProvider.of<CameraBloc>(context).getController()!,
        ),
      );
    } else if (state is CameraFailure) {
      return Error(
        key: MyPhotosKeys.errorScreen,
        message: state.error,
      );
    } else {
      return Container(key: MyPhotosKeys.emptyContainerScreen);
    }
  }
  Widget _buildFloatingActionButton(BuildContext context, CameraState state) {
    if (state is CameraReady) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            heroTag: 'takePhotoBtn',
            child: const Icon(Icons.camera_alt),
            onPressed: () => BlocProvider.of<CameraBloc>(context).add(CameraCaptured()),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            heroTag: 'GalleryPhotoBtn',
            child: const Icon(Icons.photo),
            onPressed: () => BlocProvider.of<CameraBloc>(context).add(CameraGallery()),
          ),
          const SizedBox(width: 30),
          FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
            heroTag: 'showPhotoBtn',
            onPressed: () => BlocProvider.of<CameraBloc>(context).add(const CameraFolder(path: '')),
            child: _buildBadge(context),
          ),
          const SizedBox(width: 10),
        ],
      );
    } else {
      return const SizedBox();
    }
  }
  Widget _buildBadge(BuildContext context) {
    return FutureBuilder<int>(
      future: context.read<CameraBloc>().countImagesInCache(),
      builder: (context, snapshot) {
        final badgeContent = Text(
          snapshot.hasData ? snapshot.data.toString() : '0',
          style: const TextStyle(color: Colors.white),
        );

        return B.Badge(
          position: B.BadgePosition.topEnd(top: -5, end: -5),
          badgeContent: badgeContent,
          child: const SizedBox(width: 60, height: 60, child: Icon(Icons.folder)),
        );
      },
    );
  }
}
