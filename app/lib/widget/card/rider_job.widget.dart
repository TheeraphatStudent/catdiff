import 'package:app/config/theme/app_theme.dart';
import 'package:app/widget/input.widget.dart';
import 'package:app/widget/profile_img.widget.dart';
import 'package:app/widget/tag.widget.dart';
import 'package:flutter/cupertino.dart';

class DeliverJobItem extends StatelessWidget {
  const DeliverJobItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 1.50),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          ProfileWidgets.avatar(
            isEdited: false,
            size: ProfileSize.md,
            imageUrl:
                "https://storage.googleapis.com/lottocat_bucket/uploads/2a168538-24b6-4454-bc4c-906cd49dc8a1.jpg",
            shape: ProfileShape.rectangle,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tag(color: AppColors.primary5, text: "#Cf-2510001"),
                InputField(hintText: "Test"),
              ],
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}
