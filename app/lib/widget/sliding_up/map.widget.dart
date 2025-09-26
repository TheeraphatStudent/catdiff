import 'dart:developer';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/widget/button.widget.dart';
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
  final bool isOpened;
  final VoidCallback? onConfirmLocation;
  final VoidCallback? onModalClosed;

  const MapsLocationSelector({
    super.key,
    this.onOpenModal,
    this.onLocationSelected,
    this.onMapSearch,
    this.isShowingAction = false,
    this.isOpened = false,
    this.onConfirmLocation,
    this.onModalClosed,
  });

  @override
  State<MapsLocationSelector> createState() => _MapsLocationSelectorState();
}

class _MapsLocationSelectorState extends State<MapsLocationSelector> {
  final MapLocationController controller = Get.put(MapLocationController());
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  bool _isModalCurrentlyOpen = false;
  bool _hasProcessedOpenRequest = false;

  static const String googleApiKey = "AIzaSyCK3UAtqWx2NprxrJoLh0n5gDw3G_DpNdk";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(MapsLocationSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpened &&
        !oldWidget.isOpened &&
        !_isModalCurrentlyOpen &&
        !_hasProcessedOpenRequest) {
      _hasProcessedOpenRequest = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLocationModal();
      });
    }

    if (!widget.isOpened && oldWidget.isOpened) {
      _hasProcessedOpenRequest = false;
    }
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

  void _openLocationModal() {
    if (_isModalCurrentlyOpen) {
      return; // Prevent opening multiple modals
    }

    _isModalCurrentlyOpen = true;

    WoltModalSheet.show<LatLng?>(
          context: context,
          pageListBuilder: (modalSheetContext) {
            final textTheme = Theme.of(context).textTheme;
            return [_buildLocationSelectorPage(modalSheetContext, textTheme)];
          },
          modalTypeBuilder: (context) {
            final size = MediaQuery.sizeOf(context).width;
            if (size < _pageBreakpoint) {
              return const WoltBottomSheetType();
            } else {
              return const WoltDialogType();
            }
          },
          barrierDismissible: true,
          enableDrag: true,
          onModalDismissedWithBarrierTap: () {
            log('Closed modal sheet with barrier tap');
          },
        )
        .then((selectedLocation) {
          // Modal is now closed
          _isModalCurrentlyOpen = false;
          _hasProcessedOpenRequest = false;
          
          // Call the modal closed callback to unfocus input
          widget.onModalClosed?.call();

          if (selectedLocation != null) {
            log('Location selected: $selectedLocation');
            widget.onLocationSelected?.call(selectedLocation);
          }
        })
        .catchError((error) {
          // Handle any errors and reset state
          _isModalCurrentlyOpen = false;
          _hasProcessedOpenRequest = false;
          
          // Call the modal closed callback even on error
          widget.onModalClosed?.call();
          
          log('Modal error: $error');
        });
  }

  SliverWoltModalSheetPage _buildLocationSelectorPage(
    BuildContext modalSheetContext,
    TextTheme textTheme,
  ) {
    return SliverWoltModalSheetPage(
      // pageTitle: Text(widget.isOpened.toString()),
      // pageTitle: Padding(
      //   padding: const EdgeInsets.all(_pagePadding),
      //   child: Row(
      //     children: [
      //       ButtonActions(
      //         variant: ButtonVariant.danger,
      //         icon: Icons.arrow_back,
      //       ),
      //       SizedBox(width: 16),
      //       Expanded(
      //         child: GooglePlaceAutoCompleteTextField(
      //           textEditingController: _searchController,
      //           googleAPIKey: googleApiKey,
      //           inputDecoration: InputDecoration(
      //             hintText: 'ค้นหาที่อยู่',
      //             prefixIcon: Icon(Icons.search_sharp),
      //             filled: true,
      //             fillColor: Theme.of(
      //               context,
      //             ).colorScheme.surfaceVariant.withOpacity(0.5),
      //             border: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(12),
      //               borderSide: BorderSide.none,
      //             ),
      //             enabledBorder: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(12),
      //               borderSide: BorderSide.none,
      //             ),
      //             focusedBorder: OutlineInputBorder(
      //               borderRadius: BorderRadius.circular(12),
      //               borderSide: BorderSide(
      //                 color: Theme.of(context).colorScheme.primary,
      //                 width: 2,
      //               ),
      //             ),
      //             contentPadding: const EdgeInsets.symmetric(
      //               horizontal: 16,
      //               vertical: 16,
      //             ),
      //           ),
      //           debounceTime: 1000,
      //           countries: const ["th"],
      //           isLatLngRequired: true,
      //           getPlaceDetailWithLatLng: (Prediction prediction) {
      //             log('Place selected: ${prediction.description}');
      //             _onPlaceSelected(prediction);
      //           },
      //           itemClick: (Prediction prediction) {
      //             _searchController.text = prediction.description ?? '';
      //             _searchController.selection = TextSelection.fromPosition(
      //               TextPosition(offset: prediction.description?.length ?? 0),
      //             );
      //           },
      //           seperatedBuilder: const Divider(),
      //           containerHorizontalPadding: 0,
      //           itemBuilder: (context, index, Prediction prediction) {
      //             return Container(
      //               padding: const EdgeInsets.all(12),
      //               child: Row(
      //                 children: [
      //                   Icon(
      //                     Icons.location_on,
      //                     color: Theme.of(context).colorScheme.primary,
      //                     size: 20,
      //                   ),
      //                   const SizedBox(width: 12),
      //                   Expanded(
      //                     child: Column(
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         Text(
      //                           prediction.structuredFormatting?.mainText ?? '',
      //                           style: const TextStyle(
      //                             fontWeight: FontWeight.w500,
      //                             fontSize: 14,
      //                           ),
      //                         ),
      //                         if (prediction
      //                                 .structuredFormatting
      //                                 ?.secondaryText !=
      //                             null) ...[
      //                           const SizedBox(height: 2),
      //                           Text(
      //                             prediction
      //                                 .structuredFormatting!
      //                                 .secondaryText!,
      //                             style: TextStyle(
      //                               color: Colors.grey[600],
      //                               fontSize: 12,
      //                             ),
      //                           ),
      //                         ],
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             );
      //           },
      //         ),
      //       ),
      //       SizedBox(width: 16),
      //       ButtonActions(
      //         variant: ButtonVariant.primary,
      //         icon: Icons.arrow_forward,
      //       ),
      //     ],
      //   ),
      // ),

      // trailingNavBarWidget: IconButton(
      //   padding: const EdgeInsets.all(_pagePadding),
      //   icon: const Icon(Icons.close),
      //   onPressed: Navigator.of(modalSheetContext).pop,
      // ),
      // stickyActionBar: Padding(
      //   padding: const EdgeInsets.all(_pagePadding),
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Obx(
      //         () => Container(
      //           width: double.infinity,
      //           padding: const EdgeInsets.all(12),
      //           decoration: BoxDecoration(
      //             color: Theme.of(context).colorScheme.surfaceVariant,
      //             borderRadius: BorderRadius.circular(8),
      //           ),
      //           child: Text(
      //             controller.locationStatus.value,
      //             style: textTheme.bodyMedium,
      //             textAlign: TextAlign.center,
      //           ),
      //         ),
      //       ),
      //       const SizedBox(height: 8),
      //       Row(
      //         children: [
      //           Expanded(
      //             child: ElevatedButton(
      //               onPressed: _getCurrentLocation,
      //               child: SizedBox(
      //                 height: _buttonHeight,
      //                 child: Center(
      //                   child: Obx(
      //                     () => controller.isLoading.value
      //                         ? const Row(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: [
      //                               SizedBox(
      //                                 width: 20,
      //                                 height: 20,
      //                                 child: CircularProgressIndicator(
      //                                   strokeWidth: 2,
      //                                 ),
      //                               ),
      //                               SizedBox(width: 8),
      //                               Text('Loading...'),
      //                             ],
      //                           )
      //                         : const Row(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: [
      //                               Icon(Icons.my_location, size: 20),
      //                               SizedBox(width: 8),
      //                               Text('Current Location'),
      //                             ],
      //                           ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //           const SizedBox(width: 8),
      //           Expanded(
      //             child: Obx(
      //               () => ElevatedButton(
      //                 onPressed: controller.selectedLocation.value != null
      //                     ? () {
      //                         Navigator.of(
      //                           modalSheetContext,
      //                         ).pop(controller.selectedLocation.value);
      //                       }
      //                     : null,
      //                 child: const SizedBox(
      //                   height: _buttonHeight,
      //                   child: Center(
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         Icon(Icons.check, size: 20),
      //                         SizedBox(width: 8),
      //                         Text('Confirm'),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      mainContentSliversBuilder: (context) => [
        // Map section
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.black),
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
                            onMapCreated: (GoogleMapController mapController) {
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
              Padding(
                padding: const EdgeInsets.all(_pagePadding),
                child: Row(
                  children: [
                    ButtonActions(
                      variant: ButtonVariant.danger,
                      icon: Icons.arrow_back,
                      onPressed: () {
                        _isModalCurrentlyOpen = false;
                        _hasProcessedOpenRequest = false;
                        widget.onModalClosed?.call();
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GooglePlaceAutoCompleteTextField(
                        textEditingController: _searchController,
                        googleAPIKey: googleApiKey,
                        inputDecoration: InputDecoration(
                          hintText: 'ค้นหาที่อยู่',
                          prefixIcon: Icon(Icons.search_sharp),
                          filled: true,
                          // fillColor: Theme.of(
                          //   context,
                          // ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          fillColor: AppColors.primary4,
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
                          _searchController.selection =
                              TextSelection.fromPosition(
                                TextPosition(
                                  offset: prediction.description?.length ?? 0,
                                ),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prediction
                                                .structuredFormatting
                                                ?.mainText ??
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
                                            color: AppColors.primary4,
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
                    ),
                    SizedBox(width: 16),
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
                                  final selectedLocation =
                                      controller.selectedLocation.value;
                                  if (selectedLocation != null) {
                                    _isModalCurrentlyOpen = false;
                                    _hasProcessedOpenRequest = false;
                                    widget.onModalClosed?.call();
                                    widget.onLocationSelected?.call(
                                      selectedLocation,
                                    );
                                    Navigator.of(context).pop(selectedLocation);
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // const SliverPadding(
        //   padding: EdgeInsets.only(bottom: _bottomPaddingForButton),
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _openLocationModal,
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
