import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/model/location_info/lat_lng.dart';
import 'package:route_tracker/model/location_info/location.dart';
import 'package:route_tracker/model/location_info/location_info.dart';
import 'package:route_tracker/model/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/model/routes_model/routes_model.dart';
import 'package:route_tracker/utils/service/google_maps_place_service.dart';
import 'package:route_tracker/utils/service/location_service.dart';
import 'package:route_tracker/utils/service/routes_service.dart';
import 'package:route_tracker/views/widgets/custom_list_view.dart';
import 'package:route_tracker/views/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late LocationService locationService;
  late CameraPosition cameraPosition;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late GoogleMapsPlacesService googleMapsPlacesService;
  late Uuid uuid;
  Set<Marker> markers = {};
  String? sesstionToken;
  List<PlaceModel> places = [];
  late LatLng currentLocationPosition;
  late RoutesService routesService;
  late LatLng desintation;
  Set<Polyline> polyLines = {};
  @override
  void initState() {
    routesService = RoutesService();
    googleMapsPlacesService = GoogleMapsPlacesService();
    uuid = const Uuid();
    cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    locationService = LocationService();
    textEditingController = TextEditingController();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() async {
      sesstionToken ??= uuid.v4();

      if (textEditingController.text.isNotEmpty) {
        var result = await googleMapsPlacesService.getPredictions(
            input: textEditingController.text, sesstionToken: sesstionToken!);
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        sesstionToken = null;
        places.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        polylines: polyLines,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.hybrid,
        initialCameraPosition: cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
          updateCurrentLocation();
        },
      ),
      Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
                onPlaceSelect: onPlaceSelect,
              ),
              const SizedBox(
                height: 16,
              ),
              CustomListView(
                places: places,
                googleMapsPlacesService: googleMapsPlacesService,
                onPlaceSelect: (placeDetailsModel) async{
                  onPlaceSelect();
                  desintation = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!);
                  var points = await   getRouteData();
                  displayRoute(points, polyLines: polyLines, googleMapController: googleMapController);
                  setState(() {});
                },
              )
            ],
          ))
    ]);
  }

  void onPlaceSelect() {
    textEditingController.clear();
    places.clear();
    sesstionToken = null;
    setState(() {});
  }

  void updateCurrentLocation() async {
    try {
      var location = await locationService.getLocation();
      currentLocationPosition = LatLng(location.latitude!, location.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId("my location"),
          position: currentLocationPosition);
      CameraPosition cameraPosition =
          CameraPosition(target: currentLocationPosition, zoom: 20);
      googleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      markers.add(currentLocationMarker);
      setState(() {});
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO :
    } catch (e) {
      // TODO:
    }
  }

  Future<List<LatLng>> getRouteData() async{
    LocationInfoModel origin = LocationInfoModel(location: LocationModel(latLng: LatLngModel(latitude:currentLocationPosition.latitude,longitude:currentLocationPosition.longitude )));
    LocationInfoModel destination = LocationInfoModel(location: LocationModel(latLng: LatLngModel(latitude:desintation.latitude,longitude:desintation.longitude )));
    PolylinePoints polylinePoints = PolylinePoints();
    RoutesModel route =await routesService.fetchRoutes(origin: origin, destination: destination);
    List<PointLatLng> result = polylinePoints.decodePolyline(route.routes!.first.polyline!.encodedPolyline!);
    print(result);
    List<LatLng> points =
    result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoute(List<LatLng> points, {required Set<Polyline> polyLines, required GoogleMapController googleMapController}) {
    Polyline route = Polyline(
      color: Colors.blue,
      width: 5,
      polylineId: const PolylineId('route'),
      points: points,
    );

    polyLines.add(route);

    LatLngBounds bounds = getLatLngBounds(points);
     googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 32));
  }
  LatLngBounds getLatLngBounds(List<LatLng> points) {
    var southWestLatitude = points.first.latitude;
    var southWestLongitude = points.first.longitude;
    var northEastLatitude = points.first.latitude;
    var northEastLongitude = points.first.longitude;

    for (var point in points) {
      southWestLatitude = min(southWestLatitude, point.latitude);
      southWestLongitude = min(southWestLongitude, point.longitude);
      northEastLatitude = max(northEastLatitude, point.latitude);
      northEastLongitude = max(northEastLongitude, point.longitude);
    }

    return LatLngBounds(
        southwest: LatLng(southWestLatitude, southWestLongitude),
        northeast: LatLng(northEastLatitude, northEastLongitude));
  }
//Create Text Form Field
//Listen To Text Field
//Search Places
//Display Results
}
