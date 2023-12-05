import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:map_launcher/map_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../domain/models/work.dart';
import '../../../../../../locator.dart';
import '../../../../../../services/navigation.dart';
import '../../../../../../utils/constants/colors.dart';





final NavigationService _navigationService = locator<NavigationService>();


class LayerModle {
  LayerModle(this.polygons);
  List<flutter_map.Polyline> polygons = <flutter_map.Polyline>[];
}

class MaxBoxScreen extends StatefulWidget {
  MaxBoxScreen({Key? key, required this.workcode, required this.latitud, required this.longitud,required this.latitudCliente, required this.longituduCliente, required this.customer, required this.nit}) : super(key: key);
  final String workcode;
  double?  latitud;
  double? longitud;
  double? latitudCliente;
  double? longituduCliente;
  String? customer;
  String? nit;

  @override
  State<MaxBoxScreen> createState() => _MaxBoxScreenState();
}

class _MaxBoxScreenState extends State<MaxBoxScreen> {

  // map related
  late flutter_map.MapController mapController;
  var layer = <flutter_map.PolylineLayer>[];
  final markers = <flutter_map.Marker>[];
  var works = <Work>[];
  List<Map> carouselData = [];

  //handle
  bool isLoading = false;

  // Carousel related
  CarouselController buttonCarouselController = CarouselController();
  int pageIndex = 0;
  bool accessed = false;
  List<Widget> carouselItems = [];
  // Create your stream
  final _streamController = StreamController<double>();
  Stream<double> get onZoomChanged => _streamController.stream;
  double zoom = 15.0;

  LatLng getPosition(List polygon) {
    double lat = polygon[1] + .0;
    double long = polygon[0] + .0;
    if (long > 180.0) long = 180.0;
    return LatLng(lat, long);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    mapController = flutter_map.MapController();
    onZoomChanged.listen((event) {
      setState(() {
        zoom = event;
      });
    });
    getWorks().then((value) {
      initialize();
    });
  }


  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> getWorks() async {
    setState(() {
      isLoading = true;
    });


    setState(() {
      works = [];
    });
  }

  void initialize() async {
    //TODO:: fix clients without geolocation
    setState(() {
      isLoading = true;
    });


    if (widget.latitudCliente !=0.0 && widget.longituduCliente!=0.0) {


      markers.add(flutter_map.Marker(
          height: 25,
          width: 25,
          point:  LatLng(widget.latitud!, widget.longitud!),
          builder: (ctx) =>
              Stack(alignment: Alignment.center, children: <Widget>[
                Image.asset('assets/icons/point.png', color: Colors.blue),
                const Icon(Icons.location_on, size: 14, color: Colors.white),
              ])));

      markers.add(flutter_map.Marker(
          height: 35,
          width: 35,
          point: LatLng(
              widget.latitudCliente!, widget.longituduCliente!),
          builder: (ctx) =>
              Stack(alignment: Alignment.center, children: <Widget>[
                Image.asset('assets/icons/arrived.png'),
              ])));
    }else{
      Container();
    }

    setState(() {
      isLoading = false;
    });
  }

  void onMapEvent(flutter_map.MapEvent mapEvent) {
    if (mapEvent is! flutter_map.MapEventMove &&
        mapEvent is! flutter_map.MapEventRotate) {
      debugPrint(mapEvent.toString());
    }
  }

  Future<void> showMap(String client, double lat, double lng) async {
    final availableMaps = await MapLauncher.installedMaps;

    await availableMaps.first.showMarker(
      coords: Coords(lat, lng),
      title: client,
    );
  }

  @override
  Widget build(BuildContext context) {


    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
            onPressed: (!isLoading) ? () => _navigationService.goBack() : () {},
          ),
          flexibleSpace: PreferredSize(
            preferredSize: const Size.fromHeight(500),
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEA5A2B), Color(0xE6E84118)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'CLIENTE: ${widget.customer}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'NIT:${widget.nit}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
            ),
          )
              : Stack(
            children: [
              widget.longituduCliente!=0.0 && widget.latitudCliente!=0.0 && widget.longitud!=0.0 && widget.latitud!=0.0
                  ? SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 1.0,
                  child: flutter_map.FlutterMap(
                    mapController: mapController,
                    options: flutter_map.MapOptions(
                        keepAlive: true,
                        center: markers[1].point,
                        maxZoom: 18,
                        zoom: 15.0,
                        onPositionChanged: (position, hasGesture) {
                          // Fill your stream when your position changes
                          final zoom = position.zoom;
                          if (zoom != null) {
                            _streamController.sink.add(zoom);
                          }
                        },
                        onTap: (position, location) {
                          //TODO:: notes for transporter to route
                          try {
                            print(location.latitude);
                            print(location.longitude);
                          } catch (e) {
                            print(e);
                          }
                        }),
                    children: [
                      flutter_map.TileLayer(
                        urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token={accessToken}',
                        additionalOptions: const {'accessToken':'sk.eyJ1IjoiYmV4aXRhY29sMiIsImEiOiJjbDVnc3ltaGYwMm16M21wZ21rMXg1OWd6In0.Dwtkt3r6itc0gCXDQ4CVxg'},
                      ),
                      ...layer,
                      flutter_map.MarkerLayer(
                        markers: markers,
                      ),
                      flutter_map.PolylineLayer(
                        polylines: [
                          flutter_map.Polyline(
                            points: [
                              LatLng(widget.latitud!, widget.longitud!),
                              LatLng(widget.latitudCliente!, widget.longituduCliente!),
                            ],
                            color: Colors.transparent,
                            strokeWidth: 1.0,
                          ),
                        ],
                      ),
                    ],
                  ))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
