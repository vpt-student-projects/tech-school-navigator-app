import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../models/floor.dart';
import '../dialogs/room_query.dart';
import '../widgets/floor_map.dart';

import '../blocs/map/map_bloc.dart';
import '../blocs/map/map_event.dart';
import '../blocs/map/map_state.dart';

class MapScreen extends StatelessWidget {
  final int floorId;
  const MapScreen({super.key, required this.floorId});

  Future<void> _onBuildRoutePressed(BuildContext context) async {
    final roomName = await askRoomNumber(context);
    if (roomName == null || roomName.trim().isEmpty) return;

    context.read<MapBloc>().add(MapRouteRequested(roomName.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MapBloc(floorId: floorId)..add(const MapLoadRequested()),
      child: BlocConsumer<MapBloc, MapState>(
        listenWhen: (prev, curr) =>
            curr is MapRouteBuilt || curr is MapRouteError,
        listener: (context, state) {
          if (state is MapRouteBuilt) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Маршрут до "${state.roomName}" построен')),
            );
          } else if (state is MapRouteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка маршрута: ${state.error}')),
            );
          }
        },
        builder: (context, state) {
          if (state is MapLoading || state is MapInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is MapLoadFailure) {
            return Scaffold(
              body: Center(
                child: Text('Ошибка: ${state.message}'),
              ),
            );
          }

          if (state is MapLoaded) {
            final Floor floor = state.floor;
            final List<LatLng> route = state.route;

            return Scaffold(
              appBar: AppBar(
                title: Text(floor.name),
              ),
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: FloorMap(
                    floor: floor,
                    nodeDots: const [],
                    roomDots: const [],
                    edgePolylines: const [],
                    pathLatLng: route,
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'fab_route',
                    onPressed: () => _onBuildRoutePressed(context),
                    label: const Text('Маршрут'),
                    icon: const Icon(Icons.alt_route),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    heroTag: 'fab_refresh',
                    onPressed: () {
                      context
                          .read<MapBloc>()
                          .add(const MapRefreshRequested());
                    },
                    label: const Text('Обновить'),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }

          return const Scaffold(
            body: Center(child: Text('Неизвестное состояние карты')),
          );
        },
      ),
    );
  }
}
