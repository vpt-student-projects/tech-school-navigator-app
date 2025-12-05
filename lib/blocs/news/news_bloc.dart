import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/news.dart';
import '../../services/news_parser.dart';
import 'news_event.dart';
import 'news_state.dart';

typedef FetchNewsFn = Future<List<NewsItem>> Function();

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final FetchNewsFn fetchNews;

  NewsBloc({FetchNewsFn? fetchNews})
      : fetchNews = fetchNews ?? NewsParser.fetchNews,
        super(NewsInitial()) {
    on<NewsLoadRequested>(_onLoad);
    on<NewsRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    NewsEvent event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      final items = await fetchNews();
      emit(NewsLoaded(items));
    } catch (e) {
      emit(NewsFailure(e.toString()));
    }
  }
}
