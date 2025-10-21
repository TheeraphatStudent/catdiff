import 'dart:developer';
import 'package:app/pages/debug_map_muti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/pages/map_debug.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/card/rider_job.widget.dart';

class MockupMulti extends StatefulWidget {
  const MockupMulti({super.key});

  @override
  State<MockupMulti> createState() => _MockupMultiState();
}

class _MockupMultiState extends State<MockupMulti> {
  final List<DeliveryJob> _mockJobs = [
    DeliveryJob(
      deliveryId: 'CF-001',
      status: StatusType.pending,
      pickupPkgImagesUrl: [],
      pickupAddress: AddressInfo(
        addressId: 'A01',
        detail: '123 ถนนสุขุมวิท กรุงเทพฯ',
        latitude: 13.7563,
        longtitude: 100.5018,
        createdAt: '',
        updatedAt: '',
      ),
      deliveryAddress: AddressInfo(
        addressId: 'A02',
        detail: '456 ถ.ลาดพร้าว กรุงเทพฯ',
        latitude: 13.789,
        longtitude: 100.57,
        createdAt: '',
        updatedAt: '',
      ),
      sender: UserInfo(userId: 'U01', name: 'ร้านต้นไม้', imagesUrl: ''),
      reciver: UserInfo(userId: 'U02', name: 'คุณสมชาย', imagesUrl: ''),
    ),
    DeliveryJob(
      deliveryId: 'CF-002',
      status: StatusType.pending,
      pickupPkgImagesUrl: [],
      pickupAddress: AddressInfo(
        addressId: 'A03',
        detail: '88 ถ.พระราม 9 กรุงเทพฯ',
        latitude: 13.74,
        longtitude: 100.6,
        createdAt: '',
        updatedAt: '',
      ),
      deliveryAddress: AddressInfo(
        addressId: 'A04',
        detail: '99 ถ.จตุจักร กรุงเทพฯ',
        latitude: 13.81,
        longtitude: 100.55,
        createdAt: '',
        updatedAt: '',
      ),
      sender: UserInfo(userId: 'U03', name: 'Green Delivery', imagesUrl: ''),
      reciver: UserInfo(userId: 'U04', name: 'คุณมณี', imagesUrl: ''),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: const ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              // map
              child: const MapMulti(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _mockJobs.map((job) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DeliverJobItem(
                      deliveryJob: job,
                      isEditableField: false,
                      isShowingMap: true,
                      onCardTap: () {
                        log('Card tapped: ${job.deliveryId}');
                      },
                      onLocationTap: (address) {
                        log('Location tapped: ${address.detail}');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
