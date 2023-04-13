part of 'download_cubit.dart';

class DownloadState extends Equatable {
  final RegionMode? regionMode;
  final BaseRegion? region;
  final int? regionTiles;
  final int minZoom;
  final int maxZoom;
  final StoreDirectory? selectedStore;
  final StreamController<void> manualPolygonRecalcTrigger = StreamController.broadcast();
  final Stream<DownloadProgress>? downloadProgress;
  final bool preventRedownload;
  final bool seaTileRemoval;
  final bool disableRecovery;
  final DownloadBufferMode bufferMode;
  final int bufferingAmount;

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
