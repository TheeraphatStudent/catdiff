import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/types/delivery.dart';

class RaidCard extends StatefulWidget {
  final String documentId;

  const RaidCard({Key? key, required this.documentId}) : super(key: key);

  @override
  State<RaidCard> createState() => _RaidCardState();
}

class _RaidCardState extends State<RaidCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Delivery? delivery;
  bool isLoading = true;
  Future<void> fetchDeliveryData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('Delivery')
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        setState(() {
          delivery = Delivery.fromJson(doc.data()!);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDeliveryData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (delivery == null) {
      return const Center(child: Text("ไม่พบข้อมูลการจัดส่ง"));
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // รูปโปรไฟล์
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                delivery!.profileImageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // รายละเอียดใน card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        "# ${delivery!.status}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "รหัสที่อยู่จัดส่ง: ${delivery!.deliveryAddressId}",
                    // style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "รายละเอียดเพิ่มเติม: ${delivery!.name}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
