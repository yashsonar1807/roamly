import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
          shape: shape,
        ),
      ),
    );
  }
}

class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ShimmerContainer(width: 32, height: 32, shape: BoxShape.circle),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 120, height: 14),
                    SizedBox(height: 6),
                    ShimmerContainer(width: 80, height: 10),
                  ],
                ),
              ],
            ),
          ),
          
          // Media (Edge-to-edge square)
          ShimmerContainer(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            borderRadius: 0,
          ),

          // Actions
          const Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                ShimmerContainer(width: 24, height: 24, shape: BoxShape.circle),
                SizedBox(width: 16),
                ShimmerContainer(width: 24, height: 24, shape: BoxShape.circle),
                SizedBox(width: 16),
                ShimmerContainer(width: 24, height: 24, shape: BoxShape.circle),
                Spacer(),
                ShimmerContainer(width: 24, height: 24, shape: BoxShape.circle),
              ],
            ),
          ),
          
          // Text lines
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ShimmerContainer(width: 100, height: 14),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ShimmerContainer(width: double.infinity, height: 14),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ShimmerContainer(width: 200, height: 14),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
