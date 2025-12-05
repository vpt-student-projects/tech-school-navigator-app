import 'package:equatable/equatable.dart';
import '../../models/news.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsItem> items;

  const NewsLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class NewsFailure extends NewsState {
  final String message;

  const NewsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
