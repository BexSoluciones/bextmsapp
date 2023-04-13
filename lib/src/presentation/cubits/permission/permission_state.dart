part of 'permission_cubit.dart';

abstract class PermissionState extends Equatable {
  final Permission? currentPermission;
  final PermissionRepository permissionRepository;

  const PermissionState({
    required this.permissionRepository,
    this.currentPermission
  });

  @override
  List<Object?> get props => [permissionRepository, currentPermission];
}

class WaitingForPermission extends PermissionState {
  const WaitingForPermission({required super.permissionRepository});
}

class AllPermissionsGranted extends PermissionState {
  const AllPermissionsGranted({required super.permissionRepository});
}

class PermissionDenied extends PermissionState {
  const PermissionDenied({required super.permissionRepository, required super.currentPermission});
}

class PermissionPermanentlyDenied extends PermissionState {
  const PermissionPermanentlyDenied({required super.permissionRepository, required super.currentPermission});
}

class PermissionRestricted extends PermissionState {
  const PermissionRestricted({required super.permissionRepository, required super.currentPermission});
}


class PermissionNeeded extends PermissionState {
  const PermissionNeeded({required super.permissionRepository});
}