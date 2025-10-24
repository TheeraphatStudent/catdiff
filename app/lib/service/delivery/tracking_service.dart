import 'dart:developer';

import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/user.dart';
import 'package:app/service/helper/firebase_connection.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingService {
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

      // Convert deliveries to delivery jobs with full address and user data
      final List<DeliveryJob> deliveryJobs = [];

      for (final delivery in deliveries) {
        try {
          // Fetch addresses from Firebase
          final pickupAddress = await AddressService.getAddressById(
            delivery.pickupAddressId!,
          );
          final deliveryAddress = await AddressService.getAddressById(
            delivery.deliveryAddressId!,
          );

          // Fetch user information
          final senderUser = await AuthService.getUserById(
            userId: delivery.sendedId,
          );
          final receiverUser = await AuthService.getUserById(
            userId: delivery.receivedId,
          );

          final deliveryJob = DeliveryJob(
            deliveryId: delivery.deliveryId,
            status: delivery.status,
            sender: UserInfo(
              userId: delivery.sendedId,
              name: senderUser?.name ?? "Unknown Sender",
              imagesUrl: senderUser?.imagesUrl ?? "",
            ),
            reciver: UserInfo(
              userId: delivery.receivedId,
              name: receiverUser?.name ?? "Unknown Receiver",
              imagesUrl: receiverUser?.imagesUrl ?? "",
            ),
            pickupAddress: pickupAddress,
            deliveryAddress: deliveryAddress,
            pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
            sendedPkgDetail: delivery.sendedPkgDetail ?? "",
            sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? "",
          );

          deliveryJobs.add(deliveryJob);
        } catch (e) {
          log('Error processing delivery ${delivery.deliveryId}: $e');
          // Continue with next delivery instead of failing completely
        }
      }

      log(
        'Successfully processed ${deliveryJobs.length} delivery jobs from ${deliveries.length} deliveries',
      );

      return {'date': targetDate.toIso8601String(), 'jobs': deliveryJobs};
    } catch (e) {
      log('Error querying deliveries by date: $e');
      return {'date': targetDate.toIso8601String(), 'jobs': <DeliveryJob>[]};
    }
  }

  static Stream<List<Map<String, dynamic>>>
  watchDeliveryJobsByUserIdGroupedByDate(String userId, UserType userType) {
    final String fieldName = userType == UserType.sender
        ? 'sended_id'
        : 'received_id';

    return FirebaseFirestore.instance
        .collection('delivery')
        .where(fieldName, isEqualTo: userId)
        .where(
          'status',
          whereNotIn: [
            StatusTypes().getStatusTypeString(StatusType.success),
            StatusTypes().getStatusTypeString(StatusType.prepare),
          ],
        )
        .snapshots()
        .asyncMap((snapshot) async {
          try {
            log(
              'Real-time delivery jobs received: ${snapshot.docs.length} documents',
            );

            final List<DeliveryJob> deliveryJobs = [];

            for (final doc in snapshot.docs) {
              try {
                final data = doc.data();
                data['delivery_id'] = doc.id;
                final delivery = Delivery.fromJson(data);

                final pickupAddress = await AddressService.getAddressById(
                  delivery.pickupAddressId!,
                );
                final deliveryAddress = await AddressService.getAddressById(
                  delivery.deliveryAddressId!,
                );

                final senderUser = await AuthService.getUserById(
                  userId: delivery.sendedId,
                );
                final receiverUser = await AuthService.getUserById(
                  userId: delivery.receivedId,
                );

                final deliveryJob = DeliveryJob(
                  deliveryId: delivery.deliveryId,
                  status: delivery.status,
                  sender: UserInfo(
                    userId: delivery.sendedId,
                    name: senderUser?.name ?? "Unknown Sender",
                    imagesUrl: senderUser?.imagesUrl ?? "",
                  ),
                  reciver: UserInfo(
                    userId: delivery.receivedId,
                    name: receiverUser?.name ?? "Unknown Receiver",
                    imagesUrl: receiverUser?.imagesUrl ?? "",
                  ),
                  pickupAddress: pickupAddress,
                  deliveryAddress: deliveryAddress,
                  pickupPkgImagesUrl: delivery.pickupPkgImagesUrl,
                  sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? "",
                  sendedPkgDetail: delivery.sendedPkgDetail ?? "",
                );

                deliveryJobs.add(deliveryJob);
              } catch (e) {
                log('Error processing delivery ${doc.id}: $e');
              }
            }

            final Map<String, List<DeliveryJob>> groupedJobs = {};

            for (final job in deliveryJobs) {
              String dateKey;
              try {
                final delivery = snapshot.docs
                    .firstWhere((doc) => doc.id == job.deliveryId)
                    .data();
                if (delivery['created_at'] != null) {
                  final createdDate = DateTime.parse(delivery['created_at']);
                  dateKey =
                      '${createdDate.year}/${createdDate.month.toString().padLeft(2, '0')}/${createdDate.day.toString().padLeft(2, '0')}';
                } else {
                  final now = DateTime.now();
                  dateKey =
                      '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
                }
              } catch (e) {
                final now = DateTime.now();
                dateKey =
                    '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
              }

              if (!groupedJobs.containsKey(dateKey)) {
                groupedJobs[dateKey] = [];
              }
              groupedJobs[dateKey]!.add(job);
            }

            final List<Map<String, dynamic>> result = groupedJobs.entries
                .map((entry) => {'date': entry.key, 'jobs': entry.value})
                .toList();

            result.sort((a, b) {
              try {
                final dateA = DateTime.parse(a['date'].replaceAll('/', '-'));
                final dateB = DateTime.parse(b['date'].replaceAll('/', '-'));
                return dateB.compareTo(dateA);
              } catch (e) {
                return 0;
              }
            });

            log(
              'Real-time grouped delivery jobs: ${result.length} date groups',
            );
            return result;
          } catch (e) {
            log('Error in real-time delivery jobs stream: $e');
            return <Map<String, dynamic>>[];
          }
        });
  }
}
