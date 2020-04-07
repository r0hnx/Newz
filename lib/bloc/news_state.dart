part of 'news_bloc.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => null;
}

class NewsLoading extends NewsState {}

class NewsListLoaded extends NewsState {
  final List<List<News>> newsList;
  final List<List<Source>> sourceList;
  const NewsListLoaded({@required this.newsList, @required this.sourceList}) : assert(newsList != null), assert(sourceList != null);

  @override
  List<Object> get props => [newsList, sourceList];
}

class SourceNewsLoaded extends NewsState {
  final List<News> news;
  const SourceNewsLoaded({@required this.news});

  @override
  List<Object> get props => [news];
}

class CategoryLoaded extends NewsState {
  final List<News> news;
  const CategoryLoaded({@required this.news}) : assert(news != null);

  @override
  List<Object> get props => [news];
}

class QueryLoaded extends NewsState {
  final List<News> newsList;
  const QueryLoaded({@required this.newsList}) : assert(newsList != null);

  @override
  List<Object> get props => [newsList];
}

class NewsError extends NewsState {}
