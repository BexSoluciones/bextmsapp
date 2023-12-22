import 'package:flutter_bloc/flutter_bloc.dart';
//blocs
import '../../../presentation/blocs/camera/camera_bloc.dart';
//domain
import '../../../domain/models/photo.dart';
import '../../../domain/repositories/database_repository.dart';
//utils
import '../../../utils/constants/strings.dart';
import '../../../utils/resources/camera.dart';
//services
import '../../../locator.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/camera/index.dart';
import '../../../presentation/views/user/firm/index.dart';
import '../../../presentation/views/user/photos/features/detail.dart';
import '../../../presentation/views/user/photos/index.dart';
import '../../../presentation/views/user/qr/index.dart';

Map<String, RouteType> coreRoutes = {
  AppRoutes.firm: (context, settings) =>
      FirmView(orderNumber: settings.arguments as String),
  AppRoutes.camera: (context, settings) => BlocProvider(
        create: (_) => CameraBloc(
            cameraUtils: CameraUtils(),
            databaseRepository: locator<DatabaseRepository>())
          ..add(CameraInitialized()),
        child: const CameraView(),
      ),
  AppRoutes.photo: (context, settings) => const PhotoView(),
  AppRoutes.detailPhoto: (context, settings) =>
      DetailPhotoView(photo: settings.arguments as Photo),
  AppRoutes.codeQr: (context, settings) =>
      QrView(codeQr: settings.arguments as String?),
};
