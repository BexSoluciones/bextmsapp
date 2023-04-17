import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//cubit
import '../../../../../../cubits/download/download_cubit.dart';
import '../../../features/download_region.dart';

class RecoveryStartButton extends StatelessWidget {
  const RecoveryStartButton({
    super.key,
    required this.moveToDownloadPage,
    required this.region,
  });

  final void Function() moveToDownloadPage;
  final RecoveredRegion region;

  @override
  Widget build(BuildContext context) => FutureBuilder<RecoveredRegion?>(
        future: FMTC.instance.rootDirectory.recovery.getFailedRegion(region.id),
        builder: (context, isFailed) => FutureBuilder<int>(
          future: FMTC
              .instance('')
              .download
              .check(region.toDownloadable(TileLayer())),
          builder: (context, tiles) => tiles.hasData
              ? IconButton(
                  icon: Icon(
                    Icons.download,
                    color: isFailed.data != null ? Colors.green : null,
                  ),
                  onPressed: isFailed.data == null
                      ? null
                      : () async {
                          final DownloadCubit downloadCubit =
                              BlocProvider.of<DownloadCubit>(
                            context,
                            listen: false,
                          )
                                ..region = region
                                    .toDownloadable(TileLayer())
                                    .originalRegion
                                ..minZoom = region.minZoom
                                ..maxZoom = region.maxZoom
                                ..preventRedownload = region.preventRedownload
                                ..seaTileRemoval = region.seaTileRemoval
                                ..selectedStore = FMTC.instance(region.storeName)
                                ..regionTiles = tiles.data;

                          await Navigator.of(context).push(
                            MaterialPageRoute<String>(
                              builder: (BuildContext context) =>
                                  DownloadRegionPopup(
                                region: downloadCubit.region!,
                              ),
                              fullscreenDialog: true,
                            ),
                          );

                          moveToDownloadPage();
                        },
                )
              : const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ),
        ),
      );
}
