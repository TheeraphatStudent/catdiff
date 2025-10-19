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
import 'package:flutter/cupertino.dart';
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
                      type: UserType.sender,
                      deliveryStatDisplayItems: senderItems,
                    ),

                    const SizedBox(height: 36),

                    // รับของ
                    StatusContainer(
                      type: UserType.receiver,
                      deliveryStatDisplayItems: receiverItems,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SlidingTemplate(
            isShowingAction: true,
            actionButtonText: 'Open Sliding Template',
            customTopBar: Row(
              children: [
                ButtonActions(
                  variant: ButtonVariant.danger,
                  icon: Icons.arrow_back,
                  onPressed: () {},
                ),
                Expanded(
                  child: InputField(
                    hintText: "ค้นหาผู้รับ",
                    onChanged: (value) {},
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ],
            ),
            children: [
              Column(children: [Text("test")]),
            ],
          ),
        ],
      ),
    );
  }
}
