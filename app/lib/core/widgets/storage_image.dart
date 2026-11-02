import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A photo from Firebase Storage, with a loading fill and a broken-image
/// fallback.
///
/// On the web Flutter downloads image bytes with a script request, which
/// the Storage bucket refuses unless it has a CORS policy — the photo
/// silently doesn't show. Here the web falls back to a plain `<img>`
/// element, which needs no CORS. Native apps use the disk cache.
class StorageImage extends StatelessWidget {
  const StorageImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.error,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Shown when there's no URL or the photo fails to load.
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    final loading = SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(color: AppColors.surfaceContainer),
    );
    final failed =
        error ??
        SizedBox(
          width: width,
          height: height,
          child: const ColoredBox(
            color: AppColors.surfaceContainer,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
    if (url.isEmpty) return failed;

    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : loading,
        errorBuilder: (_, _, _) => failed,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (_, _) => loading,
      errorWidget: (_, _, _) => failed,
    );
  }
}
