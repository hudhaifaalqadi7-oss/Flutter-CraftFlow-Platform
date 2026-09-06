import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/workshop.dart';

class WorkshopMedia {
  const WorkshopMedia._();

  static const carpentry = 'assets/images/carpentry_hero.jpg';
  static const blacksmith = 'assets/images/blacksmith_hero.jpg';
  static const aluminum = 'assets/images/aluminum_hero.jpg';

  static String heroFor(Workshop workshop) {
    switch (workshop.id) {
      case 'carpentry':
        return carpentry;
      case 'blacksmith':
        return blacksmith;
      default:
        return aluminum;
    }
  }
}

class CraftImage extends StatelessWidget {
  const CraftImage({required this.url, this.height, this.width, this.fit = BoxFit.cover, this.borderRadius, this.fallbackColor, super.key});

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      final isSvg = url.toLowerCase().endsWith('.svg');
      final image = isSvg
          ? SvgPicture.asset(
              url,
              height: height,
              width: width,
              fit: fit,
              placeholderBuilder: (_) => Container(
                height: height,
                width: width,
                color: fallbackColor ?? Colors.black12,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Image.asset(
              url,
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) => Container(
                height: height,
                width: width,
                color: fallbackColor ?? Colors.black12,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined, size: 38, color: Colors.black38),
              ),
            );
      return borderRadius == null ? image : ClipRRect(borderRadius: borderRadius!, child: image);
    }

    final image = Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              height: height,
              width: width,
              color: fallbackColor ?? Colors.black12,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width,
        color: fallbackColor ?? Colors.black12,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 38, color: Colors.black38),
      ),
    );

    return borderRadius == null ? image : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
