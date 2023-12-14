import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:equatable/equatable.dart';

//domain
import '../../../data/repositories/permission_repository_impl.dart';

//utils
import '../../../utils/constants/enums.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(WaitingForPermission(permissionRepository: PermissionRepository.waiting()));

  late Permission currentPermission;

  void onAllPermissionGranted() {
    emit(AllPermissionsGranted(permissionRepository: PermissionRepository.granted()));
  }

  Future<void> checkIfPermissionNeeded() async {
    for (var permission in permissionList) {
      currentPermission = permission;
      var status = await permission.status;
      if (!status.isGranted) {
        emit(PermissionNeeded(
            permissionRepository: PermissionRepository.waiting()));
        return;
      }
    }
    onAllPermissionGranted();
  }

  Future<void> onRequestAllPermission() async {
    for (var permission in permissionList) {
      currentPermission = permission;
      var status = await permission.status;
      if (status.isDenied) {
        status = await permission.request();
        if (status.isDenied) {
          onPermissionDenied();
          return;
        }
      } else if (status.isPermanentlyDenied) {
        onPermissionPermanentlyDenied();
        return;
      } else if (status.isRestricted) {
        onPermissionRestricted();
        return;
      }
    }

    for (var permission in permissionList) {
      var status = await permission.status;
      if (!status.isGranted) {
        return;
      }
    }
    onAllPermissionGranted();
  }

  void onPermissionDenied() {
    emit(PermissionDenied(
        currentPermission: currentPermission,
        permissionRepository: PermissionRepository.denied()));
  }

  void onPermissionPermanentlyDenied() {
    emit(PermissionPermanentlyDenied(
        currentPermission: currentPermission,
        permissionRepository: PermissionRepository.permanentlyDenied()));
  }

  void onPermissionRestricted() {
    emit(PermissionRestricted(
        currentPermission: currentPermission,
        permissionRepository: PermissionRepository.permanentlyDenied()));
  }

  @override
  String toString() =>
      'PermissionCubit(permissionList: $permissionList)';
}