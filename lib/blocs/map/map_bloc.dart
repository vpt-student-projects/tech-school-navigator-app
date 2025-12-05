import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/floor.dart';
import '../../models/graph.dart';
import '../../models/room.dart';

import '../../services/floor_repo.dart';
import '../../services/graph_service.dart';
import '../../services/rooms_service.dart';

import '../../utils/build_route_latlng.dart';
import '../../utils/route_planner.dart';

import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  static const double _scale = 0.0009;

  final int floorId;
  final FloorRepo _floorRepo;
  final RoomsService _roomsService;
  final GraphService _graphService;

  MapBloc({
    required this.floorId,
    FloorRepo? floorRepo,
    RoomsService? roomsService,
    GraphService? graphService,
  })  : _floorRepo = floorRepo ?? FloorRepo(),
        _roomsService = roomsService ?? RoomsService(),
        _graphService =
            graphService ?? GraphService(Supabase.instance.client),
        super(MapInitial()) {
    on<MapLoadRequested>(_onLoad);
    on<MapRefreshRequested>(_onLoad);
    on<MapRouteRequested>(_onRouteRequested);
  }

  Future<void> _onLoad(
    MapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(MapLoading());
    try {
      final floor = await _floorRepo.getFloor(floorId);
      final nodes = await _graphService.getNodes(floorId);
      final edges = await _graphService.getEdges(floorId);
      final rooms = await _roomsService.fetchRooms(floorId);

      emit(MapLoaded(
        floor: floor,
        nodes: nodes,
        edges: edges,
        rooms: rooms,
        route: const [],
      ));
    } catch (e) {
      emit(MapLoadFailure(e.toString()));
    }
  }

  Future<void> _onRouteRequested(
    MapRouteRequested event,
    Emitter<MapState> emit,
  ) async {
    final state = this.state;
    if (state is! MapLoaded) return;

    final floor = state.floor;
    final nodes = state.nodes;
    final edges = state.edges;
    final rooms = state.rooms;

    try {
      if (nodes.isEmpty || edges.isEmpty) {
        throw Exception('Граф пуст: узлов=${nodes.length}, рёбер=${edges.length}');
      }

      final roomName = event.roomName;
      final room = rooms.firstWhere(
        (r) => r.name.trim().toLowerCase() == roomName.trim().toLowerCase(),
        orElse: () => throw Exception('Кабинет "$roomName" не найден'),
      );

      final start = nodes.firstWhere(
        (n) => n.kind == 'start',
        orElse: () => closestNodeTo(nodes, 0.5, 0.5)!,
      );

      final goal = nodeForRoom(nodes, room);
      if (goal == null) {
        throw Exception('Не удалось подобрать узел для кабинета');
      }

      final poly = buildRouteLatLng(
        floor: floor,
        nodes: nodes,
        edges: edges,
        start: start,
        goal: goal,
        scale: _scale,
      );

      final route = List<LatLng>.from(poly);
      if (route.isNotEmpty) {
        final roomPoint =
            _latLngFromNorm(floor, room.xNorm, room.yNorm, _scale);
        final last = route.last;
        const eps = 1e-9;
        final isSame = (last.latitude - roomPoint.latitude).abs() < eps &&
            (last.longitude - roomPoint.longitude).abs() < eps;
        if (!isSame) route.add(roomPoint);
      }

      emit(MapRouteBuilt(
        floor: floor,
        nodes: nodes,
        edges: edges,
        rooms: rooms,
        route: route,
        roomName: room.name,
      ));
    } catch (e) {
      emit(MapRouteError(
        floor: floor,
        nodes: nodes,
        edges: edges,
        rooms: rooms,
        route: state.route,
        error: e.toString(),
      ));
    }
  }

  LatLng _latLngFromNorm(
    Floor floor,
    double x,
    double y,
    double scale,
  ) {
    final w = floor.imageWidth.toDouble();
    final h = floor.imageHeight.toDouble();
    return LatLng(y * h * scale, x * w * scale);
  }
}
