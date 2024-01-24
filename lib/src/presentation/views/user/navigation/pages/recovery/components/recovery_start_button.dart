import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';
//utils
import '../../../../../../../utils/constants/strings.dart';
//provider
import '../../../../../../providers/download_provider.dart';
//services
import '../../../../../../../locator.dart';
import '../../../../../../../services/navigation.dart';

final NavigationService _navigationService = locator<NavigationService>();

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
                          final DownloadProvider downloadProvider =
                              Provider.of<DownloadProvider>(
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
                                ..setSelectedStore(
                                  FMTC.instance(region.storeName),
                                )
                                ..regionTiles = tiles.data;

                          await _navigationService.goTo(AppRoutes.downloader,
                              arguments: downloadProvider.region);

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
