import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../models/floor.dart';
import '../../models/graph.dart';
import '../../models/room.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoadFailure extends MapState {
  final String message;

  const MapLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class MapLoaded extends MapState {
  final Floor floor;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<Room> rooms;
  final List<LatLng> route;

  const MapLoaded({
    required this.floor,
    required this.nodes,
    required this.edges,
    required this.rooms,
    required this.route,
  });

  MapLoaded copyWith({
    Floor? floor,
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    List<Room>? rooms,
    List<LatLng>? route,
  }) {
    return MapLoaded(
      floor: floor ?? this.floor,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      rooms: rooms ?? this.rooms,
      route: route ?? this.route,
    );
  }

  @override
  List<Object?> get props => [floor, nodes, edges, rooms, route];
}

/// Успешно построили маршрут до комнаты [roomName]
class MapRouteBuilt extends MapLoaded {
  final String roomName;

  const MapRouteBuilt({
    required super.floor,
    required super.nodes,
    required super.edges,
    required super.rooms,
    required super.route,
    required this.roomName,
  });

  @override
  List<Object?> get props => super.props + [roomName];
}

/// Ошибка при построении маршрута, но данные карты остаются
class MapRouteError extends MapLoaded {
  final String error;

  const MapRouteError({
    required super.floor,
    required super.nodes,
    required super.edges,
    required super.rooms,
    required super.route,
    required this.error,
  });

  @override
  List<Object?> get props => super.props + [error];
}
