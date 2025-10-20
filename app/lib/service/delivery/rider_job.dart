import 'dart:async';
import 'dart:developer';

import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/user.dart';
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

    _deliveryJobsSubscription = FirebaseFirestore.instance
        .collection('delivery')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) async {
            try {
              log(
                'Received ${snapshot.docs.length} pending delivery jobs from Firebase',
              );

              final deliveryJobs = snapshot.docs.map((doc) async {
                final data = doc.data() as Map<String, dynamic>;
                data['delivery_id'] = doc.id;

                final delivery = Delivery.fromJson(data);

                final AddressInfo pickupAddress =
                    await AddressService.getAddressById(
                      delivery.pickupAddressId,
                    );

                final AddressInfo deliveryAddress =
                    await AddressService.getAddressById(
                      delivery.deliveryAddressId,
                    );

                // ==========================

                final senderUser = await AuthService.getUserById(
                  userId: delivery.sendedId,
                );

                final receiverUser = await AuthService.getUserById(
                  userId: delivery.receivedId,
                );

                // ==========================

                return DeliveryJob(
                  deliveryId: delivery.deliveryId,
                  status: delivery.status,
                  sender: UserInfo(
                    userId: delivery.sendedId,
                    name: senderUser?.name ?? '???',
                    imagesUrl: senderUser?.imagesUrl ?? '???',
                  ),
                  reciver: UserInfo(
                    userId: delivery.receivedId,
                    name: receiverUser?.name ?? '???',
                    imagesUrl: delivery.profileImageUrl,
                  ),
                  pickupAddress: pickupAddress,
                  deliveryAddress: deliveryAddress,
                  pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
                );
              }).toList();

              final response = await Future.wait(deliveryJobs);

              _deliveryJobsController?.add(response);
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
