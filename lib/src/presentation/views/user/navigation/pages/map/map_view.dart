import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:showcaseview/showcaseview.dart';

//utils
import '../../../../../../utils/constants/strings.dart';

//blocs
import '../../../../../blocs/location/location_bloc.dart';
import '../../../../../blocs/network/network_bloc.dart';

//cubit
import '../../../../../cubits/navigation/navigation_cubit.dart';
import '../../../../../cubits/general/general_cubit.dart';

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
            if (navigationState.runtimeType == NavigationLoading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (navigationState.runtimeType == NavigationSuccess ||
                navigationState.runtimeType == NavigationFailed) {
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
              context.read<NavigationCubit>().clean();
            }),
        title: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, navigationState) {
            if (navigationState is NavigationLoading) {
              // Show loading indicator
              return const Row(
                children: [
                  CupertinoActivityIndicator(),
                ],
              );
            } else if (navigationState is NavigationSuccess) {
              // Show client count
              return Text(
                  'Clientes a visitar: ${navigationState.works.length}');
            } else {
              // Handle other states or return an empty widget
              return const SizedBox();
            }
          },
        ),
        actions: [
          BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, navigationState) {
              if (navigationState is NavigationLoading) {
                // Show loading indicator
                return const Row(
                  children: [
                    CupertinoActivityIndicator(),
                  ],
                );
              } else if (navigationState is NavigationSuccess) {
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
                          var navigationCubit = context.read<NavigationCubit>();
                          var work = navigationCubit
                              .state.works[navigationCubit.state.pageIndex];
                          _navigationService.goTo(AppRoutes.summaryNavigation, arguments: SummaryNavigationArgument(work: work));
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
    return BlocBuilder<GeneralCubit, GeneralState>(
        builder: (context, generalState) => FutureBuilder<Map<String, String>?>(
            future: generalState.currentStore == null
                ? Future.sync(() => {})
                : FMTC.instance(generalState.currentStore!).metadata.readAsync,
            builder: (context, metadata) {
              if (!metadata.hasData ||
                  metadata.data == null ||
                  (generalState.currentStore != null &&
                      metadata.data!.isEmpty)) {
                return const LoadingIndicator(
                  message:
                      'Loading Settings...\n\nSeeing this screen for a long time?\nThere may be a misconfiguration of the\nstore. Try disabling caching and deleting\n faulty stores.',
                );
              }

              final String urlTemplate = generalState.currentStore != null &&
                      metadata.data != null
                  ? metadata.data!['sourceURL']!
                  : 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token={accessToken}';

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
                                    return _buildBodyNetworkSuccess(
                                        size,
                                        state,
                                        true,
                                        urlTemplate,
                                        generalState,
                                        metadata);
                                  case NetworkFailure:
                                    return _buildBodyNetworkSuccess(
                                        size,
                                        state,
                                        true,
                                        urlTemplate,
                                        generalState,
                                        metadata);
                                  case NetworkSuccess:
                                    return _buildBodyNetworkSuccess(
                                        size,
                                        state,
                                        false,
                                        urlTemplate,
                                        generalState,
                                        metadata);
                                  default:
                                    return const SizedBox();
                                }
                              })))));
            }));
  }

  Widget _buildBodyNetworkSuccess(Size size, state, bool offline,
      String urlTemplate, generalState, metadata) {
    return Stack(
      children: [
        state.works.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 1.0,
                child: FlutterMap(
                  mapController: state.mapController,
                  options: MapOptions(
                      keepAlive: true,
                      center: state.markers[1].point,
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
                      onTap: (position, location) {
                        //TODO:: notes for transporter to route
                        try {
                          if (kDebugMode) {
                            print(location.latitude);
                            print(location.longitude);
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                        }
                      }),
                  nonRotatedChildren: [
                    AttributionWidget.defaultWidget(
                      source: Uri.parse(urlTemplate).host,
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
                      tileProvider: generalState.currentStore != null
                          ? FMTC.instance(state.currentStore!).getTileProvider(
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
                      polylines: state.Polylines,
                    ),
                    MarkerLayer(
                      markers: state.markers,
                    ),
                  ],
                ))
            : const LottieWidget(
                path: 'assets/animations/58404-geo-location-icon.json',
                message: 'No hay clientes con geolocalización.'),
        state.carouselData != null &&
                state.carouselData.isNotEmpty &&
                state.works.isNotEmpty
            ? CarouselSlider(
                items: List<Widget>.generate(
                    state.carouselData.length,
                    (index) => CarouselCard(
                        work: state.works[index] ?? 999,
                        index: state.carouselData[index]['index'],
                        distance: state.carouselData[index]['distance'],
                        duration: state.carouselData[index]['duration'],
                        context: context)),
                carouselController: state.buttonCarouselController,
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
