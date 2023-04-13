import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:location_repository/location_repository.dart';

//cubits
import '../base/base_cubit.dart';

//blocs


//domain
import '../../../domain/models/work.dart';
import '../../../domain/repositories/database_repository.dart';

//service
import '../../../locator.dart';
import '../../../services/storage.dart';

part 'navigation_state.dart';

final LocalStorageService _storageService = locator<LocalStorageService>();

class LayerMoodle {
  LayerMoodle(this.polygons);
  List<Polyline> polygons = <Polyline>[];
}

class NavigationCubit extends BaseCubit<NavigationState, List<Work>> {
  final DatabaseRepository _databaseRepository;
  final LocationRepository _locationRepository;

  CurrentUserLocationEntity? currentLocation;

  NavigationCubit(this._databaseRepository, this._locationRepository)
      : super(const NavigationLoading(), []);

  final mapController = MapController();
  final buttonCarouselController = CarouselController();
  var markers = <Marker>[];
  var carouselData = <Map>[];
  var model = <LayerMoodle>[];
  var layer = <PolylineLayer>[];
  var kWorksList = <LatLng>[];

  Future<void> getAllWorksByWorkcode(String workcode) async {
    if (isBusy) return;
    await run(() async {
      emit(await _getAllWorksByWorkcode(workcode));
    });
  }

  LatLng getPosition(List polygon) {
    double lat = polygon[1] + .0;
    double long = polygon[0] + .0;
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
    final worksDatabase =
        await _databaseRepository.findAllWorksByWorkcode(workcode);

    var works = <Work>[];

    currentLocation = await _locationRepository.getCurrentLocation();

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
      //TODO:: get warehouse

      //TODO::  get current position
      markers.add(
        Marker(
            height: 25,
            width: 25,
            point:
                LatLng(currentLocation!.latitude, currentLocation!.longitude),
            builder: (ctx) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Stack(alignment: Alignment.center, children: <Widget>[
                  Image.asset('assets/icons/point.png', color: Colors.blue),
                  const Icon(Icons.location_on, size: 14, color: Colors.white),
                ]))),
      );

      for (var index = 0; index < works.length; index++) {
        if (works[index].latitude != null &&
            works[index].longitude != null &&
            works[index].distance != null &&
            works[index].duration != null &&
            works[index].geometry != null) {
          try {
            var geometry = jsonDecode(works[index].geometry!);

            var layers = geometry['coordinates'] as List<dynamic>;

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
                      child:
                          Stack(alignment: Alignment.center, children: <Widget>[
                        Image.asset('assets/icons/point.png',
                            color: Colors.primaries[works[index].color ?? 1]),
                        Text((index + 1).toString()),
                      ]))),
            );

            var polygon = Polyline(
                color:
                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                strokeWidth: 2,
                points: layers.map((e) => getPosition(e)).toList());

            carouselData.add({
              'index': index,
              'distance': num.parse(works[index].distance!),
              'duration': num.parse(works[index].duration!),
              'geometry': geometry,
              'polygon': polygon
            });
          } on FormatException catch (e) {
            emit(NavigationFailed(error: e.message));
          }
        }
      }

      if (carouselData.isNotEmpty) {
        var polygons = List<Polyline>.generate(
            carouselData.length, (index) => carouselData[index]['polygon']);

        model.add(LayerMoodle(polygons));

        layer.addAll(model.map((layer) {
          return PolylineLayer(polylines: layer.polygons);
        }));

        // initialize map symbols in the same order as carousel widgets
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
          model: model);
    });
  }

  Future<void> getCurrentPosition(double zoom) async {
    currentLocation = await _locationRepository.getCurrentLocation();

    mapController.move(
        LatLng(currentLocation!.latitude, currentLocation!.longitude), zoom);

    emit(NavigationSuccess(
        works: data,
        mapController: mapController,
        buttonCarouselController: buttonCarouselController,
        layer: layer,
        markers: markers,
        kWorksList: kWorksList,
        carouselData: carouselData,
        pageIndex: state.pageIndex,
        model: model));
  }

  Future<void> moveController(int index, double zoom) async {
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

    Future.wait([
      _databaseRepository.updateWork(data[index - 1]),
      _databaseRepository.updateWork(data[index + 1]),
      _databaseRepository.updateWork(data[index])
    ]).then((value) {
      mapController.move(kWorksList[index], zoom);

      emit(NavigationSuccess(
          works: data,
          mapController: mapController,
          buttonCarouselController: buttonCarouselController,
          layer: layer,
          markers: markers,
          kWorksList: kWorksList,
          carouselData: carouselData,
          pageIndex: index,
          model: model));
    }).catchError((error) {
      emit(NavigationFailed(error: error.toString()));
    });
  }
}
