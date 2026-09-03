import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Horizontal scroll of photo thumbnails with a full-screen lightbox
/// (doc 11). Pass [onAddPhoto] to show a trailing "+ Add" tile.
class PhotoGallery extends StatelessWidget {
  const PhotoGallery({
    super.key,
    required this.photoUrls,
    this.onAddPhoto,
    this.thumbHeight = 120,
    this.thumbWidth = 150,
  });

  final List<String> photoUrls;
  final VoidCallback? onAddPhoto;
  final double thumbHeight;
  final double thumbWidth;

  void _openLightbox(BuildContext context, int index) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: InteractiveViewer(
          child: CachedNetworkImage(
              imageUrl: photoUrls[index], fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thumbHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length + (onAddPhoto != null ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index >= photoUrls.length) {
            return _AddTile(width: thumbWidth, onTap: onAddPhoto!);
          }
          return InkWell(
            onTap: () => _openLightbox(context, index),
            borderRadius: AppRadius.sm,
            child: ClipRRect(
              borderRadius: AppRadius.sm,
              child: CachedNetworkImage(
                imageUrl: photoUrls[index],
                width: thumbWidth,
                height: thumbHeight,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                    width: thumbWidth, color: AppColors.surfaceContainer),
                errorWidget: (_, _, _) => Container(
                  width: thumbWidth,
                  color: AppColors.surfaceContainer,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.width, required this.onTap});

  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: DottedTile(width: width),
    );
  }
}

/// Dashed-border square used as the "add photo" affordance.
class DottedTile extends StatelessWidget {
  const DottedTile({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: AppColors.textSecondary),
          SizedBox(height: 4),
          Text('Add', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
