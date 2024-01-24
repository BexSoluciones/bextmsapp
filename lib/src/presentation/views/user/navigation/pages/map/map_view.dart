import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
//utils
import '../../../../../../utils/constants/strings.dart';
//blocs
import '../../../../../blocs/location/location_bloc.dart';
import '../../../../../blocs/network/network_bloc.dart';
//cubit
import '../../../../../cubits/navigation/navigation_cubit.dart';
//providers
import '../../../../../providers/general_provider.dart';
//domain
import '../../../../../../domain/models/arguments.dart';
import '../../../../../../domain/models/enterprise_config.dart';
//widgets
import '../../../../../widgets/loading_indicator_widget.dart';
import '../../../../../widgets/lottie_widget.dart';
import '../../features/carousel_card.dart';
//services
import '../../../../../../locator.dart';
import '../../../../../../services/navigation.dart';
import 'build_attribution.dart';

final NavigationService _navigationService = locator<NavigationService>();

class LayerMoodle {
  LayerMoodle(this.polygons);
  List<Polyline> polygons = <Polyline>[];
}

class MapPage extends StatefulWidget {
  const MapPage(
      {super.key,
      required this.one,
      required this.workcode,
      this.enterpriseConfig});

  final GlobalKey one;
  final String workcode;
  final EnterpriseConfig? enterpriseConfig;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late NavigationCubit navigationCubit;
  late LocationBloc locationBloc;
  late NetworkBloc networkCubit;

  // Create your stream
  final _streamController = StreamController<double>();
  Stream<double> get onZoomChanged => _streamController.stream;
  double zoom = 15.0;

  @override
  void initState() {
    networkCubit = BlocProvider.of<NetworkBloc>(context);
    networkCubit.add(NetworkObserve());

    navigationCubit = BlocProvider.of<NavigationCubit>(context);
    navigationCubit.getAllWorksByWorkcode(widget.workcode);

    onZoomChanged.listen((event) {
      setState(() {
        zoom = event;
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.add(GetLocation());

    navigationCubit = BlocProvider.of<NavigationCubit>(context);
    navigationCubit.getAllWorksByWorkcode(widget.workcode);

    networkCubit = BlocProvider.of<NetworkBloc>(context);
    networkCubit.add(NetworkObserve());
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: buildAppBar,
        body: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, navigationState) {
            if (navigationState.status == NavigationStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (navigationState.status == NavigationStatus.success ||
                navigationState.status == NavigationStatus.failure) {
              return _buildBody(size, navigationState);
            } else {
              return const SizedBox();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'btn1',
          onPressed: () async {
            await navigationCubit.getCurrentPosition(zoom);
          },
          child: const Icon(Icons.my_location),
        ));
  }

  AppBar get buildAppBar => AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              _navigationService.goBack();
            }),
        title: BlocSelector<NavigationCubit, NavigationState, bool>(
          selector: (state) => state.status == NavigationStatus.success,
          builder: (context, condition) {
            var works = context.read<NavigationCubit>().state.works;
            return condition
                ? Text('Clientes a visitar: ${works!.length}')
                : const Row(
                    children: [
                      CupertinoActivityIndicator(),
                    ],
                  );
          },
        ),
        actions: [
          BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, navigationState) {
              if (navigationState.status == NavigationStatus.loading) {
                return const Row(
                  children: [
                    CupertinoActivityIndicator(),
                  ],
                );
              } else if (navigationState.status == NavigationStatus.success ||
                  navigationState.status == NavigationStatus.failure) {
                // Show client count
                return Showcase(
                    key: widget.one,
                    disableMovingAnimation: true,
                    title: 'Navegación completa!',
                    description:
                        'Ingresa a la navegación completa y deja que te guiemos!',
                    child: IconButton(
                        icon: const Icon(Icons.directions),
                        onPressed: () {
                          var work = navigationState
                              .works![navigationState.pageIndex ?? 0];
                          _navigationService.goTo(AppRoutes.summaryNavigation,
                              arguments: SummaryNavigationArgument(work: work));
                        }));
              } else {
                // Handle other states or return an empty widget
                return const SizedBox();
              }
            },
          ),
        ],
      );

  Widget _buildBody(Size size, state) {
    return Consumer<GeneralProvider>(
        builder: (context, provider, _) => FutureBuilder<Map<String, String>?>(
            future: provider.currentStore == null
                ? Future.sync(() => {})
                : FMTC.instance(provider.currentStore!).metadata.readAsync,
            builder: (context, metadata) {
              if (!metadata.hasData ||
                  metadata.data == null ||
                  (provider.currentStore != null && metadata.data!.isEmpty)) {
                return const LoadingIndicator(
                  message:
                      'Cargando configuración...\n\n¿Ves esta pantalla durante mucho tiempo?\nPuede haber una mala configuración del\n la tienda. Intente deshabilitar el almacenamiento en caché y eliminar\n tiendas defectuosas.',
                );
              }

              final String urlTemplate = provider.currentStore != null &&
                      metadata.data != null
                  ? metadata.data!['sourceURL']!
                  : 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png';

              return BlocBuilder<NavigationCubit, NavigationState>(
                  builder: (context, state) => SingleChildScrollView(
                      child: SafeArea(
                          child: SizedBox(
                              height: size.height,
                              width: size.width,
                              child: BlocBuilder<NetworkBloc, NetworkState>(
                                  builder: (context, networkState) {
                                switch (networkState.runtimeType) {
                                  case NetworkInitial:
                                    return _buildBodyNetworkSuccess(size, state,
                                        true, urlTemplate, provider, metadata);
                                  case NetworkFailure:
                                    return _buildBodyNetworkSuccess(size, state,
                                        true, urlTemplate, provider, metadata);
                                  case NetworkSuccess:
                                    return _buildBodyNetworkSuccess(size, state,
                                        false, urlTemplate, provider, metadata);
                                  default:
                                    return const SizedBox();
                                }
                              })))));
            }));
  }

  Widget _buildBodyNetworkSuccess(Size size, NavigationState state,
      bool offline, String urlTemplate, GeneralProvider provider, metadata) {
    return Stack(
      children: [
        state.works != null && state.works!.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1.0,
                child: FlutterMap(
                  mapController: state.mapController,
                  options: MapOptions(
                      keepAlive: true,
                      center: state.markers != null
                          ? state.markers![1].point
                          : null,
                      maxZoom: 18,
                      zoom: 9.2,
                      interactiveFlags:
                          InteractiveFlag.all & ~InteractiveFlag.rotate,
                      scrollWheelVelocity: 0.002,
                      onPositionChanged: (position, hasGesture) {
                        final zoom = position.zoom;
                        if (zoom != null) {
                          _streamController.sink.add(zoom);
                        }
                      },
                      onTap: (position, location) async {
                        try {
                          var position =
                              LatLng(location.latitude, location.longitude);
                          await navigationCubit.createNote(position);
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      }),
                  nonRotatedChildren: buildStdAttribution(urlTemplate),
                  children: [
                    TileLayer(
                      urlTemplate: urlTemplate,
                      additionalOptions: {
                        'accessToken': widget.enterpriseConfig != null
                            ? widget.enterpriseConfig!.mapbox!
                            : 'sk.eyJ1IjoiYmV4aXRhY29sMiIsImEiOiJjbDVnc3ltaGYwMm16M21wZ21rMXg1OWd6In0.Dwtkt3r6itc0gCXDQ4CVxg',
                      },
                      tileProvider: provider.currentStore != null
                          ? FMTC
                              .instance(provider.currentStore!)
                              .getTileProvider(
                                FMTCTileProviderSettings(
                                  behavior: CacheBehavior.values
                                      .byName(metadata.data!['behaviour']!),
                                  cachedValidDuration: int.parse(
                                            metadata.data!['validDuration']!,
                                          ) ==
                                          0
                                      ? Duration.zero
                                      : Duration(
                                          days: int.parse(
                                            metadata.data!['validDuration']!,
                                          ),
                                        ),
                                  maxStoreLength: int.parse(
                                    metadata.data!['maxLength']!,
                                  ),
                                ),
                              )
                          : NetworkNoRetryTileProvider(),
                    ),
                    //...state.layer,
                    PolylineLayer(
                      polylines: state.polylines ?? [],
                    ),
                    MarkerLayer(
                      markers: state.markers ?? [],
                    ),
                  ],
                ))
            : const LottieWidget(
                path: 'assets/animations/58404-geo-location-icon.json',
                message: 'No hay clientes con geolocalización.'),
        state.carouselData != null &&
                state.carouselData!.isNotEmpty &&
                state.works != null &&
                state.works!.isNotEmpty
            ? CarouselSlider(
                items: List<Widget>.generate(
                    state.carouselData!.length,
                    (index) => CarouselCard(
                        work: state.works![index],
                        index: state.carouselData![index]['index'],
                        distance: state.carouselData![index]['distance'],
                        duration: state.carouselData![index]['duration'],
                        context: context)),
                carouselController: state.carouselController,
                options: CarouselOptions(
                  height: 100,
                  viewportFraction: 0.6,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  scrollDirection: Axis.horizontal,
                  onPageChanged:
                      (int index, CarouselPageChangedReason reason) async {
                    navigationCubit.moveController(index, zoom);
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}
