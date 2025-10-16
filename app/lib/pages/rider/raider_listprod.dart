import 'package:app/widget/button_raider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/types/delivery.dart';
import 'package:app/widget/button_raider.dart';

// ============================================
// Pending Deliveries Page (ใช้ RaidCard)
// ============================================
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

  @override
  void initState() {
    super.initState();
    _pendingDeliveries = _fetchPendingDeliveries();
  }

  Future<List<Delivery>> _fetchPendingDeliveries() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Delivery')
          .where('status', isEqualTo: 'pending')
          .get();
      await FirebaseFirestore.instance.collection('Delivery').add({
        "profileImageUrl":
            "https://cdn-icons-png.flaticon.com/512/194/194938.png",
        "name": "สมชาย ขนส่งดี",
        "status": "pending",
        "delivery_id": "DEL001",
        "pickup_address_id": "ADDR001",
        "delivery_address_id": "ADDR002",
        "pickup_pkg_images_url": [
          "https://cdn-icons-png.flaticon.com/512/679/679821.png",
        ],
        "created_at": "2025-10-16T10:00:00Z",
        "updated_at": "2025-10-16T10:00:00Z",
        "delivered_at": null,
        "pickup_at": "2025-10-16T09:30:00Z",
        "sended_pkg_detail": "กล่องพัสดุขนาดกลาง",
        "sended_pkg_img_url":
            "https://cdn-icons-png.flaticon.com/512/679/679821.png",
      });
      final deliveries = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['delivery_id'] = doc.id;
        return Delivery.fromJson(data);
      }).toList();

      return deliveries;
    } catch (e) {
      print('Error fetching deliveries: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.userName ?? 'Theeraphat chueanokkhum',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ไลน์บัญชีสำหรับผู้ส่งพัสดุ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
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
