import 'package:app/config/theme/app_theme.dart';
import 'package:app/types/delivery/delivery_home.dart';
import 'package:app/types/status.dart';
import 'package:app/types/user/type.dart';
import 'package:app/widget/button.widget.dart';
import 'package:app/widget/status/status_tag.widget.dart';
import 'package:flutter/material.dart';

class StatusContainer extends StatelessWidget {
  final UserType type;
  final List<DeliveryStatDisplayItem> deliveryStatDisplayItems;
  final VoidCallback onTap;
  final VoidCallback onAddedTab;

  const StatusContainer({
    super.key,
    required this.type,
    required this.deliveryStatDisplayItems,
    required this.onTap,
    required this.onAddedTab,
  });

  @override
  Widget build(BuildContext context) {
    final String title = (type == UserType.sender) ? "ส่งของ" : "รับของ";

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        decoration: ShapeDecoration(
          color: const Color(0xFFFAFFF1) /* General-White */,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFF819067) /* Primary-Green2 */,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  shadows: [
                    BoxShadow(
                      color: AppColors.primary5,
                      blurRadius: 8,
                      offset: Offset(0, 1.50),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.black /* General-Black */,
                        fontSize: 24,
                        fontFamily: 'Mali',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 16,
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 74),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: ShapeDecoration(
                            color: AppColors.grayLight /* Gray-Light */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.2),
                            child: SizedBox(
                              height: 96,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: deliveryStatDisplayItems.isEmpty
                                      ? [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              spacing: 8,
                                              children: [
                                                Text(
                                                  'ไม่มีพัสดุจัดส่ง',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .primary2 /* Primary-Green2 */,
                                                    fontSize: 12,
                                                    fontFamily: 'Mali',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                      : deliveryStatDisplayItems.map((item) {
                                          final statusTypes = StatusTypes();
                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              spacing: 4,
                                              children: [
                                                Row(
                                                  spacing: 4,
                                                  children: [
                                                    StatusTag(
                                                      statusType: item.status,
                                                      size: 12,
                                                    ),
                                                    Text(
                                                      item.deliveryId,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .primary2 /* Primary-Green2 */,
                                                        fontSize: 12,
                                                        fontFamily: 'Mali',
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '- ${statusTypes.getStatusMeaning(item.status)}',
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .primary2 /* Primary-Green2 */,
                                                    fontSize: 12,
                                                    fontFamily: 'Mali',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 10,
                      children: [
                        ButtonActions(
                          variant: ButtonVariant.secondary,
                          icon: Icons.add,
                          onPressed: () => onAddedTab(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
