import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class NewsLoadRequested extends NewsEvent {
  const NewsLoadRequested();
}

class NewsRefreshRequested extends NewsEvent {
  const NewsRefreshRequested();
}
