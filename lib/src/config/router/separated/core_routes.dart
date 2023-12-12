//domain
import '../../../domain/models/photo.dart';
//utils

import '../../../utils/constants/strings.dart';
//router
import '../route_type.dart';
//views
import '../../../presentation/views/user/camera/index.dart';
import '../../../presentation/views/user/collection/features/firm.dart';
import '../../../presentation/views/user/photos/features/detail.dart';
import '../../../presentation/views/user/photos/index.dart';
//TODO:: [Heider Zapa fix code qr view]
import '../../../presentation/views/user/qr/index.dart';

Map<String, RouteType> coreRoutes = {
  AppRoutes.firm: (context, settings) =>
      FirmView(orderNumber: settings.arguments as String),
  AppRoutes.camera: (context, settings) => const CameraView(),
  AppRoutes.photo: (context, settings) => const PhotoView(),
  AppRoutes.detailPhoto: (context, settings) =>
      DetailPhotoView(photo: settings.arguments as Photo),
  AppRoutes.codeQr: (context, settings) => const QrView(),
};
