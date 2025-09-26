import 'dart:developer';

import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/header_card.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:app/widget/stepper.widget.dart';
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
              onFocus: () {
                setState(() {
                  _isMapModalOpened = true;
                });
                Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() {
                    _isMapModalOpened = false;
                  });
                });
              },
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
            ),
          ],
        ),
      ),
    );
  }
}
