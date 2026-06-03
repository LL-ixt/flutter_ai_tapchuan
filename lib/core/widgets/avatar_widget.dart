import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class AvatarWidget extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isOnline;

  const AvatarWidget({
    super.key,
    required this.imageUrl,
    this.radius = 20.0,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            color: AppColors.dividerBorder,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: radius, color: Colors.grey);
                    },
                  )
                : Icon(Icons.person, size: radius, color: Colors.grey),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.6,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceWhite, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
