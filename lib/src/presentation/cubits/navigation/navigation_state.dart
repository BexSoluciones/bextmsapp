part of 'navigation_cubit.dart';

abstract class NavigationState extends Equatable {
  final List<Work> works;
  final String? error;
  final MapController? mapController;
  final CarouselController? buttonCarouselController;
  final double rotation;
  final List<PolylineLayer>? layer;
  final List<Marker>? markers;
  final List<LatLng>? kWorksList;
  final List<Map>? carouselData;
  final List<LayerMoodle>? model;
  List<Polyline>? Polylines = [];
  final int pageIndex;

  final bool isLoadingFullScreenNavigation;
  final bool isLoadingPosition;

  NavigationState(
      {this.works = const [],
      this.isLoadingFullScreenNavigation = false,
      this.isLoadingPosition = false,
      this.mapController,
      this.rotation = 0,
      this.buttonCarouselController,
      this.layer,
      this.markers,
      this.kWorksList,
      this.carouselData,
      this.model,
        this.Polylines,
      this.pageIndex = 0,
      this.error});

  @override
  List<Object?> get props => [
        works,
        isLoadingFullScreenNavigation,
        isLoadingPosition,
        mapController,
        buttonCarouselController,
        rotation,
        layer,
        markers,
        kWorksList,
        carouselData,
        model,
        Polylines,
        pageIndex,
        error
      ];
}

class NavigationLoading extends NavigationState {
  NavigationLoading();
}

class NavigationLoadingMap extends NavigationState {
   NavigationLoadingMap();
}

class NavigationSuccess extends NavigationState {
   NavigationSuccess(
      {super.works,
      super.isLoadingFullScreenNavigation,
      super.isLoadingPosition,
      super.mapController,
      super.buttonCarouselController,
      super.layer,
      super.markers,
      super.rotation,
      super.kWorksList,
      super.carouselData,
        super.Polylines,
      super.pageIndex,
      super.model});
}

class NavigationFailed extends NavigationState {
   NavigationFailed({super.error});
}
