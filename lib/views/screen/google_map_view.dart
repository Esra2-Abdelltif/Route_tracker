import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracker/model/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:route_tracker/model/routes_model/routes_model.dart';
import 'package:route_tracker/utils/service/location_service.dart';
import 'package:route_tracker/utils/service/map_services.dart';
import 'package:route_tracker/views/widgets/custom_list_view.dart';
import 'package:route_tracker/views/widgets/custom_text_field.dart';
import 'package:route_tracker/views/widgets/floating_action_button_widget.dart';
import 'package:route_tracker/views/widgets/route_details_info_widget.dart';
import 'package:uuid/uuid.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  late MapServices mapServices;
  late CameraPosition cameraPosition;
  late GoogleMapController googleMapController;
  late TextEditingController textEditingController;
  late Uuid uuid;
  String? sesstionToken;

  Set<Marker> markers = {};
  Set<Polyline> polyLines = {};
  List<PlaceModel> places = [];

  late LatLng desintation;
  Timer? debounce;

  late RoutesModel routesModel;

  @override
  void initState() {
    uuid = const Uuid();
    mapServices = MapServices();
    routesModel = RoutesModel();
    cameraPosition = const CameraPosition(
      target: LatLng(0, 0),
    );
    textEditingController = TextEditingController();
    fetchPredictions();
    super.initState();
  }

  void fetchPredictions() {
    textEditingController.addListener(() {
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      }
      debounce = Timer(const Duration(milliseconds: 100), () async {
        sesstionToken ??= uuid.v4();
        await mapServices.getPredictions(
            input: textEditingController.text,
            sesstionToken: sesstionToken!,
            places: places);
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(children: [
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
                    mapServices: mapServices,
                    onPlaceSelect: (placeDetailsModel) async {
                      onPlaceSelect();
                      desintation = LatLng(
                          placeDetailsModel.geometry!.location!.lat!,
                          placeDetailsModel.geometry!.location!.lng!);
                      routesModel = await mapServices.geRouteDataInfo(
                        desintation: desintation,
                      );
                      var points = await mapServices.getRouteData(
                          desintation: desintation,
                          routes: routesModel.routes!);

                      mapServices.displayRoute(points,
                          polyLines: polyLines,
                          googleMapController: googleMapController);

                      setState(() {});
                    },
                  ),
                ],
              )),
        ]),
      ),
      bottomSheet: routesModel.routes == null
          ? null
          : RouteDetailsInfoWidget(
              duration: routesModel.routes!.first.duration!,
              distanceMeters: routesModel.routes!.first.distanceMeters!,
              cancelRouteFun: () {
                polyLines = {};
                routesModel.routes = null;
                setState(() {});
                updateCurrentLocation();
              },
              startRouteFun: () {
                updateCurrentLocation();
                setState(() {});
              },
            ),
      floatingActionButton: routesModel.routes == null
          ? FloatingActionButtonWidget(
              getCurrentLocationFun: () {
                updateCurrentLocation();
              },
            )
          : null,
    );
  }

  void onPlaceSelect() {
    FocusManager.instance.primaryFocus?.unfocus();
    textEditingController.clear();
    places.clear();
    sesstionToken = null;
    setState(() {});
  }

  void updateCurrentLocation() {
    try {
      mapServices.updateCurrentLocation(
          onUpdatecurrentLocation: () {
            setState(() {});
          },
          googleMapController: googleMapController,
          markers: markers);
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO :
    } catch (e) {
      // TODO:
    }
  }
}
//Create Text Form Field
//Listen To Text Field
//Search Places
//Display Results
