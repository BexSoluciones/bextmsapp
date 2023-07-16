import 'package:permission_handler/permission_handler.dart';

List<Permission> permissionList = [
  Permission.camera,
  Permission.locationWhenInUse,
  Permission.locationAlways
];

enum RegionMode {
  square,
  rectangleVertical,
  rectangleHorizontal,
  circle,
}