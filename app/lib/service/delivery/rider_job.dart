import 'dart:async';
import 'dart:developer';

import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryRiderJob {
  static StreamSubscription<QuerySnapshot>? _deliveryJobsSubscription;
  static StreamController<List<DeliveryJob>>? _deliveryJobsController;

  static Stream<List<DeliveryJob>> getDeliveryJobsStream() {
    _deliveryJobsController ??= StreamController<List<DeliveryJob>>.broadcast();

    // Listen to real-time updates from Firebase
    _deliveryJobsSubscription = FirebaseFirestore.instance
        .collection('delivery')
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            try {
              log(
                'Received ${snapshot.docs.length} pending delivery jobs from Firebase',
              );

              final deliveryJobs = snapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['delivery_id'] = doc.id;

                final delivery = Delivery.fromJson(data);

                return DeliveryJob(
                  deliveryId: delivery.deliveryId,
                  status: delivery.status,
                  sender: UserInfo(
                    userId: delivery.sendedId,
                    name: delivery.name,
                    imagesUrl: delivery.profileImageUrl,
                  ),
                  reciver: UserInfo(
                    userId: delivery.receivedId,
                    name: delivery.name,
                    imagesUrl: delivery.profileImageUrl,
                  ),
                  pickupAddress: AddressInfo(
                    addressId: delivery.pickupAddressId,
                    detail: "Pickup Address",
                    latitude: 0.0,
                    longtitude: 0.0,
                    createdAt: delivery.createdAt,
                    updatedAt: delivery.updatedAt,
                  ),
                  deliveryAddress: AddressInfo(
                    addressId: delivery.deliveryAddressId,
                    detail: "Delivery Address",
                    latitude: 0.0,
                    longtitude: 0.0,
                    createdAt: delivery.createdAt,
                    updatedAt: delivery.updatedAt,
                  ),
                  pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
                );
              }).toList();

              _deliveryJobsController?.add(deliveryJobs);
            } catch (e) {
              log('Error processing delivery jobs stream: $e');
              _deliveryJobsController?.addError(e);
            }
          },
          onError: (error) {
            log('Error in delivery jobs stream: $error');
            _deliveryJobsController?.addError(error);
          },
        );

    return _deliveryJobsController!.stream;
  }

  static Future<List<DeliveryJob>> getDeliveryJobs() async {
    try {
      log('Fetching pending delivery jobs...');

      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'delivery',
        where: {'status': 'pending'},
      );

      log('Retrieved ${response.length} pending deliveries');

      final deliveryJobs = response.map((doc) {
        final data = doc.data();
        if (data != null) {
          data['delivery_id'] = doc.id;
          final delivery = Delivery.fromJson(data);

          return DeliveryJob(
            deliveryId: delivery.deliveryId,
            status: delivery.status,
            sender: UserInfo(
              userId: delivery.sendedId,
              name: delivery.name,
              imagesUrl: delivery.profileImageUrl,
            ),
            reciver: UserInfo(
              userId: delivery.receivedId,
              name: delivery.name,
              imagesUrl: delivery.profileImageUrl,
            ),
            pickupAddress: AddressInfo(
              addressId: delivery.pickupAddressId,
              detail: "Pickup Address",
              latitude: 0.0,
              longtitude: 0.0,
              createdAt: delivery.createdAt,
              updatedAt: delivery.updatedAt,
            ),
            deliveryAddress: AddressInfo(
              addressId: delivery.deliveryAddressId,
              detail: "Delivery Address",
              latitude: 0.0,
              longtitude: 0.0,
              createdAt: delivery.createdAt,
              updatedAt: delivery.updatedAt,
            ),
            pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
          );
        }
        throw Exception('Document data is null for delivery: ${doc.id}');
      }).toList();

      return deliveryJobs;
    } catch (e) {
      log('Error getting delivery jobs: $e');
      return [];
    }
  }

  static void dispose() {
    log('Disposing delivery jobs stream');
    _deliveryJobsSubscription?.cancel();
    _deliveryJobsController?.close();
    _deliveryJobsSubscription = null;
    _deliveryJobsController = null;
  }
}
