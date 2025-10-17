import 'package:app/widget/button_raider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/types/delivery.dart';
import 'package:app/widget/button_raider.dart';
import 'package:app/widget/profile_img.widget.dart';

class PendingDeliveriesPage extends StatefulWidget {
  final String? userProfileImage;
  final String? userName;
  const PendingDeliveriesPage({Key? key, this.userProfileImage, this.userName})
    : super(key: key);

  @override
  State<PendingDeliveriesPage> createState() => _PendingDeliveriesPageState();
}

class _PendingDeliveriesPageState extends State<PendingDeliveriesPage> {
  late Future<List<Delivery>> _pendingDeliveries;
  String statusMessage = ' ';
  int deliveryCount = 0;
  @override
  void initState() {
    super.initState();
    // _pendingDeliveries = _fetchPendingDeliveries();
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

  // Future<List<Delivery>> _fetchPendingDeliveries() async {
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('Delivery')
  //         .where('status', isEqualTo: 'pending')
  //         .get();
  //     await FirebaseFirestore.instance.collection('Delivery').add({
  //       "profileImageUrl":
  //           "https://cdn-icons-png.flaticon.com/512/194/194938.png",
  //       "name": "bobo",
  //       "status": "pending",
  //       "delivery_id": "DEL001",
  //       "pickup_address_id": "ADDR001",
  //       "delivery_address_id": "ADDR002",
  //       "pickup_pkg_images_url": [
  //         "https://cdn-icons-png.flaticon.com/512/679/679821.png",
  //       ],
  //       "created_at": "2025-10-16T10:00:00Z",
  //       "updated_at": "2025-10-16T10:00:00Z",
  //       "delivered_at": null,
  //       "pickup_at": "2025-10-16T09:30:00Z",
  //       "sended_pkg_detail": "กล่องพัสดุขนาดกลาง",
  //       "sended_pkg_img_url":
  //           "https://cdn-icons-png.flaticon.com/512/679/679821.png",
  //     });
  //     final deliveries = querySnapshot.docs.map((doc) {
  //       final data = doc.data();
  //       data['delivery_id'] = doc.id;
  //       return Delivery.fromJson(data);
  //     }).toList();

  //     return deliveries;
  //   } catch (e) {
  //     print('Error fetching deliveries: $e');
  //     rethrow;
  //   }
  // }
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
                          String displayName = widget.userName ?? 'ผู้ใช้';
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            displayName =
                                snapshot.data!.first.name ??
                                widget.userName ??
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
                          int count = snapshot.data!.length;
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
                    String? profileImage = widget.userProfileImage;

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      profileImage =
                          snapshot.data!.first.profileImageUrl ??
                          widget.userProfileImage;
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
