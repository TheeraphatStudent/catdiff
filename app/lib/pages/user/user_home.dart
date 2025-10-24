import 'dart:async';
import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/address/address_service.dart';
import 'package:app/service/auth/reciver.dart';
import 'package:app/service/delivery/delivery_service.dart';
import 'package:app/types/address/address.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/delivery/delivery_job.dart';
import 'package:app/types/delivery/delivery.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/reciver/reciver.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/reciver_job.widget.dart';
import 'package:app/widget/card/rider_job.widget.dart';
import 'package:app/widget/card/status_container.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/sliding_up/map.widget.dart';
import 'package:app/widget/sliding_up/sliding_template.dart';
import 'package:app/widget/stepper.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Status container
  final List<DeliveryStatDisplayItem> senderItems = [];
  final List<DeliveryStatDisplayItem> receiverItems = [];

  // Reciver list
  final List<ReciverList> reciverItems = [];
  List<ReciverList> filteredReciverItems = [];

  bool _hasLoadedData = false;
  String _currentContentType = "";
  bool _isSliderOpen = false;

  int _currentSenderStep = 0;
  bool _isRealtimeListening = false;

  StreamSubscription<List<DeliveryStatDisplayItem>>? _senderSubscription;
  StreamSubscription<List<DeliveryStatDisplayItem>>? _receiverSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isRealtimeListening) {
      _startRealtimeListeners();
      _isRealtimeListening = true;
    }

    if (!_hasLoadedData) {
      _loadReceiverData();
      _hasLoadedData = true;
    }
  }

  void _loadReceiverData() async {
    final appData = Provider.of<AppData>(context, listen: false);

    final reciverListRes = await ReciverService.getReciverList(
      '',
      appData.currentUser!.id,
    );

    setState(() {
      reciverItems.clear();
      reciverItems.addAll(reciverListRes);
      filteredReciverItems = List.from(reciverItems);
    });

    // log(
    //   'Loaded ${reciverListRes.length} receivers. Delivery data will come from real-time streams.',
    // );
  }

  void _startRealtimeListeners() {
    final appData = Provider.of<AppData>(context, listen: false);

    _senderSubscription ??=
        DeliveryService.watchDeliveryDisplayByUserId(
          appData.currentUser!.id,
          UserType.sender,
        ).listen((items) {
          if (!mounted) return;
          // log('Real-time sender items received: ${items.length} items');
          setState(() {
            senderItems
              ..clear()
              ..addAll(items);
          });
        }, onError: (error) => log('Sender realtime stream error: $error'));

    _receiverSubscription ??=
        DeliveryService.watchDeliveryDisplayByUserId(
          appData.currentUser!.id,
          UserType.receiver,
        ).listen((items) {
          if (!mounted) return;
          // log('Real-time receiver items received: ${items.length} items');
          setState(() {
            receiverItems
              ..clear()
              ..addAll(items);
          });
        }, onError: (error) => log('Receiver realtime stream error: $error'));
  }

  Future<void> _refreshDeliveryStats() async {
    final appData = Provider.of<AppData>(context, listen: false);

    try {
      final senderStream = DeliveryService.watchDeliveryDisplayByUserId(
        appData.currentUser!.id,
        UserType.sender,
      );

      final receiverStream = DeliveryService.watchDeliveryDisplayByUserId(
        appData.currentUser!.id,
        UserType.receiver,
      );

      final senderItems = await senderStream.first.timeout(
        Duration(seconds: 5),
        onTimeout: () {
          // log('Sender stream timeout - using existing data');
          return this.senderItems;
        },
      );

      final receiverItems = await receiverStream.first.timeout(
        Duration(seconds: 5),
        onTimeout: () {
          // log('Receiver stream timeout - using existing data');
          return this.receiverItems;
        },
      );

      if (mounted) {
        setState(() {
          this.senderItems
            ..clear()
            ..addAll(senderItems);
          this.receiverItems
            ..clear()
            ..addAll(receiverItems);
        });
        // log('Delivery stats refreshed successfully');
      }
    } catch (e) {
      log('Error refreshing delivery stats: $e');
      // if (e.toString().contains('failed-precondition')) {
      //   log(
      //     'Skipping refresh due to missing Firebase index - please create the required index',
      //   );
      // }
    }
  }

  void _filterReciverItems(String query) {
    // log(query);

    setState(() {
      if (query.isEmpty) {
        filteredReciverItems = List.from(reciverItems);
      } else {
        // log(reciverItems.first.phoneNumber);

        filteredReciverItems = reciverItems
            .where(
              (receiver) =>
                  receiver.name.toLowerCase().contains(query.toLowerCase()) ||
                  receiver.phoneNumber.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    return MainLayout(
      scrollable: false,
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 152,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.primary5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0x3F819067),
                              blurRadius: 8,
                              offset: Offset(0, 1.50),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                appData.currentUser?.name ?? '???',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontFamily: 'Mali',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ไม่มีพัสดุจัดส่งหรือรอรับ',
                        style: TextStyle(
                          color: const Color(0xFF819067) /* Primary-Green2 */,
                          fontSize: 10,
                          fontFamily: 'Mali',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -22,
                  top: -22,
                  // child: ProfileWidget(isEdited: false, size: ProfileSize.md),
                  child: ProfileWidgets.avatar(
                    isEdited: false,
                    size: ProfileSize.md,
                    // imageUrl: "https://storage.googleapis.com/lottocat_bucket/uploads/2a168538-24b6-4454-bc4c-906cd49dc8a1.jpg",
                    imageUrl: appData.currentUser?.imagesUrl,
                    onPressed: () {
                      // log("On preseed work");

                      Get.offNamed('/profile');
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ส่งของ
                    StatusContainer(
                      onAddedTab: () {
                        setState(() {
                          _currentContentType = "sender";
                          _isSliderOpen = true;
                        });
                        _loadExistingPrepareJobs();
                      },
                      onTap: () {
                        // log("on tap sender");

                        Get.offNamed(
                          '/overview',
                          arguments: {'initialTabIsSender': true},
                        );
                      },
                      type: UserType.sender,
                      deliveryStatDisplayItems: senderItems,
                    ),

                    const SizedBox(height: 36),

                    // รับของ
                    StatusContainer(
                      onAddedTab: () {
                        setState(() {
                          _currentContentType = "receiver";
                          _isSliderOpen = !_isSliderOpen;
                        });
                      },
                      onTap: () {
                        // log("on tap receiver");

                        Get.offNamed(
                          '/overview',
                          arguments: {'initialTabIsSender': false},
                        );
                      },
                      type: UserType.receiver,
                      deliveryStatDisplayItems: receiverItems,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SlidingTemplate(
            isOpened: _isSliderOpen,
            onModalClosed: () => {onClosedModal()},
            customTopBar: Center(child: Text("การจัดส่ง")),
            children: [
              _currentContentType == "sender"
                  ? _buildSenderContent()
                  : _currentContentType == "receiver"
                  ? _buildReceiverContent()
                  : Column(children: [Text("เลือกประเภทการจัดส่ง")]),
            ],
          ),
          MapsLocationSelector(
            isOpened: _isMapOpen,
            isShowingAction: false,
            latitude: _selectedDeliveryIdForLocation != null
                ? _getDeliveryAddress(_selectedDeliveryIdForLocation!)?.latitude
                : null,
            longitude: _selectedDeliveryIdForLocation != null
                ? _getDeliveryAddress(
                    _selectedDeliveryIdForLocation!,
                  )?.longtitude
                : null,
            onAddressSelected: (latLng, address) async {
              // log(
              //   "Address selected: $address at coordinates: ${latLng.latitude}, ${latLng.longitude}",
              // );

              final currentDeliveryId = _selectedDeliveryIdForLocation;
              if (currentDeliveryId == null) {
                // log("No delivery ID selected for location update");
                return;
              }

              try {
                final index = _addedJobItemToDeliver.indexWhere(
                  (item) => item.deliveryJob.deliveryId == currentDeliveryId,
                );

                if (index == -1) {
                  // log("Delivery item not found for ID: $currentDeliveryId");
                  return;
                }

                final currentDeliveryAddress =
                    _addedJobItemToDeliver[index].deliveryJob.deliveryAddress;

                final updatedAddress = await AddressService.updateAddress(
                  addressId: currentDeliveryAddress.addressId,
                  latitude: latLng.latitude,
                  longitude: latLng.longitude,
                  detail: address,
                );

                // log(
                //   "Updated address for delivery $currentDeliveryId: ${updatedAddress.addressId}",
                // );

                setState(() {
                  _addedJobItemToDeliver[index].deliveryJob.deliveryAddress =
                      updatedAddress;
                });

                setState(() {
                  _isMapOpen = false;
                  _selectedDeliveryIdForLocation = null;
                  _pendingLocationUpdates.remove(currentDeliveryId);
                });

                _updateDeliveryJob(_addedJobItemToDeliver[index].deliveryJob);
              } catch (e) {
                log(
                  "Error updating address for delivery $currentDeliveryId: $e",
                );

                setState(() {
                  _pendingLocationUpdates.remove(currentDeliveryId);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('เกิดข้อผิดพลาดในการอัปเดตที่อยู่: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onModalClosed: () {
              final currentDeliveryId = _selectedDeliveryIdForLocation;
              setState(() {
                _isMapOpen = false;
                _selectedDeliveryIdForLocation = null;
                if (currentDeliveryId != null) {
                  _pendingLocationUpdates.remove(currentDeliveryId);
                }
              });

              if (_shouldRestoreDeliveryModal) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() {
                      _isSliderOpen = true;
                      _currentContentType =
                          _savedContentType ?? _currentContentType;
                      _currentSenderStep =
                          _savedSenderStep ?? _currentSenderStep;
                      _shouldRestoreDeliveryModal = false;
                      _savedContentType = null;
                      _savedSenderStep = null;
                    });
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }

  void onClosedModal() {
    setState(() {
      _isSliderOpen = false;
      _currentContentType = "";
      _currentSenderStep = 0;
    });
  }

  void _nextSenderStep() {
    if (_currentSenderStep < 1) {
      setState(() {
        _currentSenderStep++;
      });
    }
  }

  // void _previousSenderStep() {
  //   if (_currentSenderStep > 0) {
  //     setState(() {
  //       _currentSenderStep--;
  //     });
  //   }
  // }

  // void _goToSenderStep(int step) {
  //   if (step >= 0 && step <= 1) {
  //     setState(() {
  //       _currentSenderStep = step;
  //     });
  //   }
  // }

  Widget _getCurrentSenderStepContent() {
    switch (_currentSenderStep) {
      case 0:
        return _buildSelectReceiverContent();
      case 1:
        return _buildPreparePackageContent();
      default:
        return _buildSelectReceiverContent();
    }
  }

  // Sender content

  Widget _buildSenderContent() {
    return SizedBox(
      height: 678,
      child: Column(
        spacing: 12,
        children: [
          Expanded(
            key: ValueKey('sender_step_$_currentSenderStep'),
            child: _getCurrentSenderStepContent(),
          ),
          StepperWidget(
            steps: [
              StepData(
                label: "เลือกผู้รับ",
                active: _currentSenderStep == 0,
                icon: Icon(Icons.add),
              ),
              StepData(
                label: "จัดเตรียมสินค้า",
                active: _currentSenderStep == 1,
                icon: Icon(Icons.inbox),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- 1. Select receiver -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  ReciverList? _selectedReciver;

  Widget _buildSelectReceiverContent() {
    return Column(
      spacing: 16,
      children: [
        Row(
          children: [
            ButtonActions(
              variant: ButtonVariant.danger,
              icon: Icons.arrow_back,
              width: ButtonWidth.fit,
              onPressed: () => onClosedModal(),
            ),
            SizedBox(width: 16),
            Expanded(
              child: InputField(
                type: InputType.fill,
                hintText: "ค้นหาผู้รับ",
                onChanged: (value) => _filterReciverItems(value),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ],
        ),
        Expanded(
          child: filteredReciverItems.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    spacing: 8,
                    children: filteredReciverItems.map((receiver) {
                      return ReciverJobItem(
                        reciver: receiver,
                        onAvatarTap: (reciver) {
                          log("On tap avatar");
                        },
                        onTap: () {
                          // log(receiver.address.addressId);

                          _selectedReciver = receiver;

                          _nextSenderStep();
                        },
                      );
                    }).toList(),
                  ),
                )
              : Center(child: Text("ไม่พบผู้รับ")),
        ),
      ],
    );
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- 2. Prepare package -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  final List<DeliverJobItem> _addedJobItemToDeliver = [];
  final Map<String, ProfileController> _packageImageControllers = {};

  bool _isMapOpen = false;
  String? _selectedDeliveryIdForLocation;
  bool _shouldRestoreDeliveryModal = false;
  String? _savedContentType;
  int? _savedSenderStep;

  // Track which delivery items are pending location updates
  final Set<String> _pendingLocationUpdates = {};

  AddressInfo? _getDeliveryAddress(String deliveryId) {
    final index = _addedJobItemToDeliver.indexWhere(
      (item) => item.deliveryJob.deliveryId == deliveryId,
    );
    return index != -1
        ? _addedJobItemToDeliver[index].deliveryJob.deliveryAddress
        : null;
  }

  Future<void> _updateDeliveryJob(DeliveryJob deliveryJob) async {
    try {
      final updatedDelivery = await DeliveryService.updateDeliveryJob(
        deliveryJob,
      );
      if (updatedDelivery != null) {
        log(
          'Successfully updated delivery job location: ${deliveryJob.deliveryId}',
        );
      } else {
        log(
          'Failed to update delivery job location: ${deliveryJob.deliveryId}',
        );
      }
    } catch (e) {
      log('Error updating delivery job location: $e');
    }
  }

  Future<void> _loadExistingPrepareJobs() async {
    try {
      final appData = Provider.of<AppData>(context, listen: false);

      final deliveries = await DeliveryService.getDeliverySenderJobByUserId(
        appData.currentUser!.id,
        _selectedReciver!.userId,
      );
      final prepareJobs = deliveries
          .where((delivery) => delivery.status == StatusType.prepare)
          .toList();

      if (prepareJobs.isNotEmpty) {
        setState(() {
          _addedJobItemToDeliver.clear();
          _packageImageControllers.clear();

          for (final delivery in prepareJobs) {
            final profileController = ProfileController();

            profileController.addListener(() {
              if (profileController.uploadedUrl != null) {
                final index = _addedJobItemToDeliver.indexWhere(
                  (item) => item.deliveryJob.deliveryId == delivery.deliveryId,
                );

                if (index != -1) {
                  setState(() {
                    _addedJobItemToDeliver[index]
                            .deliveryJob
                            .pickupPkgImagesUrl =
                        profileController.uploadedUrl!;
                  });

                  _updateDeliveryJob(_addedJobItemToDeliver[index].deliveryJob);
                }
              }
            });

            _packageImageControllers[delivery.deliveryId] = profileController;

            final deliveryJob = DeliveryJob(
              deliveryId: delivery.deliveryId,
              status: delivery.status,
              sender: UserInfo(
                userId: delivery.sendedId,
                name: appData.currentUser!.name,
                imagesUrl: appData.currentUser!.imagesUrl,
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
              sendedPkgDetail: delivery.sendedPkgDetail ?? "",
              sendedPkgImgUrl: delivery.sendedPkgImgUrl ?? "",
            );

            _addedJobItemToDeliver.add(
              DeliverJobItem(
                deliveryJob: deliveryJob,
                profileController: profileController,
                userId: appData.currentUser!.id,
                onLocationTap: (AddressInfo address) {
                  log("Location tap for delivery: ${deliveryJob.deliveryId}");

                  // Prevent opening map if already updating this delivery's location
                  if (_pendingLocationUpdates.contains(
                    deliveryJob.deliveryId,
                  )) {
                    log(
                      "Location update already in progress for delivery: ${deliveryJob.deliveryId}",
                    );
                    return;
                  }

                  setState(() {
                    _selectedDeliveryIdForLocation = deliveryJob.deliveryId;
                    _pendingLocationUpdates.add(deliveryJob.deliveryId);
                    _shouldRestoreDeliveryModal = _isSliderOpen;
                    _savedContentType = _currentContentType;
                    _savedSenderStep = _currentSenderStep;
                    _isSliderOpen = false;
                  });

                  Future.delayed(Duration(milliseconds: 300), () {
                    if (mounted) {
                      setState(() {
                        _isMapOpen = true;
                      });
                    }
                  });
                },
              ),
            );
          }
        });
      }
    } catch (e) {
      log("Error loading existing prepare jobs: $e");
    }
  }

  Future<void> addedJobItemToDeliver() async {
    if (_selectedReciver == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกผู้รับก่อน')));
      return;
    }

    try {
      final appData = Provider.of<AppData>(context, listen: false);

      final delivery = Delivery(
        deliveryId: '',
        profileImageUrl: appData.currentUser!.imagesUrl,
        name: 'Package ${_addedJobItemToDeliver.length + 1}',
        status: StatusType.prepare,
        sendedId: appData.currentUser!.id,
        receivedId: _selectedReciver!.userId,
        pickupAddressId: appData.currentUser!.addressId,
        deliveryAddressId: _selectedReciver!.address.addressId,
        pickupPkgImagesUrl: '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        deliveredAt: null,
        pickupAt: null,
        sendedPkgDetail: 'Package ${_addedJobItemToDeliver.length + 1}',
        sendedPkgImgUrl: '',
      );

      final createdDelivery = await DeliveryService.createDelivery(delivery);
      if (createdDelivery == null) {
        throw Exception('Failed to create delivery');
      }

      final profileController = ProfileController();

      profileController.addListener(() async {
        if (profileController.uploadedUrl != null) {
          log(
            "Image uploaded for delivery ${createdDelivery.deliveryId}: ${profileController.uploadedUrl}",
          );

          final index = _addedJobItemToDeliver.indexWhere(
            (item) => item.deliveryJob.deliveryId == createdDelivery.deliveryId,
          );

          if (index != -1) {
            setState(() {
              _addedJobItemToDeliver[index].deliveryJob.pickupPkgImagesUrl =
                  profileController.uploadedUrl!;
            });

            try {
              final success = await DeliveryService.updatePickupImages(
                createdDelivery.deliveryId,
                profileController.uploadedUrl!,
              );

              if (success) {
                log(
                  "Successfully updated pickup images in Firebase for delivery: ${createdDelivery.deliveryId}",
                );
              } else {
                log(
                  "Failed to update pickup images in Firebase for delivery: ${createdDelivery.deliveryId}",
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('เกิดข้อผิดพลาดในการบันทึกรูปภาพ'),
                      backgroundColor: AppColors.darkDanger,
                    ),
                  );
                }
              }
            } catch (e) {
              log("Error updating pickup images in Firebase: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('เกิดข้อผิดพลาดในการบันทึกรูปภาพ: $e'),
                    backgroundColor: AppColors.darkDanger,
                  ),
                );
              }
            }
          }
        }
      });

      _packageImageControllers[createdDelivery.deliveryId] = profileController;

      setState(() {
        _addedJobItemToDeliver.add(
          DeliverJobItem(
            deliveryJob: DeliveryJob(
              deliveryId: createdDelivery.deliveryId,
              status: StatusType.pending,
              pickupPkgImagesUrl: '',
              pickupAddress: AddressInfo(
                addressId: appData.currentUser!.addressId,
                detail: "",
                latitude: 0,
                longtitude: 0,
                createdAt: '',
                updatedAt: '',
              ),
              deliveryAddress: AddressInfo(
                addressId: _selectedReciver!.address.addressId,
                detail: _selectedReciver!.address.detail,
                latitude: _selectedReciver!.address.latitude,
                longtitude: _selectedReciver!.address.longtitude,
                createdAt: '',
                updatedAt: '',
              ),
              sender: UserInfo(
                userId: appData.currentUser!.id,
                name: appData.currentUser!.name,
                imagesUrl: appData.currentUser!.imagesUrl,
              ),
              reciver: UserInfo(
                userId: _selectedReciver!.userId,
                name: _selectedReciver!.name,
                imagesUrl: _selectedReciver!.imageUrl,
              ),
              sendedPkgDetail: "",
              sendedPkgImgUrl: "",
            ),
            profileController: profileController,
            userId: appData.currentUser!.id,
            onLocationTap: (AddressInfo address) {
              log("Location tap for delivery: ${createdDelivery.deliveryId}");

              if (_pendingLocationUpdates.contains(
                createdDelivery.deliveryId,
              )) {
                log(
                  "Location update already in progress for delivery: ${createdDelivery.deliveryId}",
                );
                return;
              }

              setState(() {
                _selectedDeliveryIdForLocation = createdDelivery.deliveryId;
                _pendingLocationUpdates.add(createdDelivery.deliveryId);
                _shouldRestoreDeliveryModal = _isSliderOpen;
                _savedContentType = _currentContentType;
                _savedSenderStep = _currentSenderStep;
                _isSliderOpen = false;
              });

              Future.delayed(Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _isMapOpen = true;
                  });
                }
              });
            },
          ),
        );
      });
    } catch (e) {
      log("Error creating delivery: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการสร้างพัสดุ: $e'),
          backgroundColor: AppColors.darkDanger,
        ),
      );
    }
  }

  Widget _buildPreparePackageContent() {
    return Column(
      children: [
        // Action buttons row
        Row(
          children: [
            ButtonActions(
              variant: ButtonVariant.danger,
              icon: Icons.arrow_back,
              width: ButtonWidth.fit,
              onPressed: () => onClosedModal(),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ButtonActions(
                variant: ButtonVariant.outline,
                icon: Icons.add,
                iconPosition: IconPosition.right,
                width: ButtonWidth.full,
                text: "เพิ่มพัสดุ",
                onPressed: () {
                  addedJobItemToDeliver();
                },
              ),
            ),
            SizedBox(width: 8),
            ButtonActions(
              variant: ButtonVariant.primary,
              icon: Icons.check,
              width: ButtonWidth.fit,
              onPressed: _addedJobItemToDeliver.isNotEmpty
                  ? () {
                      _confirmToCreateDeliveryJob();
                    }
                  : null,
            ),
          ],
        ),
        SizedBox(height: 16),
        // Package items list
        Expanded(
          child: _addedJobItemToDeliver.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "ต้องการส่งอะไร เพิ่มได้เลย",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  key: ValueKey(
                    'package_list_${_addedJobItemToDeliver.length}',
                  ),
                  child: Column(
                    spacing: 8,
                    children: _addedJobItemToDeliver.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final jobItem = entry.value;
                      return Dismissible(
                        key: Key('job_item_$index'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _removeJobItem(index);
                        },
                        child: jobItem,
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _removeJobItem(int index) async {
    if (index >= 0 && index < _addedJobItemToDeliver.length) {
      final jobItem = _addedJobItemToDeliver[index];
      final deliveryId = jobItem.deliveryJob.deliveryId;

      try {
        final success = await DeliveryService.deleteDelivery(deliveryId);
        if (!success) {
          throw Exception('Failed to delete delivery from Firebase');
        }

        final deliveryAddress = jobItem.deliveryJob.deliveryAddress;
        if (_selectedReciver != null &&
            deliveryAddress.addressId != _selectedReciver!.address.addressId) {
          try {
            await AddressService.deleteAddress(deliveryAddress.addressId);
            log(
              "Deleted custom delivery address: ${deliveryAddress.addressId}",
            );
          } catch (addressError) {
            log(
              "Error deleting delivery address ${deliveryAddress.addressId}: $addressError",
            );
          }
        }

        final controller = _packageImageControllers[deliveryId];
        if (controller != null) {
          controller.dispose();
          _packageImageControllers.remove(deliveryId);
        }

        setState(() {
          _addedJobItemToDeliver.removeAt(index);
        });
      } catch (e) {
        log("Error deleting delivery $deliveryId: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการลบพัสดุ: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _confirmToCreateDeliveryJob() async {
    if (_selectedReciver == null || _addedJobItemToDeliver.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกผู้รับและเพิ่มพัสดุ')));
      return;
    }

    try {
      for (final jobItem in _addedJobItemToDeliver) {
        final deliveryId = jobItem.deliveryJob.deliveryId;

        final updatedDelivery =
            await DeliveryService.updateDeliveryStatusFromString(
              deliveryId,
              'pending',
            );

        if (updatedDelivery != null) {
          log("Successfully updated delivery $deliveryId to pending status");

          if (mounted) {
            _refreshDeliveryStats();
          }
        } else {
          log("Failed to update delivery $deliveryId to pending status");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ยืนยันการส่งของสำเร็จ ${_addedJobItemToDeliver.length} รายการ',
          ),
          backgroundColor: AppColors.primary3,
        ),
      );

      // Real-time streams will handle data updates automatically
      log('Package delivery confirmed - real-time streams will update UI');

      setState(() {
        for (final controller in _packageImageControllers.values) {
          controller.dispose();
        }
        _packageImageControllers.clear();

        _addedJobItemToDeliver.clear();
        _selectedReciver = null;
        _currentSenderStep = 0;
      });
      onClosedModal();
    } catch (e) {
      log("Error updating delivery jobs to pending: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการยืนยันการส่งของ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Receiver content

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- Display receiver delivery to me -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Widget _buildReceiverContent() {
    return Column(children: [Text("Receiver test")]);
  }

  @override
  void dispose() {
    for (final controller in _packageImageControllers.values) {
      controller.dispose();
    }
    _packageImageControllers.clear();

    _senderSubscription?.cancel();
    _receiverSubscription?.cancel();
    super.dispose();
  }
}
