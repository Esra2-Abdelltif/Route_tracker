
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/utils/service/location_service.dart';


class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late LocationService locationService;
  late CameraPosition cameraPosition;
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  @override
  void initState() {
    cameraPosition=const CameraPosition(target: LatLng(0,0),);
    locationService=LocationService();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      markers:markers,
      zoomControlsEnabled: false,
      mapType: MapType.hybrid,
      initialCameraPosition: cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        googleMapController=controller;
        updateCurrentLocation();
      },
    );
  }

  void updateCurrentLocation()async {
    try {
      var location=await locationService.getLocation();
      LatLng currentPosition=LatLng(location.latitude!, location.longitude!);
       Marker currentLocationMarker=Marker(markerId: const MarkerId("my location"),position: currentPosition);
      CameraPosition cameraPosition= CameraPosition(
        target:currentPosition,
        zoom: 100

      );
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      markers.add(currentLocationMarker);
      setState(() {

      });
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO :
    } catch (e) {
      // TODO:
    }
  }
}
