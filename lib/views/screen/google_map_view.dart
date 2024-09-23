import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/model/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/utils/service/google_maps_place_service.dart';
import 'package:route_tracker/utils/service/location_service.dart';
import 'package:route_tracker/views/widgets/custom_list_view.dart';
import 'package:route_tracker/views/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';
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

  @override
  void initState() {
    googleMapsPlacesService = GoogleMapsPlacesService();
    uuid=const Uuid();
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
        var result = await googleMapsPlacesService.getPredictions(input: textEditingController.text,sesstionToken: sesstionToken!);
        places.clear();
        places.addAll(result);
        setState(() {});
      } else {
        sesstionToken=null;
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
    print("3333333#####${sesstionToken}");
    return Stack(children: [
      GoogleMap(
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
                onPlaceSelect: (placeDetails){
                  onPlaceSelect();
                },
              )
            ],
          ))
    ]);
  }
  void  onPlaceSelect(){
      textEditingController.clear();
      places.clear();
      sesstionToken = null;
      setState(() {});
  }

  void updateCurrentLocation() async {
    try {
      var location = await locationService.getLocation();
      LatLng currentPosition = LatLng(location.latitude!, location.longitude!);
      Marker currentLocationMarker = Marker(
          markerId: const MarkerId("my location"), position: currentPosition);
      CameraPosition cameraPosition =
          CameraPosition(target: currentPosition, zoom: 20);
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

//Create Text Form Field
//Listen To Text Field
//Search Places
//Display Results
}
