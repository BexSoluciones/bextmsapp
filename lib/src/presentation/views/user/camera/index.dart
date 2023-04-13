import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:badges/badges.dart' as B;

//services
import '../../../../locator.dart';
import '../../../../services/navigation.dart';

import '../../../../../main.dart';

final NavigationService _navigationService = locator<NavigationService>();

class CameraView extends StatefulWidget {
  @override
  const CameraView({Key? key, required this.orderNumber}) : super(key: key);

  @override
  CameraViewState createState() => CameraViewState();

  final String orderNumber;
}

class CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? controller;

  File? _imageFile;


  // Initial values
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  bool _hideButtonCamera = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];

  final resolutionPresets = ResolutionPreset.values.where((element) => element.toString()
      .split('.')[1]
      .toUpperCase() == 'HIGH');

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  Future<void> refreshAlreadyCapturedImages() async {
    final directory = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/${widget.orderNumber}/');

    if (await directory.exists()) {
      var fileList = await directory.list().toList();
      allFileList.clear();
      var fileNames = <Map<int, dynamic>>[];

      for (var file in fileList) {
        if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
          allFileList.add(File(file.path));

          var name = file.path.split('/').last.split('.').first;
          fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
        }
      }

      if (fileNames.isNotEmpty) {
        final recentFile =
        fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
        String recentFileName = recentFile[1];
        if (recentFileName.contains('.jpg')) {
          _imageFile = File('${directory.path}/$recentFileName');
        }

        setState(() {});
      }
    } else {
      await directory.create();
    }
  }

  Future<XFile?> takePicture() async {

    setState(() {
      _hideButtonCamera = true;
    });
    final cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      print('taking photo');
      return null;
    }

    try {
      var file = await cameraController.takePicture();
      setState(() {
        _hideButtonCamera = false;
      });
      return file;
    } on CameraException catch (e) {
      print('Error occurred while taking picture: $e');
      return null;
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    initialize();

    super.initState();
  }
  
  Future<void> initialize() async {
    var cameras = await availableCameras();
    onNewCameraSelected(cameras[0]);
    refreshAlreadyCapturedImages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => _navigationService.goBack(),
          ),
        ),
        backgroundColor: Colors.black,
        body: _isCameraInitialized
            ? Column(
          children: [
            AspectRatio(
              aspectRatio: 1.1 / controller!.value.aspectRatio,
              child: Stack(
                children: [
                  controller!.buildPreview(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16.0,
                      8.0,
                      16.0,
                      8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: DropdownButton<ResolutionPreset>(
                                dropdownColor: Colors.black87,
                                underline: Container(),
                                value: currentResolutionPreset,
                                items: [
                                  for (ResolutionPreset preset
                                  in resolutionPresets)
                                    DropdownMenuItem(
                                      value: preset,
                                      child: Text(
                                        preset
                                            .toString()
                                            .split('.')[1]
                                            .toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white),
                                      ),
                                    )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    currentResolutionPreset = value!;
                                    _isCameraInitialized = false;
                                  });
                                  onNewCameraSelected(
                                      controller!.description);
                                },
                                hint: Text('Select item'),
                              ),
                            ),
                          ),
                        ),
                        // Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0, top: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _currentExposureOffset
                                    .toStringAsFixed(1) +
                                    'x',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                              height: 30,
                              child: Slider(
                                value: _currentExposureOffset,
                                min: _minAvailableExposureOffset,
                                max: _maxAvailableExposureOffset,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentExposureOffset = value;
                                  });
                                  await controller!
                                      .setExposureOffset(value);
                                },
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _currentZoomLevel,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoomLevel = value;
                                  });
                                  await controller!.setZoomLevel(value);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius:
                                  BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _currentZoomLevel.toStringAsFixed(1) +
                                        'x',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCameraInitialized = false;
                                });
                                onNewCameraSelected(cameras[
                                _isRearCameraSelected ? 1 : 0]);
                                setState(() {
                                  _isRearCameraSelected =
                                  !_isRearCameraSelected;
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.black38,
                                    size: 60,
                                  ),
                                  Icon(
                                    _isRearCameraSelected
                                        ? Icons.camera_front
                                        : Icons.camera_rear,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                            _hideButtonCamera ? Container() : InkWell(
                              onTap: () async {

                                var numImages = 0;

                                if(numImages <= 1){
                                  var rawImage = await takePicture();
                                  var imageFile = File(rawImage!.path);

                                  var currentUnix =
                                      DateTime.now().millisecondsSinceEpoch;

                                  final directory =
                                  await getApplicationDocumentsDirectory();

                                  var fileFormat =
                                      imageFile.path.split('.').last;

                                  await imageFile.copy(
                                    '${directory.path}/${widget.orderNumber}/$currentUnix.$fileFormat',
                                  );

                                  await refreshAlreadyCapturedImages();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(backgroundColor: Colors.red, content: Text('Solo se permite dos fotos maximo', style: TextStyle(color: Colors.white)))
                                  );
                                }


                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white38,
                                    size: 80,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 65,
                                  ),
                                  Icon(
                                    Icons.stop_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                            // InkWell(
                            //   onTap: _imageFile != null
                            //       ? () {
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (context) => CapturesScreen(
                            //           imageFileList: allFileList,
                            //         ),
                            //       ),
                            //     );
                            //   }
                            //       : null,
                            //   child: B.Badge(
                            //     position: B.BadgePosition.topEnd(
                            //         top: -5, end: -5),
                            //     badgeContent: StreamBuilder<int>(
                            //         key: Key('${Random().nextDouble()}'),
                            //         stream: helperFunctions.countImages(widget.orderNumber),
                            //         builder: (BuildContext context,
                            //             AsyncSnapshot snapshot) {
                            //           return Text(
                            //               snapshot.hasData
                            //                   ? snapshot.data.toString()
                            //                   : '0',
                            //               style: const TextStyle(color: Colors.white));
                            //         }),
                            //     child: Container(
                            //       width: 60,
                            //       height: 60,
                            //       decoration: BoxDecoration(
                            //         color: Colors.black,
                            //         borderRadius:
                            //         BorderRadius.circular(10.0),
                            //         border: Border.all(
                            //           color: Colors.white,
                            //           width: 2,
                            //         ),
                            //         image: _imageFile != null
                            //             ? DecorationImage(
                            //           image: FileImage(_imageFile!),
                            //           fit: BoxFit.cover,
                            //         )
                            //             : null,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: const [],
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.off;
                              });
                              await controller!.setFlashMode(
                                FlashMode.off,
                              );
                            },
                            child: Icon(
                              Icons.flash_off,
                              color: _currentFlashMode == FlashMode.off
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.auto;
                              });
                              await controller!.setFlashMode(
                                FlashMode.auto,
                              );
                            },
                            child: Icon(
                              Icons.flash_auto,
                              color: _currentFlashMode == FlashMode.auto
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.always;
                              });
                              await controller!.setFlashMode(
                                FlashMode.always,
                              );
                            },
                            child: Icon(
                              Icons.flash_on,
                              color: _currentFlashMode == FlashMode.always
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                _currentFlashMode = FlashMode.torch;
                              });
                              await controller!.setFlashMode(
                                FlashMode.torch,
                              );
                            },
                            child: Icon(
                              Icons.highlight,
                              color: _currentFlashMode == FlashMode.torch
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        )
            : Center(
          child: Text(
            'LOADING',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
