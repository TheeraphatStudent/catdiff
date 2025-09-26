import 'dart:developer';

import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  bool _isMapModalOpened = false;
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listener to focus node to detect focus changes
    _locationFocusNode.addListener(() {
      if (_locationFocusNode.hasFocus) {
        _openMapModal();
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _openMapModal() {
    setState(() {
      _isMapModalOpened = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isMapModalOpened = false;
        });
      }
    });
  }

  void _onModalClosed() {
    // Unfocus the specific input field when modal closes
    _locationFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                ButtonActions(
                  variant: ButtonVariant.danger,
                  icon: Icons.arrow_back,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    type: InputType.fill,
                    hintText: 'ค้นหาที่อยู่',
                    validate: true,
                    errorText: 'Error',
                    suffixIcon: const Icon(Icons.search_sharp),
                  ),
                ),
                SizedBox(width: 16),
                ButtonActions(
                  variant: ButtonVariant.primary,
                  icon: Icons.arrow_forward,
                ),
              ],
            ),

            InputField(
              label: 'ที่อยู่เริ่มต้น (สำหรับรับสินค้า):',
              type: InputType.fill,
              hintText: 'เลือกที่อยู่ในแมพ',
              validate: true,
              errorText: 'Error',
              suffixIcon: const Icon(Icons.location_on),
              controller: _locationController,
              focusNode: _locationFocusNode,
            ),

            MapsLocationSelector(
              isOpened: _isMapModalOpened,
              onLocationSelected: (location) {
                log("Location selected: $location");
                _locationController.text =
                    'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
              },
              onConfirmLocation: () {
                final selectedLocation = Get.find<MapLocationController>().selectedLocation.value;
                if (selectedLocation != null) {
                  log("Location confirmed: $selectedLocation");
                  _locationController.text =
                      'Lat: ${selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${selectedLocation.longitude.toStringAsFixed(6)}';
                }
              },
              onModalClosed: _onModalClosed,
            ),
          ],
        ),
      ),
    );
  }
}
