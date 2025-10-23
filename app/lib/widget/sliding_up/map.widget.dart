import 'dart:async';
import 'dart:developer';
import 'package:app/config/secret/api_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/service/map/routes_service.dart';
import 'package:app/widget/map/map_placeholder.dart';
import 'package:app/widget/map/map_selection_result.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class MapLocationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString locationStatus = 'กดที่บนแผนที่เพื่อเลือกตำแหน่ง'.obs;
  final Rx<LatLng> currentLocation = const LatLng(16.2467, 103.2521).obs;
  final Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  final RxSet<Marker> markers = <Marker>{}.obs;

  GoogleMapController? mapController;

  void updateSelectedLocation(LatLng location) {
    selectedLocation.value = location;
    updateMarker(location);
    locationStatus.value =
        'ตำแหน่งที่เลือก: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  void updateMarker(LatLng location) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'เลือกที่อยู่'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void moveCamera(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 18.0),
      ),
    );
  }
}

class MapsLocationSelector extends StatefulWidget {
  final VoidCallback? onOpenModal;
  final Function(LatLng)? onLocationSelected;
  final Function(String)? onMapSearch;
  final Function(LatLng, String)? onAddressSelected;

  final bool isShowingAction;
  final bool isOpened;
  final VoidCallback? onConfirmLocation;
  final VoidCallback? onModalClosed;
  final MapRouteDistanceStrategy distanceStrategy;
  final MapRoutesClientConfig? routesClientConfig;

  final double? latitude;
  final double? longitude;

  const MapsLocationSelector({
    super.key,

    this.onOpenModal,
    this.onModalClosed,
    this.isShowingAction = false,
    this.isOpened = false,

    this.onLocationSelected,
    this.onMapSearch,
    this.onAddressSelected,
    this.onConfirmLocation,
    this.distanceStrategy = MapRouteDistanceStrategy.distanceMatrixPreferred,
    this.routesClientConfig,

    this.latitude,
    this.longitude,
  });

  @override
  State<MapsLocationSelector> createState() => _MapsLocationSelectorState();
}

class _MapsLocationSelectorState extends State<MapsLocationSelector> {
  late MapLocationController controller;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  bool _isModalCurrentlyOpen = false;
  bool _hasProcessedOpenRequest = false;
  bool _hasRequestedLocation = false;

  final MapRoutesService _routesService = const MapRoutesService();
  double? _routeDistanceMeters;
  Duration? _routeDuration;
  RouteDistanceSource? _routeDistanceSource;
  bool _isRouting = false;
  String? _routeError;
  int _routeRequestId = 0;
  Worker? _selectedLocationWorker;
  Worker? _currentLocationWorker;
  Timer? _routeRefreshTimer;

  ApiData _apiData = ApiData();

  @override
  void initState() {
    super.initState();

    try {
      controller = Get.find<MapLocationController>();
    } catch (e) {
      controller = Get.put(MapLocationController());
    }

    _selectedLocationWorker = ever<LatLng?>(
      controller.selectedLocation,
      (_) => unawaited(_refreshRoutePreview()),
    );
    _currentLocationWorker = ever<LatLng>(
      controller.currentLocation,
      (_) => unawaited(_refreshRoutePreview()),
    );

    // Initialize with provided coordinates if available
    if (widget.latitude != null && widget.longitude != null) {
      final providedLocation = LatLng(widget.latitude!, widget.longitude!);
      controller.selectedLocation.value = providedLocation;
      controller.currentLocation.value = providedLocation;
      controller.updateSelectedLocation(providedLocation);
      log(
        "Initialized map with provided coordinates: ${widget.latitude}, ${widget.longitude}",
      );
    }

    if (widget.isOpened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_refreshRoutePreview());
        _ensureLocationRequested();
        _scheduleModalOpen();
      });
    } else if (widget.isShowingAction) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureLocationRequested();
      });
    }
  }

  @override
  void didUpdateWidget(MapsLocationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update map location if coordinates changed
    if ((widget.latitude != oldWidget.latitude ||
            widget.longitude != oldWidget.longitude) &&
        widget.latitude != null &&
        widget.longitude != null) {
      final newLocation = LatLng(widget.latitude!, widget.longitude!);
      controller.selectedLocation.value = newLocation;
      controller.currentLocation.value = newLocation;
      controller.updateSelectedLocation(newLocation);
      log(
        "Updated map coordinates to: ${widget.latitude}, ${widget.longitude}",
      );
    }

    if (widget.isOpened && !oldWidget.isOpened && !_isModalCurrentlyOpen) {
      _scheduleModalOpen();
    }

    if (!widget.isOpened && oldWidget.isOpened) {
      _hasProcessedOpenRequest = false;
    }

    if (widget.distanceStrategy != oldWidget.distanceStrategy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_refreshRoutePreview());
      });
    }
  }

  void _ensureLocationRequested() {
    if (_hasRequestedLocation) {
      return;
    }
    _hasRequestedLocation = true;

    // Only request GPS location if no coordinates are provided
    if (widget.latitude == null || widget.longitude == null) {
      unawaited(_getCurrentLocation());
    }
  }

  void _scheduleModalOpen() {
    if (!mounted || _isModalCurrentlyOpen || _hasProcessedOpenRequest) {
      return;
    }

    _hasProcessedOpenRequest = true;
    _ensureLocationRequested();

    // Modal opening is now handled by SlidingTemplate
  }

  Future<void> _getCurrentLocation() async {
    // If coordinates are already provided, don't override with GPS
    if (widget.latitude != null && widget.longitude != null) {
      final providedLocation = LatLng(widget.latitude!, widget.longitude!);
      controller.updateSelectedLocation(providedLocation);
      controller.locationStatus.value = 'ใช้ตำแหน่งที่กำหนด';
      controller.isLoading.value = false;
      widget.onLocationSelected?.call(providedLocation);
      log(
        'Using provided coordinates: ${widget.latitude}, ${widget.longitude}',
      );
      return;
    }

    controller.isLoading.value = true;
    controller.locationStatus.value = 'กำลังหาตำแหน่งปัจจุบัน...';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        controller.locationStatus.value = 'การเข้าถึงตำแหน่งถูกปฏิเสธ';
        controller.isLoading.value = false;
        log('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          controller.locationStatus.value = 'การเข้าถึงตำแหน่งถูกปฏิเสธ';
          controller.isLoading.value = false;
          log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        controller.locationStatus.value =
            'ขออภัย ไม่สามารถหาตำแหน่งปัจจุบันได้';
        controller.isLoading.value = false;
        log('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      controller.currentLocation.value = location;
      controller.updateSelectedLocation(location);
      controller.moveCamera(location);

      controller.locationStatus.value = 'พบตำแหน่งปัจจุบัน';
      controller.isLoading.value = false;

      widget.onLocationSelected?.call(location);
      log('Location obtained successfully: $position');
    } catch (e) {
      log('Error getting location: $e');
      controller.updateSelectedLocation(controller.currentLocation.value);
      controller.locationStatus.value =
          'ใช้ตำแหน่งเริ่มต้น (ไม่สามารถเข้าถึง GPS)';
      controller.isLoading.value = false;

      widget.onLocationSelected?.call(controller.currentLocation.value);
    }
  }

  Future<void> _refreshRoutePreview() async {
    if (!mounted) {
      return;
    }

    _routeRefreshTimer?.cancel();

    _routeRefreshTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _performRouteRefresh();
      }
    });
  }

  Future<void> _performRouteRefresh() async {
    if (!mounted) {
      return;
    }

    final LatLng? destination = controller.selectedLocation.value;
    final LatLng origin = controller.currentLocation.value;

    if (destination == null) {
      if (_routeDistanceMeters == null &&
          _routeDuration == null &&
          _routeError == null &&
          !_isRouting) {
        return;
      }
      setState(() {
        _routeDistanceMeters = null;
        _routeDuration = null;
        _routeDistanceSource = null;
        _routeError = null;
        _isRouting = false;
      });
      return;
    }

    final int requestId = ++_routeRequestId;

    setState(() {
      _isRouting = true;
      _routeError = null;
    });

    try {
      final MapRouteResult result = await _routesService.computeRoute(
        origin: origin,
        destination: destination,
        apiKey: _apiData.apiKey,
        travelMode: MapRouteTravelMode.driving,
        distanceStrategy: widget.distanceStrategy,
        clientConfig: widget.routesClientConfig,
      );

      if (!mounted || requestId != _routeRequestId) {
        return;
      }

      final double computedDistance =
          result.distanceMeters ??
          Geolocator.distanceBetween(
            origin.latitude,
            origin.longitude,
            destination.latitude,
            destination.longitude,
          );

      setState(() {
        _routeDistanceMeters = computedDistance;
        _routeDuration = result.duration;
        _routeDistanceSource = result.distanceSource;
        _routeError = null;
        _isRouting = false;
      });
    } on RouteComputationException catch (error) {
      if (!mounted || requestId != _routeRequestId) {
        return;
      }

      setState(() {
        _routeDistanceMeters = Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        );
        _routeDuration = null;
        _routeDistanceSource = RouteDistanceSource.geometry;
        _routeError = error.message;
        _isRouting = false;
      });
    } catch (_) {
      if (!mounted || requestId != _routeRequestId) {
        return;
      }

      setState(() {
        _routeDistanceMeters = Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          destination.latitude,
          destination.longitude,
        );
        _routeDuration = null;
        _routeDistanceSource = RouteDistanceSource.geometry;
        _routeError = 'Unable to compute route';
        _isRouting = false;
      });
    }
  }

  String _formatRouteDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    final double kilometers = meters / 1000;
    return kilometers >= 10
        ? '${kilometers.toStringAsFixed(1)} km'
        : '${kilometers.toStringAsFixed(2)} km';
  }

  // ignore: unused_element
  void _onLatLonSubmitted() {
    try {
      final lat = double.parse(_latController.text);
      final lon = double.parse(_lonController.text);
      final location = LatLng(lat, lon);

      controller.updateSelectedLocation(location);
      controller.moveCamera(location);
      controller.locationStatus.value =
          'Manual location set: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';

      widget.onLocationSelected?.call(location);
    } catch (e) {
      controller.locationStatus.value = 'Invalid coordinates entered';
    }
  }

  void _onPlaceSelected(Prediction prediction) {
    if (prediction.lat != null && prediction.lng != null) {
      final location = LatLng(
        double.parse(prediction.lat!),
        double.parse(prediction.lng!),
      );
      controller.updateSelectedLocation(location);
      controller.moveCamera(location);
      widget.onLocationSelected?.call(location);
    }
    _searchController.text = prediction.description ?? '';
  }

  Widget _buildMapContent() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Obx(() {
          final bool isLoading = controller.isLoading.value;
          final LatLng currentLocation = controller.currentLocation.value;
          final LatLng? selectedLocation = controller.selectedLocation.value;

          return Stack(
            children: [
              MapPlaceholder(
                mode: MapPlaceholderMode.selector,
                initialSelection: selectedLocation,
                initialUserLocation: currentLocation,
                initialPosition: selectedLocation ?? currentLocation,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                showMyLocation: true,
                showMyLocationButton: false,
                enableLiveLocation: false,
                mapPadding: const EdgeInsets.only(bottom: 140),
                onSelectionChanged: (MapSelectionResult result) {
                  final LatLng position = result.position;
                  controller.updateSelectedLocation(position);
                  if (result.address != null && result.address!.isNotEmpty) {
                    controller.locationStatus.value = result.address!;
                  }

                  widget.onLocationSelected?.call(position);
                },
              ),
              if (isLoading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlidingTemplate(
      isOpened: widget.isOpened,
      onModalClosed: () {
        _isModalCurrentlyOpen = false;
        _hasProcessedOpenRequest = false;
        widget.onModalClosed?.call();
      },
      isShowingAction: widget.isShowingAction,
      actionButtonText: 'Select Location',
      actionButtonIcon: Icons.location_on,
      customTopBar: Center(child: Text("เลือกที่อยู่")),
      topBarHeight: 84,
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ButtonActions(
                variant: ButtonVariant.danger,
                icon: Icons.arrow_back,
                onPressed: () {
                  widget.onModalClosed?.call();
                },
              ),
              SizedBox(width: 8),
              Expanded(
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: _searchController,
                  googleAPIKey: _apiData.apiKey,
                  inputDecoration: InputDecoration(
                    hintText: 'ค้นหาที่อยู่',
                    prefixIcon: Icon(Icons.search_sharp),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary1,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  debounceTime: 1000,
                  countries: const ["th"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    log('Place selected: ${prediction.description}');
                    _onPlaceSelected(prediction);
                  },
                  itemClick: (Prediction prediction) {
                    _searchController.text = prediction.description ?? '';
                    _searchController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description?.length ?? 0),
                    );
                  },
                  seperatedBuilder: const Divider(),
                  containerHorizontalPadding: 0,
                  itemBuilder: (context, index, Prediction prediction) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.primary1,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prediction.structuredFormatting?.mainText ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (prediction
                                          .structuredFormatting
                                          ?.secondaryText !=
                                      null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      prediction
                                          .structuredFormatting!
                                          .secondaryText!,
                                      style: TextStyle(
                                        color: AppColors.primary2,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              ButtonActions(
                variant: ButtonVariant.outline,
                icon: Icons.location_on,
                onPressed: _getCurrentLocation,
              ),
              SizedBox(width: 8),
              Obx(
                () => Opacity(
                  opacity: controller.selectedLocation.value != null
                      ? 1.0
                      : 0.5,
                  child: ButtonActions(
                    variant: ButtonVariant.primary,
                    icon: Icons.arrow_forward,
                    onPressed: controller.selectedLocation.value != null
                        ? () {
                            if (controller.selectedLocation.value != null) {
                              widget.onLocationSelected?.call(
                                controller.selectedLocation.value!,
                              );
                              widget.onAddressSelected?.call(
                                controller.selectedLocation.value!,
                                controller.locationStatus.value,
                              );
                              widget.onModalClosed?.call();
                            }
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildMapContent(),
      ],
    );
  }

  @override
  void dispose() {
    _routeRefreshTimer?.cancel();
    _selectedLocationWorker?.dispose();
    _currentLocationWorker?.dispose();
    _searchController.dispose();
    _latController.dispose();
    _lonController.dispose();

    try {
      if (Get.isRegistered<MapLocationController>()) {
        Get.delete<MapLocationController>();
      }
    } catch (e) {
      log(e.toString());
    }

    super.dispose();
  }
}
