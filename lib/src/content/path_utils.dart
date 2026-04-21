import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Linearly interpolates along a polyline [path] using normalized progress [t] (0..1).
///
/// - If path is empty: returns Offset(t, 0.6) as a safe fallback.
/// - If path has one point: returns that point.
/// - Otherwise: treats segments as equal-length in parameter space and lerps between
///   consecutive points.
Offset interpolatePath(List<Offset> path, double t) {
  final clampedT = t.clamp(0.0, 1.0);
  if (path.isEmpty) return Offset(clampedT, 0.6);
  if (path.length == 1) return path.first;

  final segments = path.length - 1;
  final scaled = clampedT * segments;
  final i = math.min(segments - 1, scaled.floor());
  final localT = scaled - i;

  final a = path[i];
  final b = path[i + 1];
  return Offset(
    a.dx + (b.dx - a.dx) * localT,
    a.dy + (b.dy - a.dy) * localT,
  );
}

