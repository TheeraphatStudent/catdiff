import 'dart:developer';

import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryService {
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

  static Future<List<Delivery>> getDeliveryByUserId(String userId) async {
    try {
      final response = await FirebaseHelper().getDocumentsQuery(
        collection: 'delivery',
        where: {'user_id': userId},
      );

      log('Retrieved ${response.length} deliveries for user: $userId');

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
      final now = DateTime.now().toIso8601String();
      final deliveryData = delivery.toJson();

      // Set timestamps
      deliveryData['created_at'] = now;
      deliveryData['updated_at'] = now;

      // Generate new document ID
      final docRef = FirebaseFirestore.instance.collection('delivery').doc();
      deliveryData['delivery_id'] = docRef.id;

      await FirebaseHelper().setDocument(
        collection: 'delivery',
        documentId: docRef.id,
        data: deliveryData,
      );

      log('Created delivery: ${docRef.id}');
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

  static Future<Delivery?> updateDeliveryStatusFromString(
    String deliveryId,
    String statusString,
  ) async {
    final status = StatusTypes().getStatusTypeEnum(statusString);
    return await updateDeliveryStatus(deliveryId, status);
  }
}
