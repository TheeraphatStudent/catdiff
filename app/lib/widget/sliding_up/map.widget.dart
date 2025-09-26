import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
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
        'Selected: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
  }

  void updateMarker(LatLng location) {
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: const InfoWindow(title: 'Selected Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  void moveCamera(LatLng location) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 16.0),
      ),
    );
  }
}

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _buttonWidth = 200.0;
const double _pagePadding = 16.0;
const double _pageBreakpoint = 768.0;

class MapsLocationSelector extends StatefulWidget {
  final VoidCallback? onOpenModal;
  final Function(LatLng)? onLocationSelected;
  final Function(String)? onMapSearch;
  final bool isShowingAction;

  const MapsLocationSelector({
    super.key,
    this.onOpenModal,
    this.onLocationSelected,
    this.onMapSearch,
    this.isShowingAction = false,
  });

  @override
  State<MapsLocationSelector> createState() => _MapsLocationSelectorState();
}

class _MapsLocationSelectorState extends State<MapsLocationSelector> {
  final MapLocationController controller = Get.put(MapLocationController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  static const String googleApiKey = "AIzaSyCK3UAtqWx2NprxrJoLh0n5gDw3G_DpNdk";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
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

  void _onMapTapped(LatLng location) {
    controller.updateSelectedLocation(location);
    widget.onLocationSelected?.call(location);
  }

  void _onSearchPressed() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onMapSearch?.call(query);
      controller.locationStatus.value = 'Searching for: $query';
    }
  }

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

  SliverWoltModalSheetPage _buildLocationSelectorPage(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return SliverWoltModalSheetPage(
      pageTitle: Padding(
        padding: const EdgeInsets.all(_pagePadding),
        child: Text(
          'Select Location',
          style: textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      trailingNavBarWidget: IconButton(
        padding: const EdgeInsets.all(_pagePadding),
        icon: const Icon(Icons.close),
        onPressed: Navigator.of(modalSheetContext).pop,
      ),
      stickyActionBar: Padding(
        padding: const EdgeInsets.all(_pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.locationStatus.value,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: SizedBox(
                      height: _buttonHeight,
                      child: Center(
                        child: Obx(
                          () => controller.isLoading.value
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Loading...'),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.my_location, size: 20),
                                    SizedBox(width: 8),
                                    Text('Current Location'),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.selectedLocation.value != null
                          ? () {
                              Navigator.of(
                                modalSheetContext,
                              ).pop(controller.selectedLocation.value);
                            }
                          : null,
                      child: const SizedBox(
                        height: _buttonHeight,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20),
                              SizedBox(width: 8),
                              Text('Confirm'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      mainContentSliversBuilder: (context) => [
        // Search section with Google Places Autocomplete
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search Location', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _searchController,
                  googleAPIKey: googleApiKey,
                  inputDecoration: const InputDecoration(
                    hintText: 'Search for places...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  debounceTime: 800,
                  countries: const ["th", "us"], // Thailand and US
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
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
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
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Manual coordinates section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manual Coordinates', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lonController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _onLatLonSubmitted,
                      icon: const Icon(Icons.place),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Map section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Map View', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Obx(
                      () => controller.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target:
                                    controller.selectedLocation.value ??
                                    controller.currentLocation.value,
                                zoom: 15.0,
                              ),
                              onMapCreated:
                                  (GoogleMapController mapController) {
                                    controller.mapController = mapController;
                                  },
                              onTap: _onMapTapped,
                              markers: controller.markers,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Instructions section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Tap on the map to select a location'),
                  const Text('• Search for places using the search box'),
                  const Text('• Enter coordinates manually if needed'),
                  const Text('• Use current location button for GPS location'),
                ],
              ),
            ),
          ),
        ),

        // Bottom padding
        const SliverPadding(
          padding: EdgeInsets.only(bottom: _bottomPaddingForButton),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isShowingAction) ...[
          ElevatedButton(
            onPressed: widget.onOpenModal,
            child: const SizedBox(
              height: _buttonHeight,
              width: _buttonWidth,
              child: Center(child: Text('Open Modal')),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          onPressed: () {
            WoltModalSheet.show<LatLng?>(
              context: context,
              pageListBuilder: (modalSheetContext) {
                final textTheme = Theme.of(context).textTheme;
                return [
                  _buildLocationSelectorPage(modalSheetContext, textTheme),
                ];
              },
              modalTypeBuilder: (context) {
                final size = MediaQuery.sizeOf(context).width;
                if (size < _pageBreakpoint) {
                  return const WoltBottomSheetType();
                } else {
                  return const WoltDialogType();
                }
              },
              onModalDismissedWithBarrierTap: () {
                log('Closed modal sheet with barrier tap');
                Navigator.of(context).pop();
              },
            ).then((selectedLocation) {
              if (selectedLocation != null) {
                log('Location selected: $selectedLocation');
                Get.snackbar(
                  'Location Selected',
                  'Lat: ${selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.longitude.toStringAsFixed(6)}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              }
            });
          },
          child: const SizedBox(
            height: _buttonHeight,
            width: _buttonWidth,
            child: Center(child: Text('Select Location')),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }
}
