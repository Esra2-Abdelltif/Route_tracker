import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/model/location_info/lat_lng.dart';
import 'package:route_tracker/model/location_info/location.dart';
import 'package:route_tracker/model/location_info/location_info.dart';
import 'package:route_tracker/model/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/model/place_details_model/place_details_model.dart';
import 'package:route_tracker/model/routes_model/route.dart';
import 'package:route_tracker/model/routes_model/routes_model.dart';
import 'package:route_tracker/utils/service/google_maps_place_service.dart';
import 'package:route_tracker/utils/service/location_service.dart';
import 'package:route_tracker/utils/service/routes_service.dart';

class MapServices {
  PlacesService placesService = PlacesService();
  LocationService locationService = LocationService();
  RoutesService routesService = RoutesService();
  LatLng? currentLocation;
  Future<void> getPredictions({required String input, required String sesstionToken, required List<PlaceModel> places}) async {
    if (input.isNotEmpty) {
      var result = await placesService.getPredictions(
          sesstionToken: sesstionToken, input: input);

      places.clear();
      places.addAll(result);
    } else {
      places.clear();
    }
  }

  Future<RoutesModel> geRouteDataInfo({required LatLng desintation,}) async {

    LocationInfoModel origin = LocationInfoModel(
      location: LocationModel(
          latLng: LatLngModel(
            latitude: currentLocation!.latitude,
            longitude: currentLocation!.longitude,
          )),
    );
    LocationInfoModel destination = LocationInfoModel(
      location: LocationModel(
          latLng: LatLngModel(
            latitude: desintation.latitude,
            longitude: desintation.longitude,
          )),
    );
    RoutesModel routes = await routesService.fetchRoutes(origin: origin, destination: destination);
    return routes;
  }

  Future<List<LatLng>> getRouteData({required LatLng desintation,required  List<RouteModel> routes }) async {

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points = getDecodedRoute(polylinePoints, routes,);
    return points;
  }

  List<LatLng> getDecodedRoute(PolylinePoints polylinePoints, List<RouteModel> routes,) {
    List<PointLatLng> result = polylinePoints.decodePolyline(
      routes.first.polyline!.encodedPolyline!,
    );
   List<LatLng> points = result.map((e) => LatLng(e.latitude, e.longitude)).toList();
    return points;
  }

  void displayRoute(List<LatLng> points, {required Set<Polyline> polyLines, required GoogleMapController googleMapController}) {
    Polyline route = Polyline(
      color: Colors.green,
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

  void updateCurrentLocation(
      {required GoogleMapController googleMapController,
        required Set<Marker> markers,
        required Function onUpdatecurrentLocation}) async{
    var location = await locationService.getLocation();
    currentLocation = LatLng(location.latitude!, location.longitude!);
    Marker currentLocationMarker = Marker(
        markerId: const MarkerId("my location"),
        position: currentLocation!);
    CameraPosition cameraPosition =
    CameraPosition(target: currentLocation!, zoom: 20);
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    markers.add(currentLocationMarker);
    onUpdatecurrentLocation();
  }

  void updateRealTimeCurrentLocation(
      {required GoogleMapController googleMapController,
        required Function onUpdatecurrentLocation}) {
    locationService.getRealTimeLocationData((locationData) {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);

      CameraPosition myCurrentCameraPoistion = CameraPosition(
        target: currentLocation!,
        zoom: 20,
      );
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(myCurrentCameraPoistion));
       onUpdatecurrentLocation();
    });
  }

  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async {
    return await placesService.getPlaceDetails(placeId: placeId);
  }
}