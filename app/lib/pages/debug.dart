import 'dart:developer';

import 'package:app/layout/MainLayout.dart';
import 'package:app/service/upload/storage_test.dart.bal';
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

  // Firebase Storage diagnostic state
  bool _isRunningDiagnostic = false;
  Map<String, dynamic>? _diagnosticResults;
  String? _diagnosticError;

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

  Future<void> _runStorageDiagnostic() async {
    setState(() {
      _isRunningDiagnostic = true;
      _diagnosticResults = null;
      _diagnosticError = null;
    });

    try {
      log('Starting Firebase Storage diagnostic...');
      final results = await StorageTest.runFullDiagnostic();

      setState(() {
        _diagnosticResults = results;
        _diagnosticError = results['error'];
      });

      log('Diagnostic completed: ${results['success']}');
    } catch (e) {
      log('Diagnostic failed: $e');
      setState(() {
        _diagnosticError = e.toString();
      });
    } finally {
      setState(() {
        _isRunningDiagnostic = false;
      });
    }
  }

  Widget _buildDiagnosticSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        const Text(
          '🔍 Firebase Storage Diagnostic',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        ButtonActions(
          text: _isRunningDiagnostic ? 'กำลังตรวจสอบ...' : 'เริ่มตรวจสอบ Firebase Storage',
          variant: ButtonVariant.primary,
          onPressed: _isRunningDiagnostic ? null : _runStorageDiagnostic,
        ),

        const SizedBox(height: 16),

        if (_diagnosticError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ Diagnostic Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _diagnosticError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),

        if (_diagnosticResults != null) ...[
          if (_diagnosticResults!['success'] == true) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: const Text(
                '✅ Firebase Storage Diagnostic Passed!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: const Text(
                '⚠️ Firebase Storage Issues Detected',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          _buildDiagnosticResults(),
        ],
      ],
    );
  }

  Widget _buildDiagnosticResults() {
    if (_diagnosticResults == null) return const SizedBox.shrink();

    final results = _diagnosticResults!['results'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Test Results:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          _buildTestResult('Firebase Init', results['firebase_init']),
          _buildTestResult('Storage Instance', results['storage_instance']),
          _buildTestResult('Bucket Access', results['bucket_access']),
          _buildTestResult('Path Creation', results['path_creation']),
          _buildTestResult('Simple Upload', results['simple_upload']),
        ],
      ),
    );
  }

  Widget _buildTestResult(String testName, dynamic result) {
    if (result == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            Text('$testName: Not run', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final success = result['success'] == true;
    final error = result['error'];
    final errorType = result['error_type'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '$testName: ${success ? 'PASS' : 'FAIL'}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (error != null && !success) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Error: $error',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (errorType != null)
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  'Type: $errorType',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          if (result['project_id'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Project: ${result['project_id']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          if (result['bucket'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                'Bucket: ${result['bucket']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: true,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Testing Section
            const Text(
              '🗺️ Map Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                ButtonActions(
                  variant: ButtonVariant.danger,
                  icon: Icons.arrow_back,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    type: InputType.fill,
                    hintText: 'ค้นหาที่อยู่',
                    validate: true,
                    errorText: 'Error',
                    suffixIcon: const Icon(Icons.search_sharp),
                  ),
                ),
                const SizedBox(width: 16),
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

            // Firebase Storage Diagnostic Section
            _buildDiagnosticSection(),
          ],
        ),
      ),
    );
  }
}
