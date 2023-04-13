import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

//utils
import '../../../utils/constants/enums.dart';

part 'download_state.dart';

class DownloadBloc extends Cubit<DownloadState> {
  DownloadBloc() : super(DownloadLoading());

  RegionMode? get regionMode => state.regionMode;

  set regionMode(RegionMode? newMode) {
    regionMode = newMode;
  }

  BaseRegion? get region => state.region;

  set region(BaseRegion? newRegion) {
    region = newRegion;
  }

  int? get regionTiles => state.regionTiles;

  set regionTiles(int? newNum) {
    regionTiles = newNum;
  }

  int get minZoom => state.minZoom;

  set minZoom(int newNum) {
    minZoom = newNum;
  }

  int get maxZoom => state.maxZoom;

  set maxZoom(int newNum) {
    maxZoom = newNum;
  }

  StoreDirectory? get selectedStore => state.selectedStore;

  set selectedStore(StoreDirectory? newStore) {
    selectedStore = newStore;
  }

  StreamController<void> get manualPolygonRecalcTrigger =>
      state.manualPolygonRecalcTrigger;

  void triggerManualPolygonRecalc() =>
      state.manualPolygonRecalcTrigger.add(null);

  Stream<DownloadProgress>? get downloadProgress => state.downloadProgress;

  set downloadProgress(Stream<DownloadProgress>? newStream) {
    downloadProgress = newStream;
  }

  bool get preventRedownload => state.preventRedownload;

  set preventRedownload(bool newBool) {
    preventRedownload = newBool;
  }

  bool get seaTileRemoval => state.seaTileRemoval;

  set seaTileRemoval(bool newBool) {
    seaTileRemoval = newBool;
  }

  bool get disableRecovery => state.disableRecovery;
  set disableRecovery(bool newBool) {
    disableRecovery = newBool;
  }

  DownloadBufferMode get bufferMode => state.bufferMode;

  set bufferMode(DownloadBufferMode newMode) {
    bufferMode = newMode;
    bufferingAmount = newMode == DownloadBufferMode.tiles ? 500 : 5000;
  }

  int get bufferingAmount => state.bufferingAmount;

  set bufferingAmount(int newNum) {
    bufferingAmount = newNum;
  }
}
