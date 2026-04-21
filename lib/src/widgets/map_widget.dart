import 'dart:async';
import 'package:flutter/material.dart';

import '../content/content_service.dart';
import '../content/path_utils.dart';
import '../data/step_storage.dart';
import '../domain/progress_engine.dart';
import '../domain/progress_event.dart';
import '../theme/app_theme.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    required this.worldId,
  });

  final String worldId;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  StreamSubscription<ProgressEvent>? _sub;
  double _progressPercent = 0;
  Size? _resolvedImageSize;

  @override
  void initState() {
    super.initState();
    _progressPercent = _calculateInitialProgress(widget.worldId);
    _resolveCurrentMapSize();
    _sub = ProgressEngine.instance.events.listen(_onProgressEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onProgressEvent(ProgressEvent event) {
    if (event.type != ProgressEvent.progressUpdated) return;
    if (event.worldId != widget.worldId) return;

    final percent = (event.metadata?['progressPercent'] as num?)?.toDouble();
    if (percent == null) return;

    if (!mounted) return;

    setState(() {
      _progressPercent = percent.clamp(0.0, 1.0);
    });
  }

  void _resolveCurrentMapSize() {
    final world = ContentService.instance.getById(widget.worldId);
    final mapAsset = world?.mapAsset;
    if (mapAsset == null) return;

    final provider = AssetImage(mapAsset);
    final stream = provider.resolve(const ImageConfiguration());
    stream.addListener(
      ImageStreamListener((info, _) {
        if (!mounted) return;
        setState(() {
          _resolvedImageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }),
    );
  }

  double _calculateInitialProgress(String worldId) {
    final world = ContentService.instance.getById(worldId);
    if (world == null || world.route.totalDistanceKm <= 0) {
      return 0;
    }

    final totalSteps = StepStorage.getTotalSteps(worldId);
    final totalKm = ProgressEngine.instance.distanceKmFromSteps(totalSteps);
    return (totalKm / world.route.totalDistanceKm).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final world = ContentService.instance.getById(widget.worldId);
    final mapAsset = world?.mapAsset;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final mapHeight = width * 3 / 4;

        final normalized = world?.path.isNotEmpty == true
            ? interpolatePath(world!.path, _progressPercent)
            : const Offset(0.5, 0.5);

        final imageRect = _computeContainedImageRect(
          containerWidth: width,
          containerHeight: mapHeight,
          imageSize: _resolvedImageSize,
        );

        final safeDx = normalized.dx.clamp(0.0, 1.0);
        final safeDy = normalized.dy.clamp(0.0, 1.0);

        final playerX = imageRect.left + safeDx * imageRect.width;
        final playerY = imageRect.top + safeDy * imageRect.height;

        return Container(
          height: mapHeight,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                /// 🗺 КАРТА
                Positioned.fill(
                  child: mapAsset == null
                      ? const ColoredBox(color: AppColors.card)
                      : Image.asset(
                    mapAsset,
                    fit: BoxFit.contain, // ✅ ВАЖНО
                    alignment: Alignment.center,
                  ),
                ),

                /// затемнение
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.08),
                  ),
                ),

                /// 🚶 ИГРОК (рисуем только когда знаем размер)
                if (_resolvedImageSize != null)
                  Positioned(
                    left: playerX - 10,
                    top: playerY - 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_walk,
                        size: 14,
                        color: AppColors.mapPlayer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Rect _computeContainedImageRect({
    required double containerWidth,
    required double containerHeight,
    required Size? imageSize,
  }) {
    final container = Size(containerWidth, containerHeight);

    if (imageSize == null ||
        imageSize.width <= 0 ||
        imageSize.height <= 0) {
      return Rect.fromLTWH(0, 0, container.width, container.height);
    }

    final imageAspect = imageSize.width / imageSize.height;
    final containerAspect = container.width / container.height;

    if (imageAspect > containerAspect) {
      final displayedHeight = container.width / imageAspect;
      final top = (container.height - displayedHeight) / 2;
      return Rect.fromLTWH(0, top, container.width, displayedHeight);
    } else {
      final displayedWidth = container.height * imageAspect;
      final left = (container.width - displayedWidth) / 2;
      return Rect.fromLTWH(left, 0, displayedWidth, container.height);
    }
  }
}