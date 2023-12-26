part of 'navigation_cubit.dart';

enum NavigationStatus { initial, loading, success, failure }

extension NavigationStateX on NavigationStatus {
  bool get isInitial => this == NavigationStatus.initial;
  bool get isLoading => this == NavigationStatus.loading;
  bool get isSuccess => this == NavigationStatus.success;
  bool get isError => this == NavigationStatus.failure;
}

class NavigationState extends Equatable {
  final NavigationStatus? status;
  //CONTROLLERS
  final MapController? mapController;
  final CarouselController? carouselController;
  //LISTS
  final List<Work>? works;
  final List<PolylineLayer>? layer;
  final List<Marker>? markers;
  final List<LatLng>? kWorksList;
  final List<Map>? carouselData;
  final List<LayerMoodle>? model;
  final List<Polyline>? polylines;
  //VARIABLES
  final double? rotation;
  final int? pageIndex;
  final String? error;

  const NavigationState(
      {this.status,
      this.works,
      this.mapController,
      this.rotation,
      this.carouselController,
      this.layer,
      this.markers,
      this.kWorksList,
      this.carouselData,
      this.model,
      this.polylines,
      this.pageIndex,
      this.error});

  @override
  List<Object?> get props => [
        status,
        works,
        mapController,
        carouselController,
        rotation,
        layer,
        markers,
        kWorksList,
        carouselData,
        model,
        polylines,
        pageIndex,
        error
      ];

  NavigationState copyWith({
    NavigationStatus? status,
    MapController? mapController,
    CarouselController? carouselController,
    List<Work>? works,
    List<PolylineLayer>? layer,
    List<LatLng>? kWorkList,
    List<Marker>? markers,
    List<Polyline>? polylines,
    List<Map>? carouselData,
    List<LayerMoodle>? model,
    double? rotation,
    int? pageIndex,
    String? error,
  }) {
    return NavigationState(
      status: status ?? this.status,
      mapController: mapController ?? this.mapController,
      carouselController: carouselController ?? this.carouselController,
      works: works ?? this.works,
      layer: layer ?? this.layer,
      kWorksList: kWorksList ?? this.kWorksList,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      carouselData: carouselData ?? this.carouselData,
      model: model ?? this.model,
      rotation: rotation ?? this.rotation,
      pageIndex: pageIndex ?? this.pageIndex,
      error: error ?? this.error,
    );
  }
}
