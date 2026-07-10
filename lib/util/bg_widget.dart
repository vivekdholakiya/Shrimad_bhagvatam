// ignore_for_file: constant_identifier_names, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import '../halper/context_extensions.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/images/bg_image2.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

class SpiritualDivider extends StatelessWidget {
  const SpiritualDivider({
    super.key,
    this.icon = Icons.spa,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.divider.withOpacity(.55),
                  AppColors.primary.withOpacity(.55),
                  AppColors.primary,
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.divider,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.spa_rounded,
            size: 22,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(.55),
                  AppColors.divider.withOpacity(.55),


                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
