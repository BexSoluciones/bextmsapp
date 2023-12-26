import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

//core
import 'package:bexdeliveries/core/helpers/index.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

//cubits
import '../../blocs/gps/gps_bloc.dart';
import '../base/base_cubit.dart';

//blocs

//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';
import 'package:location_repository/location_repository.dart';

part 'navigation_state.dart';

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
      : super(NavigationLoading(), []);

  final mapController = MapController();
  final buttonCarouselController = CarouselController();
  var markers = <Marker>[];
  var carouselData = <Map>[];
  List<Polyline> Polylines = [];
  var model = <LayerMoodle>[];
  var layer = <PolylineLayer>[];
  var kWorksList = <LatLng>[];

  Future<void> getAllWorksByWorkcode(String workcode) async {
    if (isBusy) return;
    emit(NavigationLoading());
    try {
      await run(() async {
        emit(await _getAllWorksByWorkcode(workcode));
      });
    } catch (error, stackTrace) {
      emit(NavigationFailed(error: error.toString()));
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

      var works = <Work>[];

      var currentLocation = gpsBloc.state.lastKnownLocation;

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

        markers.add(
          Marker(
              height: 25,
              width: 25,
              point:
                  LatLng(currentLocation!.latitude, currentLocation.longitude),
              builder: (ctx) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Stack(alignment: Alignment.center, children: <Widget>[
                    Image.asset('assets/icons/point.png', color: Colors.purple),
                    const Icon(Icons.location_on,
                        size: 14, color: Colors.white),
                  ]))),
        );

        var warehouse =
            await _databaseRepository.findWarehouse(works.first.warehouseId!);

        if (warehouse != null) {
          markers.add(
            Marker(
                height: 25,
                width: 25,
                point: LatLng(double.parse(warehouse!.latitude!),
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
              works[index].duration != null
          ) {
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
                          buttonCarouselController.jumpToPage(index);
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
              emit(NavigationFailed(error: e.message));
              await FirebaseCrashlytics.instance.recordError(e, stackTrace);
            }
          }
        }

        final manager = OSRMManager()
          ..generatePath(
              "https://osrm.bexsoluciones.com", waypoints.toString());
        final road = await manager.getRoad(
          waypoints: waypoints,
          geometries: Geometries.geojson,
          steps: true,
          language: Languages.en,
        );

        List<LatLng> polylines =
            await _databaseRepository.getPolylines(workcode);
        var polygons = Polyline(
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
            strokeWidth: 2,
            points: road.polyline!.map((e) => getPosition(e)).toList());

        if (polylines.isNotEmpty) {
          Polylines = [
            Polyline(
                points: polylines,
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                strokeWidth: 2),
          ];
        } else {
          _databaseRepository.insertPolylines(workcode, polygons.points);
          Polylines = [
            Polyline(
                points: polygons.points,
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                strokeWidth: 2),
          ];
        }

        if (carouselData.isNotEmpty) {
          kWorksList = List<LatLng>.generate(
              carouselData.length,
              (index) =>
                  getLatLngFromWorksData(works, carouselData[index]['index']));
        }

        return NavigationSuccess(
            works: data,
            mapController: mapController,
            buttonCarouselController: buttonCarouselController,
            layer: layer,
            markers: markers,
            kWorksList: kWorksList,
            carouselData: carouselData,
            pageIndex: state.pageIndex,
            Polylines: Polylines,
            model: model);
      });
    } catch (e, stackTrace) {
      print(e);
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);
      return NavigationFailed(error: e.toString());
    }
  }

  Future<void> getCurrentPosition(double zoom) async {
    var currentLocation = gpsBloc.state.lastKnownLocation;

    mapController.move(
        LatLng(currentLocation!.latitude, currentLocation.longitude), zoom);

    emit(NavigationSuccess(
        works: data,
        mapController: mapController,
        buttonCarouselController: buttonCarouselController,
        layer: layer,
        markers: markers,
        kWorksList: kWorksList,
        Polylines: Polylines,
        carouselData: carouselData,
        pageIndex: state.pageIndex,
        model: model));
  }

  Future<void> moveController(int index, double zoom) async {
    if (index >= 0 && index < data.length) {
      if (index > 0 && data[index - 1].color == 15) {
        if (data[index].hasCompleted != null && data[index].hasCompleted == 0) {
          data[index - 1].color = 5;
        } else {
          data[index - 1].color = 8;
        }
      }

      if (index < data.length - 1 && data[index + 1].color == 15) {
        if (data[index].hasCompleted != null && data[index].hasCompleted == 0) {
          data[index + 1].color = 5;
        } else {
          data[index + 1].color = 5;
        }
      }

      data[index].color = 15;

      final List<Future<void>> updateWorkFutures = [];

      if (index - 1 >= 0) {
        updateWorkFutures.add(_databaseRepository.updateWork(data[index - 1]));
      }

      if (index + 1 < data.length) {
        updateWorkFutures.add(_databaseRepository.updateWork(data[index + 1]));
      }

      updateWorkFutures.add(_databaseRepository.updateWork(data[index]));

      Future.wait(updateWorkFutures).then((value) {
        mapController.move(kWorksList[index], zoom);

        emit(NavigationSuccess(
          works: data,
          mapController: mapController,
          buttonCarouselController: buttonCarouselController,
          layer: layer,
          markers: markers,
          kWorksList: kWorksList,
          carouselData: carouselData,
          Polylines: Polylines,
          pageIndex: index,
          model: model,
        ));
      }).catchError((error) {
        emit(NavigationFailed(error: error.toString()));
      });
    } else {
      // Handle the case when 'index' is out of range.
    }
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

  Future<void> clean() async {
    carouselData.clear();
    Polylines.clear();
    layer.clear();
    markers = [];
    kWorksList.clear();
    model.clear();
  }
}
