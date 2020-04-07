import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:newz/model/news.dart';
import 'package:newz/repository/news_repo.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc < NewsEvent, NewsState > {

  final NewsRepository newsRepository;

  NewsBloc({
    @required this.newsRepository
  }): assert(newsRepository != null);

  @override
  NewsState get initialState => NewsLoading();

  @override
  Stream < NewsState > mapEventToState(
    NewsEvent event,
  ) async *{
    if (event is FetchSourceNews) {
      yield* _mapFetchSouceNewsToState(event);
    } 
    if (event is FetchQuery) {      
      yield* _mapFetchQueryToState(event);
    }
    if (event is FetchNewsList) {
      yield* _mapFetchNewsListToState(event);
    } else if (event is RefreshNews) {
      yield* _mapRefreshNewsToState(event);
    }
  }

  Stream < NewsState > _mapFetchSouceNewsToState(FetchSourceNews event) async *{
    yield NewsLoading();
    try {
      final List < News > news = await newsRepository.getTopHeadlinesBySource(event.source);
      yield SourceNewsLoaded(news: news);
    } catch (_) {
      yield NewsError();
    }
  }

  Stream < NewsState > _mapFetchQueryToState(FetchQuery event) async *{
    yield NewsLoading();
    try {
      final List < News > news = await newsRepository.getTopHeadlinesByQuery(event.query);
      yield QueryLoaded(newsList: news);
    } catch (_) {
      yield NewsError();
    }
  }

  Stream < NewsState > _mapFetchNewsListToState(FetchNewsList event) async *{
    yield NewsLoading();
    try {
      final List<String> category = [
        'latest',
        'local',
        'technology',
        'business',
        'sports',
        'entertainment',
        'health',
        'science'
      ];
      final List<List<News>> newsList = List<List<News>>();
      final List<List<Source>> sourceList = List<List<Source>>();
      newsList.add(await newsRepository.getTopHeadlinesByCountry("us"));
      sourceList.add(await newsRepository.getSource('general', "us"));
      newsList.add(await newsRepository.getTopHeadlinesByCountry(event.country));
      sourceList.add(await newsRepository.getSource("all", event.country));
      
      for (var i = 2; i < category.length; i++) {
        newsList.add(await newsRepository.getTopHeadlinesByCategory("us", category[i]));  
        sourceList.add(await newsRepository.getSource(category[i], "us"));       
      }  
      // print(newsList);
      // print(sourceList);
      yield NewsListLoaded(newsList: newsList, sourceList: sourceList);    
    } catch (_) {
      yield NewsError();
    }
  }

  Stream < NewsState > _mapRefreshNewsToState(RefreshNews event) async *{
    yield NewsLoading();
    try {
      if (event.category == 'latest') {
        final List < News > news = await newsRepository.getTopHeadlinesByCountry("us");
        yield CategoryLoaded(news: news);
      } else if  (event.category == 'local') {
        final List < News > news = await newsRepository.getTopHeadlinesByCountry(event.country);
        yield CategoryLoaded(news: news);
      } else {
        final List < News > news = await newsRepository.getTopHeadlinesByCategory("us", event.category);
        yield CategoryLoaded(news: news);
      }
    } catch (_) {}
  }
}