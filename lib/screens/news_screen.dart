import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/news/news_bloc.dart';
import '../blocs/news/news_event.dart';
import '../blocs/news/news_state.dart';
import '../models/news.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.embedded = false});

  /// Если embedded=true — возвращаем только контент без Scaffold/AppBar/FAB
  final bool embedded;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NewsBloc>().add(const NewsLoadRequested());
  }

  Future<void> _onRefresh() async {
    context.read<NewsBloc>().add(const NewsRefreshRequested());
  }

  Widget _buildBody(NewsState state) {
    if (state is NewsLoading || state is NewsInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NewsFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ошибка: ${state.message}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is NewsLoaded) {
      final items = state.items;

      if (items.isEmpty) {
        return const Center(child: Text('Новости не найдены'));
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final news = items[index];
            return _NewsCard(news: news);
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final body = BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) => _buildBody(state),
    );

    if (widget.embedded) {
      // встроенный режим (для HomeScreen) — без Scaffold/AppBar/FAB
      return body;
    }

    // отдельный экран
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости ВПТ'),
        backgroundColor: Colors.blue[800],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: _onRefresh,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              news.date,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(news.description),
            if (news.imageUrl != null) ...[
              const SizedBox(height: 8),
              Image.network(news.imageUrl!),
            ],
          ],
        ),
      ),
    );
  }
}
