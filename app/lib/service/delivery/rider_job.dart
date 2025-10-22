import 'dart:async';
import 'dart:developer';

import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/user.dart';
import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/service/helper/time.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

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
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  data['delivery_id'] = doc.id;

                  final delivery = Delivery.fromJson(data);

                  // Get pickup address with validation
                  final AddressInfo pickupAddress =
                      (delivery.pickupAddressId.isNotEmpty)
                      ? await AddressService.getAddressById(
                          delivery.pickupAddressId,
                        )
                      : AddressInfo(
                          addressId: '',
                          latitude: 0.0,
                          longtitude: 0.0,
                          detail: 'ไม่พบข้อมูลที่อยู่รับสินค้า',
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        );

                  // Get delivery address with validation
                  final AddressInfo deliveryAddress =
                      (delivery.deliveryAddressId.isNotEmpty)
                      ? await AddressService.getAddressById(
                          delivery.deliveryAddressId,
                        )
                      : AddressInfo(
                          addressId: '',
                          latitude: 0.0,
                          longtitude: 0.0,
                          detail: 'ไม่พบข้อมูลที่อยู่จัดส่ง',
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        );

                  // ==========================

                  // Get sender user with validation
                  final senderUser = (delivery.sendedId.isNotEmpty)
                      ? await AuthService.getUserById(userId: delivery.sendedId)
                      : null;

                  // Get receiver user with validation
                  final receiverUser = (delivery.receivedId.isNotEmpty)
                      ? await AuthService.getUserById(
                          userId: delivery.receivedId,
                        )
                      : null;

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
                    sendedPkgDetail: delivery.sendedPkgDetail,
                  );
                } catch (e) {
                  log('Error processing individual delivery job ${doc.id}: $e');
                  // Return null for failed jobs, will be filtered out later
                  return null;
                }
              }).toList();

              final response = await Future.wait(deliveryJobs);

              // Filter out null values (failed jobs) and add to controller
              final validJobs = response.whereType<DeliveryJob>().toList();
              _deliveryJobsController?.add(validJobs);
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
              createdAt: delivery.createdAt ?? "",
              updatedAt: delivery.updatedAt,
            ),
            deliveryAddress: AddressInfo(
              addressId: delivery.deliveryAddressId,
              detail: "Delivery Address",
              latitude: 0.0,
              longtitude: 0.0,
              createdAt: delivery.createdAt ?? "",
              updatedAt: delivery.updatedAt,
            ),
            pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
            sendedPkgDetail: delivery.sendedPkgDetail,
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

  static Future<void> onWorkingDeliveryJob(DeliveryJob job) async {
    try {
      final delivery = Delivery(
        deliveryId: job.deliveryId,
        status: job.status,
        sendedId: job.sender.userId,
        receivedId: job.reciver.userId,
        pickupPkgImagesUrl: job.pickupPkgImagesUrl,
        updatedAt: TimeHelper.getDateNow(),
        riderInfo: null,
        profileImageUrl: '',
        name: '',
        pickupAddressId: '',
        deliveryAddressId: '',
        deliveredAt: '',
        pickupAt: '',
        sendedPkgDetail: '',
        sendedPkgImgUrl: '',
      );

      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: job.deliveryId,
        data: delivery.toJson(),
      );
    } catch (e) {
      log("Accept delivery job error: ${e.toString()}");
    }
  }

  static Future<LatLng?> getRiderLocationOnJob(String deliveryId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('rider_location')
          .doc(deliveryId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return LatLng(
          data['latitude']?.toDouble() ?? 0.0,
          data['longitude']?.toDouble() ?? 0.0,
        );
      }
      return null;
    } catch (e) {
      log("Error getting rider location: ${e.toString()}");
      return null;
    }
  }

  static Future<void> updateRiderLocation(
    String deliveryId,
    LatLng location,
    String riderId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('rider_location')
          .doc(deliveryId)
          .set({
            'delivery_id': deliveryId,
            'rider_id': riderId,
            'latitude': location.latitude,
            'longitude': location.longitude,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      log("Updated rider location for delivery: $deliveryId");
    } catch (e) {
      log("Error updating rider location: ${e.toString()}");
    }
  }

  static Future<void> uploadPickupImage(
    String deliveryId,
    String imageUrl,
    String riderId,
  ) async {
    try {
      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: deliveryId,
        data: {
          'status': 'riding',
          'pickup_at': TimeHelper.getDateNow(),
          'sended_pkg_img_url': imageUrl,
          'rider_info': {
            'rider_id': riderId,
            'updated_at': TimeHelper.getDateNow(),
          },
          'updated_at': TimeHelper.getDateNow(),
        },
      );
      log("Updated delivery status to riding for: $deliveryId");
    } catch (e) {
      log("Error uploading pickup image: ${e.toString()}");
    }
  }

  static Future<void> uploadDeliveryImage(
    String deliveryId,
    String imageUrl,
  ) async {
    try {
      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: deliveryId,
        data: {
          'status': 'success',
          'delivered_at': TimeHelper.getDateNow(),
          'pickup_pkg_images_url': FieldValue.arrayUnion([imageUrl]),
          'updated_at': TimeHelper.getDateNow(),
        },
      );
      log("Updated delivery status to success for: $deliveryId");
    } catch (e) {
      log("Error uploading delivery image: ${e.toString()}");
    }
  }

  static Future<double> calculateDistanceFromDestination(
    LatLng currentLocation,
    LatLng destinationLocation,
  ) async {
    final Distance distance = Distance();
    return distance.as(LengthUnit.Meter, currentLocation, destinationLocation);
  }

  static void dispose() {
    log('Disposing delivery jobs stream');
    _deliveryJobsSubscription?.cancel();
    _deliveryJobsController?.close();
    _deliveryJobsSubscription = null;
    _deliveryJobsController = null;
  }
}
