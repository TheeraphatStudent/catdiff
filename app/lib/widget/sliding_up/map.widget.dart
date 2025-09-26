import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class LocationSelectorController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString locationStatus = 'กดที่บนแผนที่เพื่อเลือกตำแหน่ง'.obs;
}

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _buttonWidth = 200.0;
const double _pagePadding = 16.0;
const double _pageBreakpoint = 768.0;

class LocationSelectorPage extends StatefulWidget {
  final VoidCallback? onOpenSliding;
  final Function(LatLng)? onLocationSelected;
  final Function(String)? onMapSearch;

  final bool isOpenSliding;
  final bool isShowingAction;

  const LocationSelectorPage({
    super.key,
    this.onOpenSliding,
    this.onLocationSelected,
    this.onMapSearch,
    this.isOpenSliding = false,
    this.isShowingAction = false,
  });

  @override
  State<LocationSelectorPage> createState() => _LocationSelectorPageState();
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  final LocationSelectorController controller = Get.put(
    LocationSelectorController(),
  );
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  LatLng _currentLocation = const LatLng(16.2467, 103.2521);

  LatLng? _selectedLocation;

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

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentLocation;
        controller.locationStatus.value = 'Current location found';
        controller.isLoading.value = false;
      });

      widget.onLocationSelected?.call(_currentLocation);
      log('Location obtained successfully: $position');
    } catch (e) {
      log('Error getting location: $e');
      setState(() {
        _selectedLocation = _currentLocation;
        controller.locationStatus.value =
            'ใช้ตำแหน่งเริ่มต้น (ไม่สามารถเข้าถึง GPS)';
        controller.isLoading.value = false;
      });

      widget.onLocationSelected?.call(_currentLocation);
    }
  }

  void _onMapTapped(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
      controller.locationStatus.value =
          'Location selected: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    });
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

      setState(() {
        _selectedLocation = location;
        controller.locationStatus.value =
            'Manual location set: ${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
      });

      widget.onLocationSelected?.call(location);
    } catch (e) {
      setState(() {
        controller.locationStatus.value = 'Invalid coordinates entered';
      });
    }
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
            // Status text
            Container(
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
            const SizedBox(height: 8),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const SizedBox(
                      height: _buttonHeight,
                      child: Center(
                        child: Row(
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedLocation != null
                        ? () {
                            Navigator.of(
                              modalSheetContext,
                            ).pop(_selectedLocation);
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
              ],
            ),
          ],
        ),
      ),
      mainContentSliversBuilder: (context) => [
        // Search section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(_pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Search Location', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Enter location name...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _onSearchPressed(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _onSearchPressed,
                      icon: const Icon(Icons.search),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
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
                        keyboardType: TextInputType.number,
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
                        keyboardType: TextInputType.number,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Map View', style: textTheme.titleMedium),
                    if (widget.onOpenSliding != null)
                      TextButton.icon(
                        onPressed: widget.onOpenSliding,
                        icon: const Icon(Icons.open_in_full, size: 16),
                        label: const Text('Full Screen'),
                      ),
                  ],
                ),
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
                    child: controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  _selectedLocation ?? _currentLocation,
                              initialZoom: 15.0,
                              onTap: _onMapTapped,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'Catdiff/1.0',
                                maxNativeZoom: 18,
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40.0,
                                      height: 40.0,
                                      point: _selectedLocation!,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.location_pin,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              RichAttributionWidget(
                                attributions: [
                                  TextSourceAttribution(
                                    '© OpenStreetMap contributors',
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ],
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
    return Builder(
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isShowingAction) ...[
              ElevatedButton(
                onPressed: () {
                  if (widget.onOpenSliding != null) {
                    widget.onOpenSliding!();
                  }
                },
                child: SizedBox(
                  height: _buttonHeight,
                  width: _buttonWidth,
                  child: Center(
                    child: Text(
                      widget.isOpenSliding ? 'Close Sliding' : 'Open Sliding',
                    ),
                  ),
                ),
              ),
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
      },
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
