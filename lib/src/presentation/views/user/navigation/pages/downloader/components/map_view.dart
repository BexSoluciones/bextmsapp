import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

//domain
import '../../../../../../../domain/models/enterprise_config.dart';

//cubits
import '../../../../../../cubits/download/download_cubit.dart';
import '../../../../../../cubits/general/general_cubit.dart';

//utils
import '../../../../../../../utils/constants/enums.dart';

//widgets
import 'cross-hairs.dart';
import '../../../../../../widgets/loading_indicator_widget.dart';

class MapView extends StatefulWidget {
  const MapView({
    super.key,
    this.enterpriseConfig
  });

  final EnterpriseConfig? enterpriseConfig;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const double _shapePadding = 15;
  static const _crosshairsMovement = Point<double>(10, 10);

  final _mapKey = GlobalKey<State<StatefulWidget>>();
  final MapController _mapController = MapController();

  late final StreamSubscription _polygonVisualizerStream;
  late final StreamSubscription _tileCounterTriggerStream;
  late final StreamSubscription _manualPolygonRecalcTriggerStream;

  Point<double>? _crosshairsTop;
  Point<double>? _crosshairsBottom;
  LatLng? _coordsTopLeft;
  LatLng? _coordsBottomRight;
  LatLng? _center;
  double? _radius;

  PolygonLayer _buildTargetPolygon(BaseRegion region) => PolygonLayer(
        polygons: [
          Polygon(
            points: [
              LatLng(-90, 180),
              LatLng(90, 180),
              LatLng(90, -180),
              LatLng(-90, -180),
            ],
            holePointsList: [region.toOutline()],
            isFilled: true,
            borderColor: Colors.black,
            borderStrokeWidth: 2,
            color: Theme.of(context).colorScheme.background.withOpacity(2 / 3),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();

    _manualPolygonRecalcTriggerStream =
        BlocProvider.of<DownloadCubit>(context, listen: false)
            .manualPolygonRecalcTrigger
            .stream
            .listen((_) {
      _updatePointLatLng();
      _countTiles();
    });

    _polygonVisualizerStream =
        _mapController.mapEventStream.listen((_) => _updatePointLatLng());
    _tileCounterTriggerStream = _mapController.mapEventStream
        .debounce(const Duration(seconds: 1))
        .listen((_) => _countTiles());
  }

  @override
  void dispose() {
    super.dispose();

    _polygonVisualizerStream.cancel();
    _tileCounterTriggerStream.cancel();
    _manualPolygonRecalcTriggerStream.cancel();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DownloadCubit, DownloadState>(
        key: _mapKey,
        builder: (context, downloadCubit) => BlocBuilder<GeneralCubit, GeneralState>(
          builder: (context, generalState) =>  FutureBuilder<Map<String, String>?>(
            future: generalState.currentStore == null
                ? Future.sync(() => {})
                : FMTC.instance(generalState.currentStore!).metadata.readAsync,
            builder: (context, metadata) {
              if (!metadata.hasData ||
                  metadata.data == null ||
                  (generalState.currentStore != null &&
                      (metadata.data ?? {}).isEmpty)) {
                return const LoadingIndicator(
                  message:
                  'Loading Settings...\n\nSeeing this screen for a long time?\nThere may be a misconfiguration of the\nstore. Try disabling caching and deleting\n faulty stores.',
                );
              }

              final String urlTemplate =
              generalState.currentStore != null && metadata.data != null
                  ? metadata.data!['sourceURL']!
                  : 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token={accessToken}';

              return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: LatLng(4.645345,-74.3390061),
                      zoom: 9.2,
                      maxZoom: 22,
                      maxBounds: LatLngBounds.fromPoints([
                        LatLng(-90, 180),
                        LatLng(90, 180),
                        LatLng(90, -180),
                        LatLng(-90, -180),
                      ]),
                      interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                      scrollWheelVelocity: 0.002,
                      keepAlive: true,
                      onMapReady: () {
                        _updatePointLatLng();
                        _countTiles();
                      },
                    ),
                    nonRotatedChildren: [
                      AttributionWidget.defaultWidget(
                        source: Uri.parse(urlTemplate).host,
                        alignment: Alignment.bottomLeft,
                      ),
                    ],
                    children: [
                      TileLayer(
                        urlTemplate: urlTemplate,
                        additionalOptions: {
                          'accessToken': widget.enterpriseConfig != null
                              ? widget.enterpriseConfig!.mapbox!
                              : 'sk.eyJ1IjoiYmV4aXRhY29sMiIsImEiOiJjbDVnc3ltaGYwMm16M21wZ21rMXg1OWd6In0.Dwtkt3r6itc0gCXDQ4CVxg',
                        },
                        maxZoom: 20,
                        reset: generalState.resetController?.stream,
                        keepBuffer: 5,
                        backgroundColor: const Color(0xFFaad3df),
                        tileBuilder: (context, widget, tile) =>
                            FutureBuilder<bool?>(
                              future: generalState.currentStore == null
                                  ? Future.sync(() => null)
                                  : FMTC
                                  .instance(generalState.currentStore!)
                                  .getTileProvider()
                                  .checkTileCachedAsync(
                                coords: tile.coords,
                                options: TileLayer(
                                  urlTemplate: urlTemplate,
                                ),
                              ),
                              builder: (context, snapshot) => DecoratedBox(
                                position: DecorationPosition.foreground,
                                decoration: BoxDecoration(
                                  color: (snapshot.data ?? false)
                                      ? Colors.deepOrange.withOpacity(0.33)
                                      : Colors.transparent,
                                ),
                                child: widget,
                              ),
                            ),
                      ),
                      if (_coordsTopLeft != null &&
                          _coordsBottomRight != null &&
                          downloadCubit.regionMode != RegionMode.circle)
                        _buildTargetPolygon(
                          RectangleRegion(
                            LatLngBounds(_coordsTopLeft, _coordsBottomRight),
                          ),
                        )
                      else if (_center != null &&
                          _radius != null &&
                          downloadCubit.regionMode == RegionMode.circle)
                        _buildTargetPolygon(CircleRegion(_center!, _radius!))
                    ],
                  ),
                  if (_crosshairsTop != null && _crosshairsBottom != null) ...[
                    Positioned(
                      top: _crosshairsTop!.y,
                      left: _crosshairsTop!.x,
                      child: const Crosshairs(),
                    ),
                    Positioned(
                      top: _crosshairsBottom!.y,
                      left: _crosshairsBottom!.x,
                      child: const Crosshairs(),
                    ),
                  ]
                ],
              );
            },
          ),
        ),

      );

  void _updatePointLatLng() {
    final DownloadCubit downloadCubit =
        BlocProvider.of<DownloadCubit>(context, listen: false);

    final Size mapSize = _mapKey.currentContext!.size!;
    final bool isHeightLongestSide = mapSize.width < mapSize.height;

    final centerNormal = Point<double>(mapSize.width / 2, mapSize.height / 2);
    final centerInversed = Point<double>(mapSize.height / 2, mapSize.width / 2);

    late final Point<double> calculatedTopLeft;
    late final Point<double> calculatedBottomRight;

    switch (downloadCubit.regionMode!) {
      case RegionMode.square:
        final double offset = (mapSize.shortestSide - (_shapePadding * 2)) / 2;

        calculatedTopLeft = Point<double>(
          centerNormal.x - offset,
          centerNormal.y - offset,
        );
        calculatedBottomRight = Point<double>(
          centerNormal.x + offset,
          centerNormal.y + offset,
        );
        break;
      case RegionMode.rectangleVertical:
        final allowedArea = Size(
          mapSize.width - (_shapePadding * 2),
          (mapSize.height - (_shapePadding * 2)) / 1.5 - 50,
        );

        calculatedTopLeft = Point<double>(
          centerInversed.y - allowedArea.shortestSide / 2,
          _shapePadding,
        );
        calculatedBottomRight = Point<double>(
          centerInversed.y + allowedArea.shortestSide / 2,
          mapSize.height - _shapePadding - 25,
        );
        break;
      case RegionMode.rectangleHorizontal:
        final allowedArea = Size(
          mapSize.width - (_shapePadding * 2),
          (mapSize.width < mapSize.height + 250)
              ? (mapSize.width - (_shapePadding * 2)) / 1.75
              : (mapSize.height - (_shapePadding * 2) - 0),
        );

        calculatedTopLeft = Point<double>(
          _shapePadding,
          centerNormal.y - allowedArea.height / 2,
        );
        calculatedBottomRight = Point<double>(
          mapSize.width - _shapePadding,
          centerNormal.y + allowedArea.height / 2 - 25,
        );
        break;
      case RegionMode.circle:
        final allowedArea =
            Size.square(mapSize.shortestSide - (_shapePadding * 2));

        final calculatedTop = Point<double>(
          centerNormal.x,
          (isHeightLongestSide ? centerNormal.y : centerInversed.x) -
              allowedArea.width / 2,
        );

        _crosshairsTop = calculatedTop - _crosshairsMovement;
        _crosshairsBottom = centerNormal - _crosshairsMovement;

        _center =
            _mapController.pointToLatLng(_customPointFromPoint(centerNormal));
        _radius = const Distance(roundResult: false).distance(
              _center!,
              _mapController
                  .pointToLatLng(_customPointFromPoint(calculatedTop))!,
            ) /
            1000;
        setState(() {});
        break;
    }

    if (downloadCubit.regionMode != RegionMode.circle) {
      _crosshairsTop = calculatedTopLeft - _crosshairsMovement;
      _crosshairsBottom = calculatedBottomRight - _crosshairsMovement;

      _coordsTopLeft = _mapController
          .pointToLatLng(_customPointFromPoint(calculatedTopLeft));
      _coordsBottomRight = _mapController
          .pointToLatLng(_customPointFromPoint(calculatedBottomRight));

      setState(() {});
    }

    downloadCubit.region = downloadCubit.regionMode == RegionMode.circle
        ? CircleRegion(_center!, _radius!)
        : RectangleRegion(
            LatLngBounds(_coordsTopLeft, _coordsBottomRight),
          );
  }

  Future<void> _countTiles() async {
    final DownloadCubit downloadCubit =
        BlocProvider.of<DownloadCubit>(context, listen: false);

    if (downloadCubit.region != null) {
      downloadCubit
        ..regionTiles = null
        ..regionTiles = await FMTC.instance('').download.check(
              downloadCubit.region!.toDownloadable(
                downloadCubit.minZoom,
                downloadCubit.maxZoom,
                TileLayer(),
              ),
            );
    }
  }
}

CustomPoint<E> _customPointFromPoint<E extends num>(Point<E> point) =>
    CustomPoint(point.x, point.y);
