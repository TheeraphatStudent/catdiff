import 'package:app/layout/MainLayout.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/status.dart';
import 'package:app/widget/card/sender_job.widget.dart';
import 'package:app/types/delivery/sender_showcard.dart';
import 'package:flutter/material.dart';
import 'package:app/config/theme/app_theme.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});
  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  int? selectedIndex;

  final List<SenderJob> senderJobs = [
    SenderJob(
      sendedName: "แมวเป้า",
      pickupPkgImagesUrl: [
        "https://storage.googleapis.com/lottocat_bucket/uploads/c8230831-13f0-4ea6-b6a8-a5ca9d081e5b.jpeg",
      ],
      pickupAddressId: "addr_001",
      deliveryAddressId: "addr_002",
      sendedPkgImgUrl: "",
      sendedPkgDetail: "",
      pickupAddress: Address(
        addressId: "addr_001",
        detail: "Test pickup address detail info!",
        latitude: 13.7563,
        longtitude: 100.5018,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
      deliveryAddress: Address(
        addressId: "addr_002",
        detail: "41, Kham Riang, Kantharawichai District, Maha Sarakham 44150",
        latitude: 18.7883,
        longtitude: 98.9853,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
    ),
    SenderJob(
      sendedName: "แมวเป้า",
      pickupPkgImagesUrl: [
        "https://storage.googleapis.com/lottocat_bucket/uploads/c8230831-13f0-4ea6-b6a8-a5ca9d081e5b.jpeg",
      ],
      pickupAddressId: "addr_001",
      deliveryAddressId: "addr_002",
      sendedPkgImgUrl: "",
      sendedPkgDetail: "",
      pickupAddress: Address(
        addressId: "addr_001",
        detail: "Test pickup address detail info!",
        latitude: 13.7563,
        longtitude: 100.5018,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
      deliveryAddress: Address(
        addressId: "addr_002",
        detail: "41, Kham Riang, Kantharawichai District, Maha Sarakham 44150",
        latitude: 18.7883,
        longtitude: 98.9853,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
    ),
    SenderJob(
      sendedName: "แมวเป้า",
      pickupPkgImagesUrl: [
        "https://storage.googleapis.com/lottocat_bucket/uploads/c8230831-13f0-4ea6-b6a8-a5ca9d081e5b.jpeg",
      ],
      pickupAddressId: "addr_001",
      deliveryAddressId: "addr_002",
      sendedPkgImgUrl: "",
      sendedPkgDetail: "",
      pickupAddress: Address(
        addressId: "addr_001",
        detail: "Test pickup address detail info!",
        latitude: 13.7563,
        longtitude: 100.5018,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
      deliveryAddress: Address(
        addressId: "addr_002",
        detail: "41, Kham Riang, Kantharawichai District, Maha Sarakham 44150",
        latitude: 18.7883,
        longtitude: 98.9853,
        createdAt: "2024-10-18T10:00:00Z",
        updatedAt: "2024-10-18T10:00:00Z",
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Column(
        children: List.generate(
          senderJobs.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Opacity(
              opacity: selectedIndex == null || selectedIndex == index
                  ? 1.0
                  : 0.4,
              child: SenderJobItem(
                senderJob: senderJobs[index],
                isSelected: selectedIndex == index,
                backgroundColor: selectedIndex == index
                    ? AppColors.primary2
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
