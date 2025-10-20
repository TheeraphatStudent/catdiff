import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
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
import 'package:app/widget/sliding_up/map_viewer_single-point.widget.dart';
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
  String _searchQuery = '';

  bool _hasLoadedData = false;
  String _currentContentType = "";
  bool _isSliderOpen = false;

  int _currentSenderStep = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedData) {
      _loadData();
      _hasLoadedData = true;
    }
  }

  void _loadData() async {
    final appData = Provider.of<AppData>(context, listen: false);

    final resposne = await DeliveryService.getDeliveryDisplayByUserId(
      appData.currentUser!.id,
    );

    final reciverListRes = await ReciverService.getReciverList(
      '',
      appData.currentUser!.id,
    );

    log(
      'Retrieved ${resposne.length} deliveries for user: ${appData.currentUser!.id}',
    );

    setState(() {
      // senderItems = resposne.where((item) => item.status == 'sender').toList();
      // receiverItems = resposne
      //     .where((item) => item.status == 'receiver')
      //     .toList();

      senderItems.addAll(
        resposne.where((item) => item.sendedId == appData.currentUser!.id),
      );
      receiverItems.addAll(
        resposne.where((item) => item.receiverId == appData.currentUser!.id),
      );

      reciverItems.addAll(reciverListRes);
      filteredReciverItems = List.from(reciverItems);
    });
  }

  void _filterReciverItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredReciverItems = List.from(reciverItems);
      } else {
        filteredReciverItems = reciverItems
            .where(
              (receiver) =>
                  receiver.name.toLowerCase().contains(query.toLowerCase()),
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
                      log("On preseed work");

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
                  mainAxisSize: MainAxisSize.min,
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
                      },
                      onTap: () {
                        log(
                          'StatusContainer onTap: Setting sender mode and opening slider',
                        );
                        setState(() {
                          _currentContentType = "sender";
                          _isSliderOpen = true;
                        });
                        log(
                          'StatusContainer onTap: _isSliderOpen = $_isSliderOpen, _currentContentType = $_currentContentType',
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
                        setState(() {
                          _currentContentType = "receiver";
                          _isSliderOpen = !_isSliderOpen;
                        });
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
            onModalClosed: () => onClosedModal(),
            customTopBar: Center(child: Text("test")),
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
            isShowingAction: true,
            onLocationSelected: (selectedLatLng) {
              log(
                "Location selected: ${selectedLatLng.latitude}, ${selectedLatLng.longitude}",
              );

              if (_selectedDeliveryIdForLocation != null) {
                final newAddress = AddressInfo(
                  addressId: DateTime.now().millisecondsSinceEpoch.toString(),
                  detail:
                      "Selected location: ${selectedLatLng.latitude.toStringAsFixed(6)}, ${selectedLatLng.longitude.toStringAsFixed(6)}",
                  latitude: selectedLatLng.latitude,
                  longtitude: selectedLatLng.longitude,
                  createdAt: DateTime.now().toIso8601String(),
                  updatedAt: DateTime.now().toIso8601String(),
                );

                final index = _addedJobItemToDeliver.indexWhere(
                  (item) =>
                      item.deliveryJob.deliveryId ==
                      _selectedDeliveryIdForLocation,
                );

                if (index != -1) {
                  setState(() {
                    _addedJobItemToDeliver[index].deliveryJob.deliveryAddress =
                        newAddress;
                  });

                  log(
                    "Updated delivery address for delivery: $_selectedDeliveryIdForLocation",
                  );
                }
              }

              setState(() {
                _isMapOpen = false;
                _selectedDeliveryIdForLocation = null;
              });

              if (_shouldRestoreDeliveryModal) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() {
                      _isSliderOpen = true;
                      _currentContentType =
                          _savedContentType ??
                          _currentContentType; // Restore content type
                      _shouldRestoreDeliveryModal = false;
                      _savedContentType = null; // Clear saved state
                    });
                  }
                });
              }
            },
            onModalClosed: () {
              setState(() {
                _isMapOpen = false;
                _selectedDeliveryIdForLocation = null;
              });

              if (_shouldRestoreDeliveryModal) {
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    setState(() {
                      _isSliderOpen = true;
                      _currentContentType =
                          _savedContentType ??
                          _currentContentType; // Restore content type
                      _shouldRestoreDeliveryModal = false;
                      _savedContentType = null; // Clear saved state
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
    log("On close work");

    setState(() {
      _isSliderOpen = false;
      _currentContentType = "";
      _currentSenderStep = 0;
    });
  }

  void _nextSenderStep() {
    log("Next step work!");

    if (_currentSenderStep < 1) {
      setState(() {
        _currentSenderStep++;
      });
    }
  }

  void _previousSenderStep() {
    if (_currentSenderStep > 0) {
      setState(() {
        _currentSenderStep--;
      });
    }
  }

  void _goToSenderStep(int step) {
    if (step >= 0 && step <= 1) {
      setState(() {
        _currentSenderStep = step;
      });
    }
  }

  Widget _getCurrentSenderStepContent() {
    log("Building step content for step: $_currentSenderStep");
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
                        onTap: () {
                          log(receiver.address.addressId);
                          log(receiver.address.addressId);

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

  AddressInfo? _getDeliveryAddress(String deliveryId) {
    final index = _addedJobItemToDeliver.indexWhere(
      (item) => item.deliveryJob.deliveryId == deliveryId,
    );
    return index != -1
        ? _addedJobItemToDeliver[index].deliveryJob.deliveryAddress
        : null;
  }

  Future<void> addedJobItemToDeliver() async {
    if (_selectedReciver == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กรุณาเลือกผู้รับก่อน')));
      return;
    }

    log("Adding job item. Current count: ${_addedJobItemToDeliver.length}");

    try {
      final appData = Provider.of<AppData>(context, listen: false);

      final delivery = Delivery(
        deliveryId: '',
        profileImageUrl: appData.currentUser!.imagesUrl,
        name: 'Package ${_addedJobItemToDeliver.length + 1}',
        status: StatusType.pending,
        sendedId: appData.currentUser!.id,
        receivedId: _selectedReciver!.userId,
        pickupAddressId: appData.currentUser!.addressId,
        deliveryAddressId: _selectedReciver!.address.addressId,
        pickupPkgImagesUrl: [],
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

      profileController.addListener(() {
        if (profileController.uploadedUrl != null) {
          log(
            "Image uploaded for delivery ${createdDelivery.deliveryId}: ${profileController.uploadedUrl}",
          );

          final index = _addedJobItemToDeliver.indexWhere(
            (item) => item.deliveryJob.deliveryId == createdDelivery.deliveryId,
          );

          if (index != -1) {
            setState(() {
              _addedJobItemToDeliver[index].deliveryJob.pickupPkgImagesUrl = [
                profileController.uploadedUrl!,
              ];
            });

            log(
              "Updated pickupPkgImagesUrl for delivery ${createdDelivery.deliveryId}",
            );
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
              pickupPkgImagesUrl: [],
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
            ),
            profileController: profileController,
            userId: appData.currentUser!.id,
            onLocationTap: (AddressInfo address) {
              log("Location tap for delivery: ${createdDelivery.deliveryId}");
              log("Current address: ${address.detail}");
              log(address.latitude.toString());
              log(address.longtitude.toString());

              setState(() {
                _selectedDeliveryIdForLocation = createdDelivery.deliveryId;
                _shouldRestoreDeliveryModal = _isSliderOpen;
                _savedContentType = _currentContentType;
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

      log("Successfully created delivery: ${createdDelivery.deliveryId}");
    } catch (e) {
      log("Error creating delivery: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาดในการสร้างพัสดุ: $e'),
          backgroundColor: AppColors.lightDanger,
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
    log(
      "Removing job item at index: $index. Current count: ${_addedJobItemToDeliver.length}",
    );

    if (index >= 0 && index < _addedJobItemToDeliver.length) {
      final jobItem = _addedJobItemToDeliver[index];
      final deliveryId = jobItem.deliveryJob.deliveryId;

      try {
        final success = await DeliveryService.deleteDelivery(deliveryId);
        if (!success) {
          throw Exception('Failed to delete delivery from Firebase');
        }

        final controller = _packageImageControllers[deliveryId];
        if (controller != null) {
          controller.dispose();
          _packageImageControllers.remove(deliveryId);
          log("Disposed ProfileController for delivery ID: $deliveryId");
        }

        setState(() {
          _addedJobItemToDeliver.removeAt(index);
        });

        log("Successfully deleted delivery: $deliveryId");
        log("After removal, count: ${_addedJobItemToDeliver.length}");
      } catch (e) {
        log("Error deleting delivery $deliveryId: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการลบพัสดุ: $e'),
            backgroundColor: AppColors.lightDanger,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ยืนยันการส่งของสำเร็จ ${_addedJobItemToDeliver.length} รายการ',
        ),
        backgroundColor: AppColors.primary3,
      ),
    );

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
    super.dispose();
  }
}
