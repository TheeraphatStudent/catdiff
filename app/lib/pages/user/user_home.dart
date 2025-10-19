import 'dart:developer';

import 'package:app/config/share/app_data.dart';
import 'package:app/config/theme/app_theme.dart';
import 'package:app/layout/MainLayout.dart';
import 'package:app/service/delivery/delivery_service.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/card/status_container.widget.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
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
  final List<DeliveryStatDisplayItem> senderItems = [];
  final List<DeliveryStatDisplayItem> receiverItems = [];

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
                        setState(() {
                          _currentContentType = "sender";
                          _isSliderOpen = true;
                        });
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
    if (_currentSenderStep < 2) {
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
    if (step >= 0 && step <= 2) {
      setState(() {
        _currentSenderStep = step;
      });
    }
  }

  Widget _getCurrentSenderStepContent() {
    switch (_currentSenderStep) {
      case 0:
        return _buildSelectReceiverContent();
      case 1:
        return _buildPreparePackageContent();
      case 2:
        return _buildConfirmDeliveryContent();
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
          Expanded(child: _getCurrentSenderStepContent()),
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
              StepData(
                label: "ยืนยันการส่ง",
                active: _currentSenderStep == 2,
                icon: Icon(Icons.check),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- 1. Select receiver -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Widget _buildSelectReceiverContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
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
                  hintText: _currentContentType == "sender"
                      ? "ค้นหาผู้รับ"
                      : "ค้นหาผู้ส่ง",
                  onChanged: (value) {},
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: Center(child: Text("Select receiver content"))),
      ],
    );
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- 2. Prepare package -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Widget _buildPreparePackageContent() {
    return Column(
      children: [
        // Expanded(child: Center(child: Text("Prepare package content"))),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       ButtonActions(
        //         variant: ButtonVariant.secondary,
        //         icon: Icons.arrow_back,
        //         onPressed: _previousSenderStep,
        //         text: "ย้อนกลับ",
        //       ),
        //       ButtonActions(
        //         variant: ButtonVariant.primary,
        //         icon: Icons.arrow_forward,
        //         onPressed: _nextSenderStep,
        //         text: "ถัดไป",
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- 3. Confirm delivery -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Widget _buildConfirmDeliveryContent() {
    return Column(
      children: [
        // Expanded(child: Center(child: Text("Confirm delivery content"))),
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       ButtonActions(
        //         variant: ButtonVariant.secondary,
        //         icon: Icons.arrow_back,
        //         onPressed: _previousSenderStep,
        //         text: "ย้อนกลับ",
        //       ),
        //       ButtonActions(
        //         variant: ButtonVariant.primary,
        //         icon: Icons.check,
        //         onPressed: () {
        //           // Handle final confirmation
        //           onClosedModal();
        //         },
        //         text: "ยืนยัน",
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  // Receiver content

  // -=-=-=-=-=-=-=-=-=-=-=-=-=-=- Display receiver delivery to me -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  Widget _buildReceiverContent() {
    return Column(children: [Text("Receiver test")]);
  }
}
