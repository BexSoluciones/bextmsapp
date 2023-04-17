part of 'download_cubit.dart';

class DownloadState extends Equatable {
  RegionMode? regionMode;
  final BaseRegion? region;
  int? regionTiles;
  int minZoom;
  int maxZoom;
  StoreDirectory? selectedStore;
  final StreamController<void> manualPolygonRecalcTrigger = StreamController.broadcast();
  Stream<DownloadProgress>? downloadProgress;
  bool preventRedownload;
  bool seaTileRemoval;
  bool disableRecovery;
  DownloadBufferMode bufferMode;
  int bufferingAmount;

  final String? error;

  DownloadState(
      {this.regionMode = RegionMode.square,
      this.region,
      this.regionTiles,
      this.minZoom = 1,
      this.maxZoom = 16,
      this.selectedStore,
      this.downloadProgress,
      this.preventRedownload = false,
      this.seaTileRemoval = true,
      this.disableRecovery = false,
      this.bufferMode = DownloadBufferMode.tiles,
      this.bufferingAmount = 500,
      this.error});

  @override
  List<Object?> get props => [
        regionMode,
        region,
        regionTiles,
        minZoom,
        maxZoom,
        manualPolygonRecalcTrigger,
        downloadProgress,
        preventRedownload,
        seaTileRemoval,
        disableRecovery,
        bufferMode,
        bufferingAmount,
        error
      ];
}

class DownloadLoading extends DownloadState {
  DownloadLoading();
}

class DownloadSuccess extends DownloadState {
  DownloadSuccess(
      {super.regionMode,
      super.region,
      super.regionTiles,
      super.minZoom,
      super.maxZoom,
      manualPolygonRecalcTrigger,
      super.downloadProgress,
      super.preventRedownload,
      super.seaTileRemoval,
      super.disableRecovery,
      super.bufferMode,
      super.bufferingAmount});
}

class DownloadFailed extends DownloadState {
  DownloadFailed({super.error});
}
