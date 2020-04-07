import 'dart:convert';
import 'package:http/http.dart'
as http;
import 'package:meta/meta.dart';
import 'package:newz/model/news.dart';

part 'news_api.dart';

class NewsRepository {
  final NewsApiClient newsApiClient;
  NewsRepository({@required this.newsApiClient}) : assert(newsApiClient != null);
  Future<List<Source>> getSource(String category, String country){
    return newsApiClient.fetchSources(category, country);
  }

  Future<List<News>> getTopHeadlinesByCountry(String country){
    return newsApiClient.fetchTopHeadLinesByCountry(country);
  }

  Future<List<News>> getTopHeadlinesByCategory(String country, String category){
    return newsApiClient.fetchTopHeadLinesByCategory(country, category);
  }

  Future<List<News>> getTopHeadlinesByQuery(String query){
    return newsApiClient.fetchTopHeadLinesByQuery(query);
  }

  Future<List<News>> getTopHeadlinesBySource(String source){
    return newsApiClient.fetchTopHeadLinesBySources(source);
  }
}