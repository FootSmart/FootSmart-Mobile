import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

class AppSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.md)),
  });

  const AppSkeleton.card({super.key})
      : width = double.infinity,
        height = 120,
        borderRadius = const BorderRadius.all(Radius.circular(AppRadius.lg));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.borderSubtle,
      highlightColor: colorScheme.borderDefault,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.backgroundElevated,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
