import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/user.dart';
import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/service/helper/time.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/user/user_auth.dart';
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

                  final AddressInfo pickupAddress =
                      (delivery.pickupAddressId != null)
                      ? await AddressService.getAddressById(
                          delivery.pickupAddressId!,
                        )
                      : AddressInfo(
                          addressId: '',
                          latitude: 0.0,
                          longtitude: 0.0,
                          detail: 'ไม่พบข้อมูลที่อยู่รับสินค้า',
                          createdAt: DateTime.now().toIso8601String(),
                          updatedAt: DateTime.now().toIso8601String(),
                        );

                  final AddressInfo deliveryAddress =
                      (delivery.deliveryAddressId != null)
                      ? await AddressService.getAddressById(
                          delivery.deliveryAddressId!,
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
                      imagesUrl: delivery.profileImageUrl ?? '???',
                    ),
                    pickupAddress: pickupAddress,
                    deliveryAddress: deliveryAddress,
                    pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
                    sendedPkgDetail: delivery.sendedPkgDetail ?? '???',
                    sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? '???',
                  );
                } catch (e) {
                  log('Error processing individual delivery job ${doc.id}: $e');
                  return null;
                }
              }).toList();

              final response = await Future.wait(deliveryJobs);

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
              name: delivery.name ?? "",
              imagesUrl: delivery.profileImageUrl ?? "",
            ),
            reciver: UserInfo(
              userId: delivery.receivedId,
              name: delivery.name ?? "",
              imagesUrl: delivery.profileImageUrl ?? "",
            ),
            pickupAddress: AddressInfo(
              addressId: delivery.pickupAddressId ?? "",
              detail: "Pickup Address",
              latitude: 0.0,
              longtitude: 0.0,
              createdAt: delivery.createdAt ?? "",
              updatedAt: delivery.updatedAt,
            ),
            deliveryAddress: AddressInfo(
              addressId: delivery.deliveryAddressId ?? "",
              detail: "Delivery Address",
              latitude: 0.0,
              longtitude: 0.0,
              createdAt: delivery.createdAt ?? "",
              updatedAt: delivery.updatedAt,
            ),
            pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
            sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? "",
            sendedPkgDetail: delivery.sendedPkgDetail ?? "",
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

  static Future<void> onWorkingDeliveryJob(
    DeliveryJob job,
    User riderInfo,
  ) async {
    try {
      // log('Rider ${riderInfo.userId} accepting job: ${job.deliveryId}');
      // log('Setting status to: receiving');
      // log('Rider info: ${riderInfo.toJson()}');

      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: job.deliveryId,
        data: {
          'status': 'receiving',
          'rider_info': riderInfo.toJson(),
          'updated_at': TimeHelper.getDateNow(),
          'pickup_address_id': job.pickupAddress.addressId,
          'delivery_address_id': job.deliveryAddress.addressId,
        },
      );

      log(
        'Successfully updated job ${job.deliveryId} with rider ${riderInfo.userId}',
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

  static Future<bool> getRiderJobExist(String userId) async {
    try {
      log("Checking for active rider job for user: $userId");

      final doc = await FirebaseFirestore.instance
          .collection('delivery')
          .where('rider_info.user_id', isEqualTo: userId)
          .where('status', whereIn: ['receiving', 'riding'])
          .get();

      final hasActiveJob = doc.docs.isNotEmpty;
      log("Rider $userId has active job: $hasActiveJob");

      if (doc.docs.isNotEmpty) {
        log("Found ${doc.docs.length} active job(s) for rider $userId");
        for (var docSnapshot in doc.docs) {
          final data = docSnapshot.data();
          log(
            "Job ${docSnapshot.id}: status=${data['status']}, rider_info=${data['rider_info']}",
          );
        }
      }
      // else {
      //   log("No active jobs found for rider $userId");
      //   final allRiderJobs = await FirebaseFirestore.instance
      //       .collection('delivery')
      //       .where('rider_info.user_id', isEqualTo: userId)
      //       .get();
      //   log("Total jobs for rider $userId: ${allRiderJobs.docs.length}");
      //   for (var docSnapshot in allRiderJobs.docs) {
      //     final data = docSnapshot.data();
      //     log("Job ${docSnapshot.id}: status=${data['status']}");
      //   }
      // }

      return hasActiveJob;
    } catch (e) {
      log("Error checking rider active job: ${e.toString()}");
      return false;
    }
  }

  static Future<DeliveryJob?> getActiveRiderJob(String userId) async {
    try {
      log("Getting active rider job details for user: $userId");

      final querySnapshot = await FirebaseFirestore.instance
          .collection('delivery')
          .where('rider_info.user_id', isEqualTo: userId)
          .where('status', whereIn: ['receiving', 'riding'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        log("No active job found for rider: $userId");
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['delivery_id'] = doc.id;

      final delivery = Delivery.fromJson(data);

      final AddressInfo pickupAddress = (delivery.pickupAddressId != null)
          ? await AddressService.getAddressById(delivery.pickupAddressId!)
          : AddressInfo(
              addressId: '',
              latitude: 0.0,
              longtitude: 0.0,
              detail: 'ไม่พบข้อมูลที่อยู่รับสินค้า',
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );

      final AddressInfo deliveryAddress = (delivery.deliveryAddressId != null)
          ? await AddressService.getAddressById(delivery.deliveryAddressId!)
          : AddressInfo(
              addressId: '',
              latitude: 0.0,
              longtitude: 0.0,
              detail: 'ไม่พบข้อมูลที่อยู่จัดส่ง',
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            );

      final senderUser = (delivery.sendedId.isNotEmpty)
          ? await AuthService.getUserById(userId: delivery.sendedId)
          : null;

      final receiverUser = (delivery.receivedId.isNotEmpty)
          ? await AuthService.getUserById(userId: delivery.receivedId)
          : null;

      final deliveryJob = DeliveryJob(
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
          imagesUrl: delivery.profileImageUrl ?? '???',
        ),
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
        sendedPkgDetail: delivery.sendedPkgDetail ?? '???',
        sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? '???',
      );

      log(
        "Found active job: ${deliveryJob.deliveryId} with status: ${deliveryJob.status}",
      );
      return deliveryJob;
    } catch (e) {
      log("Error getting active rider job: ${e.toString()}");
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
      log("Uploading pickup image for delivery: $deliveryId");

      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: deliveryId,
        data: {
          'status': 'riding',
          'pickup_at': TimeHelper.getDateNow(),
          'pickup_pkg_images_url': FieldValue.arrayUnion([imageUrl]),
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
          'sended_pkg_img_url': imageUrl,
          'updated_at': TimeHelper.getDateNow(),
        },
      );
      log("Updated delivery status to success for: $deliveryId");
    } catch (e) {
      log("Error uploading delivery image: ${e.toString()}");
    }
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  static Future<bool> isWithinCompletionRange(
    LatLng currentLocation,
    LatLng destinationLocation,
  ) async {
    final distance = calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      destinationLocation.latitude,
      destinationLocation.longitude,
    );
    return distance <= 20.0;
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters >= 1000) {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} กม.';
    } else {
      return '${distanceInMeters.toStringAsFixed(0)} ม.';
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
