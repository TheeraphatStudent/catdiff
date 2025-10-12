import 'package:app/layout/MainLayout.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final TextEditingController _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();

  bool _isOpenedLocationSelector = false;
  LatLng? _selectedLatLng;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _addressFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _addressFocusNode.removeListener(_handleFocusChange);
    _addressFocusNode.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_addressFocusNode.hasFocus && !_isOpenedLocationSelector) {
      setState(() => _isOpenedLocationSelector = true);
    }
  }

  void _handleLocationSelected(LatLng location) {
    String? resolvedAddress;
    if (Get.isRegistered<MapLocationController>()) {
      resolvedAddress = Get.find<MapLocationController>().locationStatus.value;
    }

    _addressController.text =
        (resolvedAddress != null && resolvedAddress.isNotEmpty)
        ? resolvedAddress
        : '${location.latitude.toStringAsFixed(6)}, '
              '${location.longitude.toStringAsFixed(6)}';

    setState(() {
      _selectedLatLng = location;
      _selectedAddress = (resolvedAddress != null && resolvedAddress.isNotEmpty)
          ? resolvedAddress
          : _addressController.text;
    });
  }

  void _handleModalClosed() {
    if (!mounted) {
      return;
    }
    setState(() => _isOpenedLocationSelector = false);
    _addressFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> details = <Widget>[];

    if (_selectedAddress != null && _selectedAddress!.isNotEmpty) {
      details.add(Text('Address: $_selectedAddress'));
    }
    if (_selectedLatLng != null) {
      details.add(
        Text(
          'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(6)}, '
          'Lon: ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
        ),
      );
    }

    return MainLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputField(
            hintText: 'ตำแหน่งที่อยู่',
            controller: _addressController,
            focusNode: _addressFocusNode,
            onFocus: _handleFocusChange,
          ),
          // const SizedBox(height: 16),
          // ...details,
          // if (details.isNotEmpty) const SizedBox(height: 16),
          MapsLocationSelector(
            isOpened: _isOpenedLocationSelector,
            isShowingAction: false,
            onLocationSelected: _handleLocationSelected,
            onModalClosed: _handleModalClosed,
          ),
        ],
      ),
    );
  }
}
