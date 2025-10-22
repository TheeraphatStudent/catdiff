import 'dart:developer';

import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/service/helper/time.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryService {
  static const String _counterCollection = 'delivery_counters';

  static Future<String> _generateDeliveryId() async {
    try {
      final now = DateTime.now();
      final yearMonth =
          '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}';
      final counterId = 'fc-$yearMonth';

      final counterRef = FirebaseFirestore.instance
          .collection(_counterCollection)
          .doc(counterId);

      return await FirebaseFirestore.instance.runTransaction((
        transaction,
      ) async {
        final counterDoc = await transaction.get(counterRef);

        int currentCount;
        if (!counterDoc.exists) {
          currentCount = 1;
        } else {
          currentCount = (counterDoc.data()?['count'] ?? 0) + 1;

          if (currentCount > 999) {
            currentCount = 1;
          }
        }

        // Update counter
        transaction.set(counterRef, {
          'count': currentCount,
          'updated_at': DateTime.now().toIso8601String(),
        });

        final deliveryId =
            'fc-$yearMonth${currentCount.toString().padLeft(3, '0')}';
        log('Generated delivery ID: $deliveryId');

        return deliveryId;
      });
    } catch (e) {
      log('Error generating delivery ID: $e');
      return 'fc-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static Future<List<Delivery>> getDeliveries() async {
    try {
      final response = await FirebaseHelper().getDocuments(
        collection: 'delivery',
      );

      log('Retrieved ${response.length} deliveries');

      return response.map((doc) {
        final data = doc.data();
        if (data != null) {
          data['delivery_id'] = doc.id;
          return Delivery.fromJson(data);
        }
        throw Exception('Document data is null for delivery: ${doc.id}');
      }).toList();
    } catch (e) {
      log('Error getting deliveries: $e');
      return [];
    }
  }

  static Future<List<Delivery>> getDeliverySenderJobByUserId(
    String userId,
    String reciverId,
  ) async {
    try {
      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'delivery',
        where: {'sended_id': userId, 'received_id': reciverId},
      );

      return response.map((doc) {
        final data = doc.data();
        if (data != null) {
          data['delivery_id'] = doc.id;
          return Delivery.fromJson(data);
        }
        throw Exception('Document data is null for delivery: ${doc.id}');
      }).toList();
    } catch (e) {
      log('Error getting deliveries for user $userId: $e');
      return [];
    }
  }

  static Future<List<DeliveryStatDisplayItem>> getDeliveryDisplayByUserId(
    String userId,
    UserType displayType,
  ) async {
    try {
      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'delivery',
        where: {
          if (displayType == UserType.sender) 'sended_id': userId,
          if (displayType == UserType.receiver) 'received_id': userId,
        },
      );

      // log('Retrieved ${response.length} deliveries for user: $userId');

      return response
          .where((doc) {
            final data = doc.data();
            return data != null;
          })
          .map((doc) {
            try {
              final data = doc.data()!;
              data['delivery_id'] = doc.id;

              // log('Processing delivery ${doc.id}: $data');

              return DeliveryStatDisplayItem.fromJson(data);
            } catch (e) {
              log('Error parsing delivery ${doc.id}: $e');
              log('Document data: ${doc.data()}');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<DeliveryStatDisplayItem>()
          .toList();
    } catch (e) {
      log('Error getting deliveries for user $userId: $e');
      return [];
    }
  }

  static Future<Delivery?> getDeliveryById(String id) async {
    try {
      final response = await FirebaseHelper().getDocumentById(
        collection: 'delivery',
        documentId: id,
      );

      if (response.exists) {
        final data = response.data()!;
        data['delivery_id'] = response.id;
        log('Retrieved delivery: $id');
        return Delivery.fromJson(data);
      } else {
        log('Delivery not found: $id');
        return null;
      }
    } catch (e) {
      log('Error getting delivery $id: $e');
      return null;
    }
  }

  static Future<Delivery?> createDelivery(Delivery delivery) async {
    try {
      final now = TimeHelper.getDateNow();
      final deliveryData = delivery.toJson();

      // Set timestamps
      deliveryData['created_at'] = now;
      deliveryData['updated_at'] = now;

      final customDeliveryId = await _generateDeliveryId();
      deliveryData['delivery_id'] = customDeliveryId;

      await FirebaseHelper().setDocument(
        collection: 'delivery',
        documentId: customDeliveryId,
        data: deliveryData,
      );

      log('Created delivery: $customDeliveryId');
      return Delivery.fromJson(deliveryData);
    } catch (e) {
      log('Error creating delivery: $e');
      return null;
    }
  }

  static Future<Delivery?> updateDelivery(Delivery delivery) async {
    try {
      final deliveryData = delivery.toJson();
      deliveryData['updated_at'] = DateTime.now().toIso8601String();

      await FirebaseHelper().updateDocument(
        collection: 'delivery',
        documentId: delivery.deliveryId,
        data: deliveryData,
      );

      log('Updated delivery: ${delivery.deliveryId}');
      return Delivery.fromJson(deliveryData);
    } catch (e) {
      log('Error updating delivery ${delivery.deliveryId}: $e');
      return null;
    }
  }

  static Future<bool> deleteDelivery(String deliveryId) async {
    try {
      await FirebaseHelper().deleteDocument(
        collection: 'delivery',
        documentId: deliveryId,
      );

      log('Deleted delivery: $deliveryId');
      return true;
    } catch (e) {
      log('Error deleting delivery $deliveryId: $e');
      return false;
    }
  }

  static Future<Delivery?> updateDeliveryStatus(
    String deliveryId,
    StatusType status,
  ) async {
    try {
      final delivery = await getDeliveryById(deliveryId);
      if (delivery != null) {
        final updatedDelivery = Delivery(
          profileImageUrl: delivery.profileImageUrl,
          name: delivery.name,
          status: status,
          deliveryId: delivery.deliveryId,
          sendedId: delivery.sendedId,
          receivedId: delivery.receivedId,
          pickupAddressId: delivery.pickupAddressId,
          deliveryAddressId: delivery.deliveryAddressId,
          pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
          createdAt: delivery.createdAt,
          updatedAt: DateTime.now().toIso8601String(),
          deliveredAt: status == StatusType.success
              ? DateTime.now().toIso8601String()
              : delivery.deliveredAt,
          pickupAt: delivery.pickupAt,
          sendedPkgDetail: delivery.sendedPkgDetail,
          sendedPkgImgUrl: delivery.sendedPkgImgUrl,
        );

        return await updateDelivery(updatedDelivery);
      }
      return null;
    } catch (e) {
      log('Error updating delivery status $deliveryId: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getDeliveryQueryByDate(
    DateTime targetDate,
  ) async {
    try {
      final startTime = targetDate.subtract(Duration(minutes: 1));
      final endTime = targetDate.add(Duration(minutes: 1));

      log(
        'Querying deliveries between ${startTime.toIso8601String()} and ${endTime.toIso8601String()}',
      );

      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'delivery',
        where: {
          'created_at': {
            '>=': startTime.toIso8601String(),
            '<=': endTime.toIso8601String(),
          },
        },
      );

      final deliveries = response.map((doc) {
        final data = doc.data();
        if (data != null) {
          data['delivery_id'] = doc.id;
          return Delivery.fromJson(data);
        }
        throw Exception('Document data is null for delivery: ${doc.id}');
      }).toList();

      // Convert Delivery objects to DeliveryJob objects
      final deliveryJobs = deliveries.map((delivery) {
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
      }).toList();

      log('Found ${deliveryJobs.length} delivery jobs in date range');

      return {'date': targetDate.toIso8601String(), 'jobs': deliveryJobs};
    } catch (e) {
      log('Error querying deliveries by date: $e');
      return {'date': targetDate.toIso8601String(), 'jobs': <DeliveryJob>[]};
    }
  }

  static Future<Delivery?> updateDeliveryStatusFromString(
    String deliveryId,
    String statusString,
  ) async {
    final status = StatusTypes().getStatusTypeEnum(statusString);
    return await updateDeliveryStatus(deliveryId, status);
  }
}
