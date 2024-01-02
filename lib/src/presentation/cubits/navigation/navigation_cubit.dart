import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:location_repository/location_repository.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

//core
import '../../../../core/helpers/index.dart';

//utils
import '../../../utils/constants/strings.dart';

//cubits
import '../../blocs/gps/gps_bloc.dart';
import '../base/base_cubit.dart';

//blocs

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';

//services
import '../../../locator.dart';
import '../../../services/navigation.dart';
import '../../../services/logger.dart';

part 'navigation_state.dart';

final NavigationService _navigationService = locator<NavigationService>();

class LayerMoodle {
  LayerMoodle(this.polygons);
  List<Polyline> polygons = <Polyline>[];
}

class NavigationCubit extends BaseCubit<NavigationState, List<Work>> {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;
  final helperFunctions = HelperFunctions();
  final GpsBloc gpsBloc;

  CurrentUserLocationEntity? currentLocation;

  NavigationCubit(
      this._databaseRepository, this._locationRepository, this.gpsBloc)
      : super(const NavigationState(status: NavigationStatus.initial), []);

  Future<void> getAllWorksByWorkcode(String workcode) async {
    if (isBusy) return;
    try {
      await run(() async {
        emit(state.copyWith(
            status: NavigationStatus.loading,
            mapController: MapController(),
            carouselController: CarouselController()));

        emit(await _getAllWorksByWorkcode(workcode));
      });
    } catch (error, stackTrace) {
      emit(state.copyWith(
          status: NavigationStatus.failure, error: error.toString()));
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  LatLng getPosition(LngLat lngLat) {
    double lat = lngLat.lat;
    double long = lngLat.lng;
    if (long > 180.0) long = 180.0;
    return LatLng(lat, long);
  }

  LatLng getLatLngFromString(String latitude, String longitude) {
    return LatLng(double.parse(latitude), double.parse(longitude));
  }

  LatLng getLatLngFromWorksData(List<Work> works, int index) {
    return LatLng(double.parse(works[index].latitude!),
        double.parse(works[index].longitude!));
  }

  Future<NavigationState> _getAllWorksByWorkcode(String workcode) async {
    try {
      final worksDatabase =
          await _databaseRepository.findAllWorksByWorkcode(workcode);

      var currentLocation = gpsBloc.state.lastKnownLocation;

      var works = <Work>[];
      var markers = <Marker>[];
      var layer = <PolylineLayer>[];
      var kWorkList = <LatLng>[];
      var polylines = <Polyline>[];
      var model = <LayerMoodle>[];
      var carouselData = <Map>[];

      return await Future.forEach(worksDatabase, (work) async {
        if (work.latitude != null && work.longitude != null) {
          if (work.hasCompleted != null && work.hasCompleted == 1) {
            work.color = 5;
          } else {
            work.color = 8;
          }
          await _databaseRepository.updateWork(work);
        }

        works.add(work);
      }).then((_) async {
        data = [];
        if (data.isEmpty) {
          data.addAll(works);
        }
        List<LngLat> waypoints = [];

        if (currentLocation != null) {
          markers.add(
            Marker(
                height: 25,
                width: 25,
                point:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                builder: (ctx) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child:
                        Stack(alignment: Alignment.center, children: <Widget>[
                      Image.asset('assets/icons/point.png',
                          color: Colors.purple),
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.white),
                    ]))),
          );
        }

        var warehouse =
            await _databaseRepository.findWarehouse(works.first.warehouseId!);

        if (warehouse != null) {
          markers.add(
            Marker(
                height: 25,
                width: 25,
                point: LatLng(double.parse(warehouse.latitude!),
                    double.parse(warehouse.longitude!)),
                builder: (ctx) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child:
                        Stack(alignment: Alignment.center, children: <Widget>[
                      Image.asset('assets/icons/point.png', color: Colors.blue),
                      Text(0.toString()),
                    ]))),
          );

          waypoints.add(LngLat(
              lng: double.parse(warehouse.longitude!),
              lat: double.parse(warehouse.latitude!)));
        }

        for (var index = 0; index < works.length; index++) {
          if (works[index].latitude != null &&
              works[index].longitude != null &&
              works[index].distance != null &&
              works[index].duration != null) {
            try {
              waypoints.add(LngLat(
                  lng: double.parse(works[index].longitude!),
                  lat: double.parse(works[index].latitude!)));
              markers.add(
                Marker(
                    height: 25,
                    width: 25,
                    point: getLatLngFromString(
                        works[index].latitude!, works[index].longitude!),
                    builder: (ctx) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          state.carouselController!.jumpToPage(index);
                        },
                        child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image.asset('assets/icons/point.png',
                                  color: Colors
                                      .primaries[works[index].color ?? 1]),
                              Text((index + 1).toString()),
                            ]))),
              );

              carouselData.add({
                'index': index,
                'distance': num.parse(works[index].distance!),
                'duration': num.parse(works[index].duration!),
              });
            } on FormatException catch (e, stackTrace) {
              emit(state.copyWith(
                  status: NavigationStatus.failure, error: e.message));
              await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            }
          }
        }

        try {
          final manager = OSRMManager()
            ..generatePath(
                "https://osrm.bexsoluciones.com", waypoints.toString());

          final road = await manager.getRoad(
            waypoints: waypoints,
            geometries: Geometries.geojson,
            steps: true,
            language: Languages.en,
          );

          List<LatLng> polylinesDatabase =
              await _databaseRepository.getPolylines(workcode);
          var polygons = Polyline(
              color:
                  Colors.primaries[Random().nextInt(Colors.primaries.length)],
              strokeWidth: 2,
              points: road.polyline!.map((e) => getPosition(e)).toList());

          if (polylinesDatabase.isNotEmpty) {
            polylines = [
              Polyline(
                  points: polylinesDatabase,
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  strokeWidth: 2),
            ];
          } else {
            _databaseRepository.insertPolylines(workcode, polygons.points);
            polylines = [
              Polyline(
                  points: polygons.points,
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  strokeWidth: 2),
            ];
          }
        } on FormatException catch (e, stackTrace) {
          await FirebaseCrashlytics.instance.recordError(e, stackTrace);
        }

        if (carouselData.isNotEmpty) {
          kWorkList = List<LatLng>.generate(
              carouselData.length,
              (index) =>
                  getLatLngFromWorksData(works, carouselData[index]['index']));
        }

        return state.copyWith(
            status: NavigationStatus.success,
            works: data,
            layer: layer,
            markers: markers,
            kWorkList: kWorkList,
            carouselData: carouselData,
            pageIndex: state.pageIndex,
            polylines: polylines,
            model: model);
      });
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      return state.copyWith(
          status: NavigationStatus.failure, error: e.toString());
    }
  }

  Future<void> getCurrentPosition(double zoom) async {
    var currentLocation = gpsBloc.state.lastKnownLocation;
    state.mapController!.move(
        LatLng(currentLocation!.latitude, currentLocation.longitude), zoom);
    emit(state.copyWith(status: NavigationStatus.success));
  }

  Future<void> createNote(LatLng? position) async {
    if (position == null) {
      var currentLocation = gpsBloc.state.lastKnownLocation;
      position = LatLng(currentLocation!.latitude, currentLocation.longitude);
    }
    _navigationService.goTo(AppRoutes.notes, arguments: position);
  }

  Future<void> moveController(int index, double zoom) async {
    if (isBusy) return;

    await run(() async {
      logDebugFine(headerNavigationLogger, data.length.toString());
      if (index >= 0 && index < data.length) {
        if (index > 0 && data[index - 1].color == 15) {
          if (data[index].hasCompleted != null &&
              data[index].hasCompleted == 0) {
            data[index - 1].color = 5;
          } else {
            data[index - 1].color = 8;
          }
        }

        if (index < data.length - 1 && data[index + 1].color == 15) {
          if (data[index].hasCompleted != null &&
              data[index].hasCompleted == 0) {
            data[index + 1].color = 5;
          } else {
            data[index + 1].color = 5;
          }
        }

        data[index].color = 15;

        final List<Future<void>> updateWorkFutures = [];

        if (index - 1 >= 0) {
          updateWorkFutures
              .add(_databaseRepository.updateWork(data[index - 1]));
        }

        if (index + 1 < data.length) {
          updateWorkFutures
              .add(_databaseRepository.updateWork(data[index + 1]));
        }

        updateWorkFutures.add(_databaseRepository.updateWork(data[index]));

        await Future.wait(updateWorkFutures).then((value) {
          logDebugFine(headerNavigationLogger, state.mapController.toString());
          logDebugFine(headerNavigationLogger, state.kWorkList.toString());

          state.mapController!.move(state.kWorkList![index], zoom);
          emit(state.copyWith(works: data));
        }).catchError((error) {
          logDebugFine(headerNavigationLogger, error.toString());
          emit(state.copyWith(
              status: NavigationStatus.failure, error: error.toString()));
        });
      } else {
        // Handle the case when 'index' is out of range.
        emit(state.copyWith(
            status: NavigationStatus.failure, error: 'Ocurrio un erroe'));
      }
    });
  }

  Future<void> showMaps(
    BuildContext context,
    Work work,
  ) async {
    currentLocation ??= await _locationRepository.getCurrentLocation();
    if (context.mounted) {
      helperFunctions.showMapDirection(context, work, currentLocation!);
    }
  }
}
