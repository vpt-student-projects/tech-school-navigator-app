import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapLoadRequested extends MapEvent {
  const MapLoadRequested();
}

class MapRefreshRequested extends MapEvent {
  const MapRefreshRequested();
}

class MapRouteRequested extends MapEvent {
  final String roomName;

  const MapRouteRequested(this.roomName);

  @override
  List<Object?> get props => [roomName];
}
