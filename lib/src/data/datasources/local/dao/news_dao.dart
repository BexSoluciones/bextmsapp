part of '../app_database.dart';

class NewsDao {
  final AppDatabase _appDatabase;

  NewsDao(this._appDatabase);

  List<News> parseNews(List<Map<String, dynamic>> newsList) {
    final news = <News>[];
    for (var newsMap in newsList) {
      final n = News.fromJson(newsMap);
      news.add(n);
    }
    return news;
  }

  Future<List<News>> getAllNews() async {
    final db = await _appDatabase.streamDatabase;
    final newsList = await db!.query(tableNews);
    final news = parseNews(newsList);
    return news;
  }

  Stream<List<News>> watchAllNews() async* {
    final db = await _appDatabase.streamDatabase;
    final newsList = await db!.query(tableNews);
    final news = parseNews(newsList);
    yield news;
  }

  Future<int> insertNews(News news) {
    return _appDatabase.insert(tableNews, news.toJson());
  }

  Future<int> updateNews(News news) {
    return _appDatabase.update(
        tableNews, news.toJson(), 'id', news.id!);
  }

  Future<void> emptyNews() async {
    final db = await _appDatabase.streamDatabase;
    await db!.delete(tableNews);
    return Future.value();
  }
}
