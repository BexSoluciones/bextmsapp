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
  final int pageIndex;

  final bool isLoadingFullScreenNavigation;
  final bool isLoadingPosition;

  const NavigationState(
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
        pageIndex,
        error
      ];
}

class NavigationLoading extends NavigationState {
  const NavigationLoading();
}

class NavigationLoadingMap extends NavigationState {
  const NavigationLoadingMap();
}

class NavigationSuccess extends NavigationState {
  const NavigationSuccess(
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
      super.pageIndex,
      super.model});
}

class NavigationFailed extends NavigationState {
  const NavigationFailed({super.error});
}
