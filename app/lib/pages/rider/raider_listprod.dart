import 'package:app/config/share/app_data.dart';
import 'package:app/widget/button_raider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/widget/button_raider.dart';
import 'package:app/widget/profile_img.widget.dart';

class RiderListProd extends StatefulWidget {
  const RiderListProd({super.key});

  @override
  State<RiderListProd> createState() => _RiderListProdState();
}

class _RiderListProdState extends State<RiderListProd> {
  late Future<List<Delivery>> _pendingDeliveries;
  String statusMessage = ' ';
  int deliveryCount = 0;

  final AppData _appData = AppData();

  @override
  void initState() {
    super.initState();
    _pendingDeliveries = Future.value([]);
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final deliveries = await _pendingDeliveries;
    setState(() {
      deliveryCount = deliveries.length;
      if (deliveryCount == 0) {
        statusMessage = 'ไม่มีพัสดุจัดส่งหรือรอรับ';
      } else {
        statusMessage = 'มีพัสดุรอจัดส่ง $deliveryCount รายการ';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FutureBuilder<List<Delivery>>(
                        future: _pendingDeliveries,
                        builder: (context, snapshot) {
                          String displayName =
                              _appData.currentUser?.name ?? 'ผู้ใช้';
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            displayName =
                                snapshot.data!.first.name ??
                                _appData.currentUser?.name ??
                                'ผู้ใช้';
                          }
                          return Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<List<Delivery>>(
                        future: _pendingDeliveries,
                        builder: (context, snapshot) {
                          int count = snapshot.data?.length ?? 0;
                          statusMessage = 'มีพัสดุรอจัดส่ง $count รายการ';
                          return Text(
                            statusMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                FutureBuilder<List<Delivery>>(
                  future: _pendingDeliveries,
                  builder: (context, snapshot) {
                    String? profileImage = _appData.currentUser?.imagesUrl;

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      profileImage =
                          snapshot.data!.first.profileImageUrl ??
                          _appData.currentUser?.imagesUrl;
                    }
                    return ProfileWidgets.avatar(
                      isEdited: false,
                      imageUrl: profileImage,
                      size: ProfileSize.sm,
                      shape: ProfileShape.circular,
                      config: ProfileWidgetConfig.light,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Delivery>>(
        future: _pendingDeliveries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending deliveries'));
          }

          final deliveries = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: deliveries.length,
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              return RaidCard(documentId: delivery.deliveryId);
            },
          );
        },
      ),
    );
  }
}
