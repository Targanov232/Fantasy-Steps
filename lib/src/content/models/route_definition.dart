import 'route_event_definition.dart';

class RouteDefinition {
  const RouteDefinition({
    required this.id,
    required this.name,
    required this.startLabel,
    required this.endLabel,
    required this.totalDistanceKm,
    required this.events,
  });

  final String id;
  final String name;
  final String startLabel;
  final String endLabel;
  final double totalDistanceKm;
  final List<RouteEventDefinition> events;

  String get routeLabel => '$startLabel → $endLabel';
}
